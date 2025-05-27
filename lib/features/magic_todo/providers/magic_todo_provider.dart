import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../services/ai/magic_todo_service.dart';

part 'magic_todo_provider.g.dart';

@riverpod
class MagicTodoNotifier extends _$MagicTodoNotifier {
  @override
  List<Map<String, dynamic>> build() => [];

  void setTodos(List<Map<String, dynamic>> todos) => state = todos;
  void clear() => state = [];
}

abstract class MagicTodoAIService {
  Future<List<Map<String, dynamic>>> generateTodos(String input);
}

final magicTodoServiceProvider = Provider<MagicTodoAIService>((ref) => MagicTodoService()); 