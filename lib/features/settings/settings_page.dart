import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../l10n/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final currentLanguage = ref.watch(languageNotifierProvider);
    final notificationsEnabled = ref.watch(notificationNotifierProvider);
    final loc = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: ListView(
        children: [
          // 프로필(이름/이메일)
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(loc.profile),
            subtitle: const Text('honggildong@email.com'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(loc.editProfile),
                    content: Text('프로필 수정 기능은 추후 지원됩니다.'),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.confirm))],
                  ),
                );
              },
            ),
          ),
          const Divider(),
          // 언어 선택
          ListTile(
            title: Text(loc.language),
            trailing: DropdownButton<String>(
              value: currentLanguage,
              items: const [
                DropdownMenuItem(value: '한국어', child: Text('한국어')),
                DropdownMenuItem(value: 'English', child: Text('English')),
                DropdownMenuItem(value: '日本語', child: Text('日本語')),
              ],
              onChanged: (String? newLanguage) {
                if (newLanguage != null) {
                  ref.read(languageNotifierProvider.notifier).setLanguage(newLanguage);
                }
              },
            ),
          ),
          const Divider(),
          // 알림 설정
          SwitchListTile(
            title: Text(loc.receiveNotification),
            value: notificationsEnabled,
            onChanged: (v) {
              ref.read(notificationNotifierProvider.notifier).setNotificationEnabled(v);
            },
          ),
          const Divider(),
          // 구독 관리
          ListTile(
            title: Text(loc.subscription),
            trailing: IconButton(
              icon: const Icon(Icons.subscriptions),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(loc.subscription),
                    content: Text('구독 관리 기능은 추후 지원됩니다.'),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.confirm))],
                  ),
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(loc.theme),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              items: [
                DropdownMenuItem(value: ThemeMode.system, child: Text('시스템')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('라이트')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('다크')),
              ],
              onChanged: (ThemeMode? newMode) {
                if (newMode != null) {
                  ref.read(themeNotifierProvider.notifier).setThemeMode(newMode);
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(loc.resetData),
            trailing: IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(loc.resetData),
                    content: Text(loc.resetConfirm),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.cancel)),
                      ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(loc.confirm)),
                    ],
                  ),
                );
                if (ok == true) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(loc.resetData),
                        content: Text(loc.resetComplete),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.confirm))],
                      ),
                    );
                  }
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(loc.about),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(loc.about),
                    content: Text('이 앱은 Eisenhower Matrix 기반의 할일/일정/AI 매직투두/구독/설정 등 다양한 기능을 제공합니다.'),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.confirm))],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 