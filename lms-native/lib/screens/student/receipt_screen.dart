import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/student/tuition_payment.dart';
import '../../repositories/student_repository.dart';
import 'widgets/shared/custom_app_bar.dart';
import 'widgets/shared/mesh_background.dart';
import '../../core/widgets/custom_loading_indicator.dart';

const Color _kPrimary = Color(0xFF4F46E5);

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: MeshBackground(
        child: Column(
          children: [
            const CustomAppBar(title: 'Phiếu thu'),
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
                  
                  // Only show successful payments as receipts
                  final txs = (snapshot.data ?? [])
                      .where((tx) => tx.status == 'SUCCESS')
                      .toList();
                      
                  if (txs.isEmpty) {
                    return const Center(child: Text('Chưa có phiếu thu nào.'));
                  }
                  
                  // Sort descending by date
                  txs.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: txs.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _ReceiptCard(receipt: txs[i])
                          .animate()
                          .fade(duration: 400.ms, delay: (50 * i).ms)
                          .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final TuitionPayment receipt;
  const _ReceiptCard({required this.receipt});

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
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}, ${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Số phiếu & ngày giờ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Số phiếu: ',
                      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B), fontWeight: FontWeight.w500, height: 1.3),
                      children: [
                        TextSpan(
                          text: receipt.transactionCode.isNotEmpty ? receipt.transactionCode : '#${receipt.id}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _formatDate(receipt.paymentDate),
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Row 2: Đơn vị thu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_balance_rounded, size: 18, color: Color(0xFF10B981)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đơn vị thu',
                          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          receipt.paymentMethod,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 16),
              // Row 3: Số tiền
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _kPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.payments_rounded, size: 18, color: _kPrimary),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Số tiền',
                    style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    _formatMoney(receipt.amount),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _kPrimary,
                    ),
                  ),
                ],
              ),
              // Link xem hóa đơn (Optional, wait, real API doesn't have hasInvoice. Always true for receipts? Let's just keep it)
              const SizedBox(height: 16),
              InkWell(
                onTap: () {}, // TODO: handle action
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _kPrimary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _kPrimary.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.open_in_new_rounded, size: 16, color: _kPrimary),
                      const SizedBox(width: 6),
                      Text(
                        'Xem hoá đơn điện tử',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _kPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
