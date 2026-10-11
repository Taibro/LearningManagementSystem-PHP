import 'package:flutter/material.dart';

class ReportsHeaderAndFilter extends StatefulWidget {
  final VoidCallback onExport;
  const ReportsHeaderAndFilter({super.key, required this.onExport});

  @override
  State<ReportsHeaderAndFilter> createState() => _ReportsHeaderAndFilterState();
}

class _ReportsHeaderAndFilterState extends State<ReportsHeaderAndFilter> {
  static const _kPrimary = Color(0xFF1A237E);
  String _selectedSemester = 'HK2 - 2025-2026';
  String _selectedDept = 'Tất cả khoa';

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildHeader(context),
      _buildFilter(),
    ]);
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bar_chart_rounded, color: _kPrimary, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Báo cáo & Thống kê',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5)),
                Text('Trích xuất dữ liệu',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              ],
            ),
          ),
          GestureDetector(
            onTap: widget.onExport,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                  color: _kPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: const Row(children: [
                Icon(Icons.download_rounded, color: _kPrimary, size: 16),
                SizedBox(width: 6),
                Text('Xuất',
                    style: TextStyle(
                        color: _kPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilter() {
    final semesters = ['HK2 - 2025-2026', 'HK1 - 2025-2026', 'HK2 - 2024-2025'];
    final depts = ['Tất cả khoa', 'Khoa CNTT', 'Khoa HTTT', 'Khoa KHMT'];
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(children: [
        Expanded(child: _dropdownField('Học kỳ', semesters, _selectedSemester, (v) => setState(() => _selectedSemester = v!))),
        const SizedBox(width: 10),
        Expanded(child: _dropdownField('Khoa', depts, _selectedDept, (v) => setState(() => _selectedDept = v!))),
      ]),
    );
  }

  Widget _dropdownField(String label, List<String> items, String value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
      onChanged: onChanged,
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.transparent)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.transparent)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _kPrimary.withOpacity(0.3), width: 1.5)),
      ),
      isExpanded: true,
      style: const TextStyle(fontSize: 12, color: Color(0xFF212121)),
      icon: const Icon(Icons.keyboard_arrow_down, color: _kPrimary, size: 18),
    );
  }
}
