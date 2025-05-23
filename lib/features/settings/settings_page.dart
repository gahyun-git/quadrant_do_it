import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dummyUser = {'email': 'test@email.com', 'name': '홍길동'};
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('설정/개인정보')),
      body: ListView(
        children: [
          ListTile(title: const Text('프로필'), subtitle: Text('${dummyUser['name']} / ${dummyUser['email']}')),
          const Divider(),
          SwitchListTile(
            title: const Text('다크모드'),
            value: isDark,
            onChanged: (val) => ref.read(themeModeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light,
          ),
          const ListTile(title: Text('언어')), // 실제 선택은 추후
          const ListTile(title: Text('알림 설정')), // 실제 토글은 추후
          const ListTile(title: Text('구독 관리')), // paywall로 이동
          const ListTile(title: Text('앱 정보')),
        ],
      ),
    );
  }
} 