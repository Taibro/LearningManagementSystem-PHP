import 'package:flutter/material.dart';
import 'package:learning_management_app/core/utils/feature_manager.dart';
import 'widgets/shared/lecturer_custom_app_bar.dart';

const Color _kBg = Color(0xFFF8F9FA);

class FeatureItem {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  bool isOnHome;

  FeatureItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    this.isOnHome = true,
  });
}

class LecturerCustomizeFeaturesScreen extends StatefulWidget {
  const LecturerCustomizeFeaturesScreen({super.key});

  @override
  State<LecturerCustomizeFeaturesScreen> createState() =>
      _LecturerCustomizeFeaturesScreenState();
}

class _LecturerCustomizeFeaturesScreenState
    extends State<LecturerCustomizeFeaturesScreen> {
  late List<FeatureItem> _homeFeatures;
  late List<FeatureItem> _otherFeatures;
  late List<FeatureItem> _defaultHomeFeatures;
  late List<FeatureItem> _defaultOtherFeatures;

  @override
  void initState() {
    super.initState();
    _defaultHomeFeatures = [
      FeatureItem(
        icon: Icons.how_to_reg_rounded,
        label: 'Điểm danh',
        color: const Color(0xFF6B4FA0),
        bgColor: const Color(0xFF6B4FA0).withValues(alpha: 0.1),
      ),
      FeatureItem(
        icon: Icons.qr_code_2_rounded,
        label: 'QR Code',
        color: const Color(0xFF10B981),
        bgColor: const Color(0xFF10B981).withValues(alpha: 0.1),
      ),
      FeatureItem(
        icon: Icons.grade_rounded,
        label: 'Kết quả học tập',
        color: const Color(0xFF3B82F6),
        bgColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
      ),
      FeatureItem(
        icon: Icons.bar_chart_rounded,
        label: 'Thống kê giảng dạy',
        color: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFF59E0B).withValues(alpha: 0.1),
      ),
      FeatureItem(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Thông tin lương',
        color: const Color(0xFF2E7D32),
        bgColor: const Color(0xFF2E7D32).withValues(alpha: 0.1),
      ),
      FeatureItem(
        icon: Icons.library_books_rounded,
        label: 'Tài liệu bài giảng',
        color: const Color(0xFF5C6BC0),
        bgColor: const Color(0xFF5C6BC0).withValues(alpha: 0.1),
      ),
      FeatureItem(
        icon: Icons.edit_document,
        label: 'Đề xuất lịch dạy',
        color: const Color(0xFFEC4899),
        bgColor: const Color(0xFFEC4899).withValues(alpha: 0.1),
      ),
    ];

    _defaultOtherFeatures = [
      FeatureItem(
        icon: Icons.badge_rounded,
        label: 'Hồ sơ cá nhân',
        color: const Color(0xFF5C6BC0),
        bgColor: const Color(0xFF5C6BC0).withValues(alpha: 0.1),
        isOnHome: false,
      ),
      FeatureItem(
        icon: Icons.poll_rounded,
        label: 'Khảo sát',
        color: const Color(0xFFE85D75),
        bgColor: const Color(0xFFE85D75).withValues(alpha: 0.1),
        isOnHome: false,
      ),
      FeatureItem(
        icon: Icons.calendar_month_rounded,
        label: 'Lịch dạy',
        color: const Color(0xFFE65100),
        bgColor: const Color(0xFFE65100).withValues(alpha: 0.1),
        isOnHome: false,
      ),
    ];

    _loadFeatures();
  }

  void _loadFeatures() {
    final manager = FeatureManager();
    final savedHome = manager.getHomeFeatureIds('lecturer');
    final savedOther = manager.getOtherFeatureIds('lecturer');

    if (savedHome == null) {
      _homeFeatures = List.from(_defaultHomeFeatures);
      _otherFeatures = List.from(_defaultOtherFeatures);
    } else {
      final allDefaults = [..._defaultHomeFeatures, ..._defaultOtherFeatures];
      _homeFeatures = savedHome
          .map((label) => allDefaults.firstWhere((f) => f.label == label, orElse: () => allDefaults.first))
          .toList();
      for (var f in _homeFeatures) {
        f.isOnHome = true;
      }

      _otherFeatures = savedOther
          ?.map((label) => allDefaults.firstWhere((f) => f.label == label, orElse: () => allDefaults.first))
          .toList() ?? [];
      for (var f in _otherFeatures) {
        f.isOnHome = false;
      }
    }
  }

  void _saveFeatures() {
    final manager = FeatureManager();
    manager.saveFeatures(
      'lecturer',
      _homeFeatures.map((f) => f.label).toList(),
      _otherFeatures.map((f) => f.label).toList(),
    );
  }

  void _removeFromHome(int index) {
    setState(() {
      final item = _homeFeatures.removeAt(index);
      item.isOnHome = false;
      _otherFeatures.add(item);
      _saveFeatures();
    });
  }

  void _addToHome(int index) {
    setState(() {
      final item = _otherFeatures.removeAt(index);
      item.isOnHome = true;
      _homeFeatures.add(item);
      _saveFeatures();
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final dividerIndex = _homeFeatures.length;

      // Cannot reorder the divider itself
      if (oldIndex == dividerIndex || newIndex == dividerIndex) return;

      final isFromHome = oldIndex < dividerIndex;
      final isToHome = newIndex <= dividerIndex;

      FeatureItem item;
      if (isFromHome) {
        item = _homeFeatures.removeAt(oldIndex);
      } else {
        item = _otherFeatures.removeAt(oldIndex - dividerIndex - 1);
      }

      if (isToHome) {
        item.isOnHome = true;
        _homeFeatures.insert(newIndex.clamp(0, _homeFeatures.length), item);
      } else {
        item.isOnHome = false;
        final insertIndex = newIndex - _homeFeatures.length - (isFromHome ? 0 : 1);
        _otherFeatures.insert(insertIndex.clamp(0, _otherFeatures.length), item);
      }
      _saveFeatures();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          const LecturerCustomAppBar(title: 'Tuỳ chỉnh tính năng'),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Tính năng trang chủ (Kéo thả để sắp xếp)'),
                  _buildCombinedList(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF757575),
        ),
      ),
    );
  }

  Widget _buildCombinedList() {
    final List<dynamic> combinedList = [
      ..._homeFeatures,
      'DIVIDER',
      ..._otherFeatures,
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Material(
                elevation: 4,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: child,
              );
            },
            child: child,
          );
        },
        itemCount: combinedList.length,
        onReorder: _onReorder,
        itemBuilder: (context, index) {
          final item = combinedList[index];

          if (item == 'DIVIDER') {
            return Container(
              key: const ValueKey('DIVIDER'),
              color: _kBg,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
              child: const Text(
                'Tính năng khác',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF757575),
                ),
              ),
            );
          }

          final feature = item as FeatureItem;
          final isHome = feature.isOnHome;
          
          int localIndex = isHome 
              ? _homeFeatures.indexOf(feature) 
              : _otherFeatures.indexOf(feature);

          return Column(
            key: ValueKey(feature.label),
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    // Button (+ or -)
                    GestureDetector(
                      onTap: () => isHome ? _removeFromHome(localIndex) : _addToHome(localIndex),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isHome ? const Color(0xFFE53935) : const Color(0xFF43A047),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isHome ? Icons.remove : Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Icon
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: feature.bgColor,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(feature.icon, color: feature.color, size: 20),
                    ),
                    const SizedBox(width: 14),
                    // Label
                    Expanded(
                      child: Text(
                        feature.label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ),
                    // Drag handle
                    ReorderableDragStartListener(
                      index: index,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.drag_handle,
                          color: Color(0xFFBDBDBD),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if ((isHome && localIndex < _homeFeatures.length - 1) || 
                  (!isHome && localIndex < _otherFeatures.length - 1))
                const Divider(height: 1, indent: 54, color: Color(0xFFF0F0F0)),
            ],
          );
        },
      ),
    );
  }
}
