import 'package:shared_preferences/shared_preferences.dart';

class FeatureManager {
  static final FeatureManager _instance = FeatureManager._internal();
  factory FeatureManager() => _instance;
  FeatureManager._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Lấy danh sách ID của các tính năng trên trang chủ
  List<String>? getHomeFeatureIds(String role) {
    return _prefs?.getStringList('${role}_home_features');
  }

  // Lấy danh sách ID của các tính năng bị ẩn
  List<String>? getOtherFeatureIds(String role) {
    return _prefs?.getStringList('${role}_other_features');
  }

  // Lưu trạng thái
  Future<void> saveFeatures(String role, List<String> homeIds, List<String> otherIds) async {
    if (_prefs == null) return;
    await _prefs!.setStringList('${role}_home_features', homeIds);
    await _prefs!.setStringList('${role}_other_features', otherIds);
  }
}
