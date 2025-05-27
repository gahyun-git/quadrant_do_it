import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'language_provider.g.dart';

@riverpod
class LanguageNotifier extends _$LanguageNotifier {
  static const String _languageKey = 'current_language';

  @override
  String build() {
    _loadLanguage();
    return '한국어';
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);
    if (savedLanguage != null) {
      state = savedLanguage;
    }
  }

  Future<void> setLanguage(String language) async {
    if (state == language) return;
    state = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }
} 