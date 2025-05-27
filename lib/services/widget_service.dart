import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const String _widgetName = 'QuadrantDoItWidgetProvider'; // Android
  static const String _iOSWidgetName = 'QuadrantDoItWidget'; // iOS

  static void init() {
    HomeWidget.registerInteractivityCallback(interactivityCallback);
  }

  static Future<void> interactivityCallback(Uri? uri) async {
    if (uri == null) return;
    print('위젯 인터랙션 업데이트: $uri');
  }

  /// 오늘의 할일과 매트릭스 요약을 위젯에 저장 및 새로고침
  static Future<void> updateTodayTodo(String todo, String summary) async {
    try {
      await HomeWidget.saveWidgetData<String>('today_todo', todo);
      await HomeWidget.saveWidgetData<String>('matrix_summary', summary);
      await HomeWidget.updateWidget(
        name: _widgetName,
        iOSName: _iOSWidgetName,
      );
    } catch (e) {
      print('위젯 업데이트 실패: $e');
    }
  }

  /// 매트릭스 요약(예: 각 사분면별 개수 등)을 위젯에 저장
  static Future<void> updateMatrixSummary(Map<String, int> summary) async {
    try {
      await HomeWidget.saveWidgetData<String>('matrix_summary', summary.toString());
      await HomeWidget.updateWidget(
        name: _widgetName,
        iOSName: _iOSWidgetName,
      );
    } catch (e) {
      print('위젯 업데이트 실패: $e');
    }
  }
}