import 'package:go_router/go_router.dart';
import 'package:quadrant_do_it/models/matrix_category.dart';
import '../../features/auth/auth_page.dart';
import '../../features/matrix/matrix_page.dart';
import '../../features/timer/timer_page.dart';
import '../../features/calendar/calendar_page.dart';
import '../../features/magic_todo/magic_todo_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/paywall/paywall_page.dart';
import '../../features/matrix/matrix_category_list_page.dart';
// TODO: 각 페이지 import

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AuthPage()),
    GoRoute(path: '/matrix', builder: (context, state) {
      final category = state.extra as MatrixCategory?;
      if (category != null) {
        return MatrixPage(category: category);
      } else {
        return const MatrixCategoryListPage();
      }
    }),
    GoRoute(path: '/timer', builder: (context, state) => const TimerPage()),
    GoRoute(path: '/calendar', builder: (context, state) => const CalendarPage()),
    GoRoute(path: '/magic', builder: (context, state) => const MagicTodoPage()),
    GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),
    GoRoute(path: '/paywall', builder: (context, state) => const PaywallPage()),
  ],
);