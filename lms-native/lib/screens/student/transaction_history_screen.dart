import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/student/tuition_payment.dart';
import '../../repositories/student_repository.dart';
import 'widgets/shared/custom_app_bar.dart';
import '../../core/widgets/custom_loading_indicator.dart';

const Color _kBg = Color(0xFFF0F4FF);

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          const CustomAppBar(
            title: 'Lịch sử giao dịch trực tuyến',
            isGradient: true,
            paddingBottom: 16,
            fontSize: 17,
          ),
          Expanded(
            child: FutureBuilder<List<TuitionPayment>>(
              future: context.read<StudentRepository>().getPayments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CustomLoadingIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Lỗi: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                  );
                }
                final txs = snapshot.data ?? [];
                if (txs.isEmpty) {
                  return const Center(child: Text('Chưa có lịch sử giao dịch.'));
                }
                // Sort descending by date
                txs.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: txs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE8E8E8)),
                  itemBuilder: (_, i) => _TransactionRow(tx: txs[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final TuitionPayment tx;
  const _TransactionRow({required this.tx});

  String _formatMoney(double amount) {
    final intAmount = amount.toInt();
    final str = intAmount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write('.');
    }
    return '${buffer.toString().split('').reversed.join()}đ';
  }

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = tx.status == 'SUCCESS';
    final isFailed = tx.status == 'FAILED' || tx.status == 'CANCELLED';
    
    String statusText = 'Đang xử lý';
    Color statusColor = const Color(0xFFF57F17); // PENDING color
    
    if (isSuccess) {
      statusText = 'Thành công';
      statusColor = const Color(0xFF2E7D32);
    } else if (isFailed) {
      statusText = 'Giao dịch đã hủy';
      statusColor = const Color(0xFFE65100);
    }
    
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.note.isNotEmpty ? tx.note : 'Thu học phí',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDate(tx.paymentDate),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          // Right column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatMoney(tx.amount),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
