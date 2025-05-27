import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../auth/widgets/social_login_button.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _userName = '';
  String _userEmail = '';
  String _userPhoto = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? '';
      _userEmail = prefs.getString('user_email') ?? '';
      _userPhoto = prefs.getString('user_photo') ?? '';
    });
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);
    final photoController = TextEditingController(text: _userPhoto);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.editProfile),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: '이름',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: photoController,
              decoration: InputDecoration(
                labelText: '프로필 사진 URL',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {
              'name': nameController.text,
              'email': emailController.text,
              'photo': photoController.text,
            }),
            child: Text(AppLocalizations.of(context)!.add),
          ),
        ],
      ),
    );

    if (result != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', result['name']!);
      await prefs.setString('user_email', result['email']!);
      await prefs.setString('user_photo', result['photo']!);
      await _loadUserProfile();
    }
  }

  Future<void> _resetData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.resetData),
        content: Text(AppLocalizations.of(context)!.resetConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.resetComplete)),
        );
      }
    }
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.subscription),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('구독 상태: 무료 플랜'),
            SizedBox(height: 8),
            Text('프리미엄 기능: 곧 출시 예정'),
            SizedBox(height: 8),
            Text('구독 관리 기능은 추후 제공됩니다.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: _userPhoto.isNotEmpty ? NetworkImage(_userPhoto) : null,
                child: _userPhoto.isEmpty ? const Icon(Icons.person) : null,
              ),
              title: Text(_userName.isNotEmpty ? _userName : '이름 없음'),
              subtitle: Text(_userEmail.isNotEmpty ? _userEmail : '이메일 없음'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editProfile,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: Text(loc.theme),
                  trailing: DropdownButton<ThemeMode>(
                    value: Theme.of(context).brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
                    items: [
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('라이트'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('다크'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('시스템'),
                      ),
                    ],
                    onChanged: (ThemeMode? mode) {
                      if (mode != null) {
                        ref.read(themeNotifierProvider.notifier).setThemeMode(mode);
                      }
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.subscriptions),
                  title: Text(loc.subscription),
                  onTap: _showSubscriptionDialog,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: Text(loc.resetData),
                  onTap: _resetData,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(loc.profile),
                  subtitle: const Text('로그인하여 데이터를 동기화하세요'),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SocialLoginButton(type: SocialType.google),
                      const SizedBox(height: 8),
                      SocialLoginButton(type: SocialType.apple),
                      const SizedBox(height: 8),
                      SocialLoginButton(type: SocialType.kakao),
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
} 