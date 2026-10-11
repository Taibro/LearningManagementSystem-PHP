import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/custom_loading_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/shared/lecturer_custom_app_bar.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/lecturer/salary/teacher_salary_bloc.dart';
import '../../blocs/lecturer/salary/teacher_salary_event.dart';
import '../../blocs/lecturer/salary/teacher_salary_state.dart';
import '../../models/lecturer/monthly_salary.dart';
import 'package:intl/intl.dart';

const Color _kPrimary = Color(0xFF6B4FA0);
const Color _kBg = Color(0xFFF8F9FA);

class LecturerSalaryScreen extends StatefulWidget {
  const LecturerSalaryScreen({super.key});

  @override
  State<LecturerSalaryScreen> createState() => _LecturerSalaryScreenState();
}

class _LecturerSalaryScreenState extends State<LecturerSalaryScreen> {
  int _selectedYear = 2026;
  int _selectedMonth = 3;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _fetchSalary();
  }

  void _fetchSalary() {
    context.read<TeacherSalaryBloc>().add(TeacherSalaryFetchRequested(
          year: _selectedYear,
          month: _selectedMonth,
        ));
  }

  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  String formatCurrency(double amount) {
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          const LecturerCustomAppBar(title: 'Thông tin lương'),
          Expanded(
            child: BlocBuilder<TeacherSalaryBloc, TeacherSalaryState>(
              builder: (context, state) {
                if (state is TeacherSalaryLoading) {
                  return Center(child: CustomLoadingIndicator());
                } else if (state is TeacherSalaryLoadFailure) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: _buildMonthSelector(),
                      ),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'Không có dữ liệu lương tháng $_selectedMonth/$_selectedYear',
                                style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 16),
                              ),
                            ],
                          ).animate().fadeIn().slideY(begin: 0.1),
                        ),
                      ),
                    ],
                  );
                } else if (state is TeacherSalaryLoadSuccess) {
                  final salary = state.salary;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      children: [
                        _buildTotalCard(salary).animate().fadeIn().slideY(begin: 0.1),
                        const SizedBox(height: 24),
                        _buildMonthSelector().animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                        const SizedBox(height: 24),
                        _buildSummaryCards(salary).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                        const SizedBox(height: 24),
                        _buildSalaryBreakdown(salary).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(MonthlySalary salary) {
    final items = [
      {'value': formatCurrency(salary.baseAmount ?? 0), 'label': 'Lương cơ bản', 'color': const Color(0xFF3B82F6), 'icon': Icons.account_balance_wallet_rounded},
      {'value': formatCurrency((salary.sessionAmount ?? 0) + (salary.bonusAmount ?? 0)), 'label': 'Phụ cấp & Thưởng', 'color': const Color(0xFFF59E0B), 'icon': Icons.stars_rounded},
    ];

    return Row(
      children: items.map((item) {
        final color = item['color'] as Color;
        final icon = item['icon'] as IconData;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 16),
                Text(
                  item['value'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['label'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMonthSelector() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) {
            int tempMonth = _selectedMonth;
            int tempYear = _selectedYear;
            return StatefulBuilder(
              builder: (ctx, setDialogState) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text('Chọn kỳ lương', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownButton<int>(
                        value: tempMonth,
                        items: List.generate(12, (index) => DropdownMenuItem(value: index + 1, child: Text('Tháng ${index + 1}'))),
                        onChanged: (val) => setDialogState(() => tempMonth = val!),
                      ),
                      const SizedBox(width: 16),
                      DropdownButton<int>(
                        value: tempYear,
                        items: List.generate(5, (index) => DropdownMenuItem(value: 2024 + index, child: Text('${2024 + index}'))),
                        onChanged: (val) => setDialogState(() => tempYear = val!),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedMonth = tempMonth;
                          _selectedYear = tempYear;
                        });
                        _fetchSalary();
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B4FA0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Chọn', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B4FA0).withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calendar_month_rounded, color: _kPrimary, size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kỳ lương',
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
                Text(
                  'Tháng $_selectedMonth/$_selectedYear',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B), size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryBreakdown(MonthlySalary salary) {
    final List<Map<String, dynamic>> details = [
      {'label': 'Lương cơ bản', 'amount': formatCurrency(salary.baseAmount ?? 0), 'note': 'Hệ số ${salary.coefficientSnapshot ?? 1.0}', 'plus': true},
      {'label': 'Phụ cấp & Thưởng', 'amount': formatCurrency(salary.bonusAmount ?? 0), 'note': '', 'plus': true},
      {'label': 'Thù lao vượt tiết', 'amount': formatCurrency(salary.sessionAmount ?? 0), 'note': '', 'plus': true},
      {'label': 'Các khoản khấu trừ', 'amount': '-${formatCurrency(salary.deductionAmount ?? 0)}', 'note': 'Thuế, BHXH...', 'plus': false},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4FA0).withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chi tiết bảng lương',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          ...details.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == details.length - 1;
            return Column(
              children: [
                _buildSalaryRow(item),
                if (!isLast) const Divider(color: Color(0xFFF1F5F9), height: 24, thickness: 1),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSalaryRow(Map<String, dynamic> item) {
    final isPlus = item['plus'];
    final iconColor = isPlus ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final bgColor = isPlus ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isPlus ? Icons.add_rounded : Icons.remove_rounded,
            color: iconColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['label'],
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              if ((item['note'] as String).isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  item['note'],
                  style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8)),
                ),
              ],
            ],
          ),
        ),
        Text(
          item['amount'],
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isPlus ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalCard(MonthlySalary salary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B4FA0), Color(0xFF8B6BBF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'THỰC NHẬN',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                formatCurrency(salary.netAmount ?? 0),
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }
}
