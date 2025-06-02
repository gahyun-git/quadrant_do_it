// lib/main.dart
// Flutter + Riverpod + Supabase 초기화 및 메인 앱 스캐폴드

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/language_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'models/matrix_category.dart';
import 'package:home_widget/home_widget.dart';
import 'core/widgets/animated_fab_menu.dart';

import 'features/auth/auth_page.dart';
import 'features/matrix/matrix_page.dart';
import 'features/timer/timer_page.dart';
import 'features/calendar/calendar_page.dart';
import 'features/magic_todo/magic_todo_page.dart';
import 'features/settings/settings_page.dart';
import 'features/matrix/matrix_category_provider.dart';
import 'features/matrix/matrix_category_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANNON_KEY']!,
  );
    await HomeWidget.setAppGroupId('group.com.example.quadrantDoIt');
  } catch (e, s) {
    print('초기화 에러: $e\n$s');
  }
  runApp(const ProviderScope(child: QuadrantDoItApp()));
}

class QuadrantDoItApp extends ConsumerWidget {
  const QuadrantDoItApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final language = ref.watch(languageNotifierProvider);
    Locale? locale;
    if (language == 'English') {
      locale = const Locale('en');
    } else if (language == '日本語') {
      locale = const Locale('ja');
    } else {
      locale = const Locale('ko');
    }
    return MaterialApp(
      title: 'Quadrant Do It',
      themeMode: themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.appDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko'),
        Locale('en'),
        Locale('ja'),
      ],
      home: const MainNavScreen(),
    );
  }
}

class AuthGate extends HookConsumerWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = Supabase.instance.client.auth.currentSession;
    // Listen to auth state changes
    useEffect(() {
      final sub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        if (data.session != null) {
          // rebuild on login
          ref.invalidate(_authStateProvider);
        }
      });
      return sub.cancel;
    }, []);

    // return session == null ? const AuthPage() : const MainScreen();
    return const MatrixCategoryListPage();
  }
}

// dummy provider to trigger rebuild
final _authStateProvider = Provider<void>((ref) {});

class MainNavScreen extends ConsumerStatefulWidget {
  const MainNavScreen({super.key});
  @override
  ConsumerState<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends ConsumerState<MainNavScreen> with SingleTickerProviderStateMixin {
  bool _loading = true;
  int _currentIndex = 0;
  late final PageController _pageController;
  bool _isFabMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadLastMatrix();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadLastMatrix() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loading = false;
    });
  }

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
      _isFabMenuOpen = false;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final categories = ref.watch(matrixCategoryListProvider);
    final selectedId = ref.watch(selectedMatrixCategoryIdProvider);
    MatrixCategory? selectedCat;
    if (categories.isNotEmpty && selectedId != null) {
      selectedCat = categories.firstWhere(
        (c) => c.id == selectedId,
        orElse: () => categories.first,
      );
    } else if (categories.isNotEmpty) {
      selectedCat = categories.first;
    }
    final pages = [
      (selectedCat != null)
          ? MatrixPage(category: selectedCat)
          : const MatrixCategoryListPage(),
      const TimerPage(),
      const CalendarPage(),
      const MagicTodoPage(),
      const SettingsPage(),
    ];

    final fabItems = [
      FabMenuItem(
        heroTag: 'matrix',
        icon: const Icon(Icons.dashboard),
        onPressed: () => _navigateToPage(0),
      ),
      FabMenuItem(
        heroTag: 'timer',
        icon: const Icon(Icons.timer),
        onPressed: () => _navigateToPage(1),
      ),
      FabMenuItem(
        heroTag: 'calendar',
        icon: const Icon(Icons.calendar_today),
        onPressed: () => _navigateToPage(2),
      ),
      FabMenuItem(
        heroTag: 'magic',
        icon: const Icon(Icons.auto_awesome),
        onPressed: () => _navigateToPage(3),
      ),
      FabMenuItem(
        heroTag: 'settings',
        icon: const Icon(Icons.settings),
        onPressed: () => _navigateToPage(4),
      ),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: pages,
      ),
      floatingActionButton: AnimatedFabMenu(
        isOpen: _isFabMenuOpen,
        onToggle: () {
          setState(() {
            _isFabMenuOpen = !_isFabMenuOpen;
          });
        },
        items: fabItems,
        onItemSelected: () {
          setState(() {
            _isFabMenuOpen = false;
          });
        },
      ),
    );
  }
}
