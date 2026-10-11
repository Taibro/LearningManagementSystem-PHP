import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'data/mock_school_data.dart';
import 'role_selection_screen.dart';
import '../student/widgets/shared/mesh_background.dart';

/// Screen 2: Chọn trường
class ChooseSchoolScreen extends StatefulWidget {
  final String? initialCode;
  const ChooseSchoolScreen({super.key, this.initialCode});

  @override
  State<ChooseSchoolScreen> createState() => _ChooseSchoolScreenState();
}

class _ChooseSchoolScreenState extends State<ChooseSchoolScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedFilter = 'Chọn đơn vị';
  int? _selectedIndex;
  List<SchoolInfo> _filtered = [];

  final _filterOptions = [
    'Chọn đơn vị',
    'Đại học',
    'Cao đẳng',
    'Doanh nghiệp',
  ];

  @override
  void initState() {
    super.initState();
    _filtered = List.from(mockSchools);
    if (widget.initialCode != null) {
      _searchCtrl.text = widget.initialCode!;
      _applySearch(widget.initialCode!);
    }
  }

  void _applySearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = List.from(mockSchools);
      } else {
        final q = query.toLowerCase();
        _filtered = mockSchools
            .where((s) =>
                s.name.toLowerCase().contains(q) ||
                s.code.toLowerCase().contains(q))
            .toList();
      }
      _selectedIndex = null;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_selectedIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn một trường'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final school = _filtered[_selectedIndex!];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoleSelectionScreen(schoolName: school.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: MeshBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 16, 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Chọn trường',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _applySearch,
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: const Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: 'Nhập từ khoá để tìm kiếm ...',
                      hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 15),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ).animate().fade(duration: 400.ms).slideY(begin: -0.1, end: 0, curve: Curves.easeOutQuart),

              const SizedBox(height: 12),

              // Filter dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.account_balance_rounded,
                          color: Color(0xFF4F46E5),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedFilter,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF334155),
                            ),
                            items: _filterOptions
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedFilter = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fade(duration: 500.ms).slideY(begin: -0.1, end: 0, curve: Curves.easeOutQuart),

              const SizedBox(height: 16),

              // School list
              Expanded(
                child: _filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search_off_rounded,
                                size: 64, color: Color(0xFFCBD5E1)),
                            const SizedBox(height: 16),
                            Text(
                              'Không tìm thấy trường nào',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF64748B),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fade()
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final school = _filtered[i];
                          final isSelected = _selectedIndex == i;
                          return _SchoolTile(
                            school: school,
                            isSelected: isSelected,
                            onTap: () => setState(() => _selectedIndex = i),
                          ).animate().fade(duration: 400.ms, delay: (40 * i).ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
                        },
                      ),
              ),

              // Bottom buttons
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: const Color(0xFFF1F5F9),
                        ),
                        child: Text(
                          'Huỷ',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Continue button
                    Expanded(
                      child: GestureDetector(
                        onTap: _onContinue,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4F46E5).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Tiếp tục',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().slideY(begin: 1.0, end: 0, duration: 600.ms, curve: Curves.easeOutCubic),
            ],
          ),
        ),
      ),
    );
  }
}

// ── School tile ──────────────────────────────────────────────────────────────
class _SchoolTile extends StatelessWidget {
  final SchoolInfo school;
  final bool isSelected;
  final VoidCallback onTap;

  const _SchoolTile({
    required this.school,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4F46E5).withOpacity(0.05)
              : Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5).withOpacity(0.5) : Colors.white,
            width: 2,
          ),
          boxShadow: isSelected ? [] : [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            // Logo placeholder
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _colorForCode(school.code),
                    _colorForCode(school.code).withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _colorForCode(school.code).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Center(
                child: Text(
                  school.code.substring(0, school.code.length > 2 ? 2 : school.code.length),
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    school.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mã đơn vị: ${school.code}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF4F46E5), size: 28)
                  .animate().scale(curve: Curves.elasticOut, duration: 600.ms),
          ],
        ),
      ),
    );
  }

  Color _colorForCode(String code) {
    final colors = [
      const Color(0xFF4F46E5),
      const Color(0xFFE11D48),
      const Color(0xFF059669),
      const Color(0xFFD97706),
      const Color(0xFF7C3AED),
      const Color(0xFF0D9488),
      const Color(0xFF2563EB),
      const Color(0xFFDB2777),
    ];
    return colors[code.hashCode.abs() % colors.length];
  }
}
