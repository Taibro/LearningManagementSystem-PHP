import 'package:flutter/material.dart';
import 'shared_sheet_helpers.dart';

class SalarySheet extends StatelessWidget {
  SalarySheet({super.key});

  final List<Map<String, dynamic>> _items = [
    {'label': 'Lương cơ bản', 'amount': '12,500,000đ', 'note': 'Hệ số 3.0', 'plus': true},
    {'label': 'Phụ cấp chức vụ', 'amount': '800,000đ', 'note': '', 'plus': true},
    {'label': 'Phụ cấp thâm niên', 'amount': '1,200,000đ', 'note': '8% lương CB', 'plus': true},
    {'label': 'Thưởng tiết dạy vượt', 'amount': '1,200,000đ', 'note': '12 tiết × 100,000đ', 'plus': true},
    {'label': 'Bảo hiểm xã hội (8%)', 'amount': '-1,000,000đ', 'note': '', 'plus': false},
    {'label': 'Thuế TNCN', 'amount': '-1,100,000đ', 'note': '', 'plus': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          buildSheetHandle(),
          buildSheetHeader('Thông tin lương', 'Tháng 3/2026',
              const Color(0xFF2E7D32)),
          // Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildSalaryStat('12,500,000đ', 'Lương cơ bản',
                    const Color(0xFF4CAF50)),
                const SizedBox(width: 8),
                _buildSalaryStat('3,200,000đ', 'Phụ cấp',
                    const Color(0xFF6B4FA0)),
                const SizedBox(width: 8),
                _buildSalaryStat('14,800,000đ', 'Thực nhận',
                    const Color(0xFFE85D75)),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ..._items.map((item) => _buildSalaryRow(item)),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6B4FA0), Color(0xFF8B6BBF)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('THỰC NHẬN',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      Text('14,800,000đ',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryStat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryRow(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['label'],
                    style: TextStyle(
                        fontSize: 13,
                        color: item['plus']
                            ? const Color(0xFF212121)
                            : const Color(0xFFC62828))),
                if ((item['note'] as String).isNotEmpty)
                  Text(item['note'],
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF9E9E9E))),
              ],
            ),
          ),
          Text(
            item['amount'],
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: item['plus']
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFC62828)),
          ),
        ],
      ),
    );
  }
}
