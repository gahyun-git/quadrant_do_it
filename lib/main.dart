// lib/main.dart
// Flutter + Riverpod + Supabase 초기화 및 메인 앱 스캐폴드

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/settings/settings_provider.dart';

import 'features/auth/auth_page.dart';
import 'features/matrix/matrix_page.dart';
import 'features/timer/timer_page.dart';
import 'features/calendar/calendar_page.dart';
import 'features/magic_todo/magic_todo_page.dart';
import 'features/settings/settings_page.dart';
import 'features/matrix/matrix_category_provider.dart';
import 'features/matrix/matrix_category_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/matrix_category.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANNON_KEY']!,
    );
  } catch (e, s) {
    print('초기화 에러: $e\n$s');
  }
  runApp(const ProviderScope(child: QuadrantDoItApp()));
}

class QuadrantDoItApp extends ConsumerWidget {
  const QuadrantDoItApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'Quadrant Do It',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
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

class _MainNavScreenState extends ConsumerState<MainNavScreen> {
  bool _loading = true;
  String? _lastMatrixId;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadLastMatrix();
  }

  Future<void> _loadLastMatrix() async {
    final prefs = await SharedPreferences.getInstance();
    final lastId = prefs.getString('last_matrix_category_id');
    setState(() {
      _lastMatrixId = lastId;
      _loading = false;
    });
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
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '매트릭스'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: '타이머'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '캘린더'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Magic'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }
}
