import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learning_management_app/core/utils/feature_manager.dart';
import 'widgets/shared/custom_app_bar.dart';

const Color _kBg = Color(0xFFF0F4FF);

/// Represents a feature that can appear on the home screen grid.
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

class CustomizeFeaturesScreen extends StatefulWidget {
  const CustomizeFeaturesScreen({super.key});

  @override
  State<CustomizeFeaturesScreen> createState() =>
      _CustomizeFeaturesScreenState();
}

class _CustomizeFeaturesScreenState extends State<CustomizeFeaturesScreen> {
  late List<FeatureItem> _homeFeatures;
  late List<FeatureItem> _otherFeatures;

  @override
  late List<FeatureItem> _allFeatures;
  late List<FeatureItem> _defaultHomeFeatures;
  late List<FeatureItem> _defaultOtherFeatures;

  @override
  void initState() {
    super.initState();
    _defaultHomeFeatures = [
      FeatureItem(
        icon: Icons.grade_rounded,
        label: 'Xem điểm',
        color: const Color(0xFF1565C0),
        bgColor: const Color(0xFFE3F2FD),
      ),
      FeatureItem(
        icon: Icons.star_rounded,
        label: 'Thành tích',
        color: const Color(0xFFE65100),
        bgColor: const Color(0xFFFFF3E0),
      ),
      FeatureItem(
        icon: Icons.menu_book_rounded,
        label: 'Chương trình khung',
        color: const Color(0xFFC62828),
        bgColor: const Color(0xFFFFEBEE),
      ),
      FeatureItem(
        icon: Icons.monetization_on_outlined,
        label: 'Thanh toán học phí',
        color: const Color(0xFF2E7D32),
        bgColor: const Color(0xFFE8F5E9),
      ),
      FeatureItem(
        icon: Icons.receipt_long_outlined,
        label: 'Phiếu thu tổng hợp',
        color: const Color(0xFF00695C),
        bgColor: const Color(0xFFE0F2F1),
      ),
      FeatureItem(
        icon: Icons.how_to_reg_outlined,
        label: 'Thống kê điểm danh',
        color: const Color(0xFF1565C0),
        bgColor: const Color(0xFFE3F2FD),
      ),
      FeatureItem(
        icon: Icons.calendar_month_outlined,
        label: 'Lịch học/ lịch thi',
        color: const Color(0xFFE65100),
        bgColor: const Color(0xFFFFF3E0),
      ),
    ];

    _defaultOtherFeatures = [
      FeatureItem(
        icon: Icons.emoji_events_outlined,
        label: 'Rèn luyện',
        color: const Color(0xFFC62828),
        bgColor: const Color(0xFFFFEBEE),
        isOnHome: false,
      ),
      FeatureItem(
        icon: Icons.article_outlined,
        label: 'Tin tức',
        color: const Color(0xFF1565C0),
        bgColor: const Color(0xFFE3F2FD),
        isOnHome: false,
      ),
      FeatureItem(
        icon: Icons.poll_outlined,
        label: 'Khảo sát',
        color: const Color(0xFFE65100),
        bgColor: const Color(0xFFFFF3E0),
        isOnHome: false,
      ),
    ];

    _loadFeatures();
  }

  void _loadFeatures() {
    final manager = FeatureManager();
    final savedHome = manager.getHomeFeatureIds('student');
    final savedOther = manager.getOtherFeatureIds('student');

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
      'student',
      _homeFeatures.map((f) => f.label).toList(),
      _otherFeatures.map((f) => f.label).toList(),
    );
    _allFeatures = [
      FeatureItem(icon: Icons.grade_rounded, label: 'Xem điểm', color: const Color(0xFF1565C0), bgColor: const Color(0xFFE3F2FD)),
      FeatureItem(icon: Icons.star_rounded, label: 'Thành tích', color: const Color(0xFFE65100), bgColor: const Color(0xFFFFF3E0)),
      FeatureItem(icon: Icons.menu_book_rounded, label: 'Chương trình khung', color: const Color(0xFFC62828), bgColor: const Color(0xFFFFEBEE)),
      FeatureItem(icon: Icons.monetization_on_outlined, label: 'Thanh toán học phí', color: const Color(0xFF2E7D32), bgColor: const Color(0xFFE8F5E9)),
      FeatureItem(icon: Icons.receipt_long_outlined, label: 'Phiếu thu tổng hợp', color: const Color(0xFF00695C), bgColor: const Color(0xFFE0F2F1)),
      FeatureItem(icon: Icons.how_to_reg_outlined, label: 'Thống kê điểm danh', color: const Color(0xFF1565C0), bgColor: const Color(0xFFE3F2FD)),
      FeatureItem(icon: Icons.calendar_month_outlined, label: 'Lịch học/ lịch thi', color: const Color(0xFFE65100), bgColor: const Color(0xFFFFF3E0)),
      FeatureItem(icon: Icons.emoji_events_outlined, label: 'Rèn luyện', color: const Color(0xFFC62828), bgColor: const Color(0xFFFFEBEE)),
      FeatureItem(icon: Icons.article_outlined, label: 'Tin tức', color: const Color(0xFF1565C0), bgColor: const Color(0xFFE3F2FD)),
      FeatureItem(icon: Icons.poll_outlined, label: 'Khảo sát', color: const Color(0xFFE65100), bgColor: const Color(0xFFFFF3E0)),
      FeatureItem(icon: Icons.chat_rounded, label: 'Trò chuyện', color: const Color(0xFFE11D48), bgColor: const Color(0xFFE11D48).withOpacity(0.1)),
    ];
    _homeFeatures = [];
    _otherFeatures = [];
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHomeLabels = prefs.getStringList('student_home_features');

    setState(() {
      if (savedHomeLabels != null) {
        _homeFeatures = savedHomeLabels.map((label) {
          final item = _allFeatures.firstWhere((f) => f.label == label, orElse: () => _allFeatures.first);
          item.isOnHome = true;
          return item;
        }).toList();
        
        _otherFeatures = _allFeatures.where((f) => !savedHomeLabels.contains(f.label)).toList();
        for (var item in _otherFeatures) {
          item.isOnHome = false;
        }
      } else {
        // Defaults
        final defaultHome = ['Xem điểm', 'Thành tích', 'Chương trình khung', 'Thanh toán học phí', 'Phiếu thu tổng hợp', 'Thống kê điểm danh', 'Lịch học/ lịch thi'];
        _homeFeatures = _allFeatures.where((f) => defaultHome.contains(f.label)).toList();
        for (var item in _homeFeatures) {
          item.isOnHome = true;
        }
        _otherFeatures = _allFeatures.where((f) => !defaultHome.contains(f.label)).toList();
        for (var item in _otherFeatures) {
          item.isOnHome = false;
        }
      }
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final homeLabels = _homeFeatures.map((e) => e.label).toList();
    await prefs.setStringList('student_home_features', homeLabels);
  }

  void _removeFromHome(int index) {
    setState(() {
      final item = _homeFeatures.removeAt(index);
      item.isOnHome = false;
      _otherFeatures.add(item);
      _saveFeatures();
    });
    _savePreferences();
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
    _savePreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          const CustomAppBar(title: 'Tuỳ chỉnh tính năng'),
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
