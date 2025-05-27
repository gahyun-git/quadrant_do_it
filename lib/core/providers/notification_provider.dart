import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'notification_provider.g.dart';

@riverpod
class NotificationNotifier extends _$NotificationNotifier {
  static const String _notificationKey = 'notifications_enabled';

  @override
  bool build() {
    _loadNotificationSetting();
    return true;
  }

  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_notificationKey) ?? true;
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    if (state == enabled) return;
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationKey, enabled);
  }
} 