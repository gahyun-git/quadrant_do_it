// lib/services/todo_repository.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/todo.dart';
import 'supabase_service.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return TodoRepository(supabase);
});

class TodoRepository {
  final SupabaseClient _supabase;
  TodoRepository(this._supabase);

//   Stream<List<Todo>> streamTodos() {
//     final userId = _supabase.auth.currentUser?.id;
//     if (userId == null) {
//       throw Exception('사용자가 로그인되어 있지 않습니다.');
//     }
//     try {
//       return _supabase
//         .from('todos')
//         .stream(primaryKey: ['id'])
//         .eq('user_id', userId)
//         .order('due_date')
//         .map((rows) => rows.map((e) => Todo.fromJson(e)).toList());
//     } catch (e) {
//       print('Todo 스트림 에러: $e');
//       rethrow;
//     }
//   }

//   Future<void> addTodo(Todo todo) async {
//     await _supabase.from('todos').insert(todo.toJson());
//   }

//   Future<void> updateTodo(Todo todo) async {
//     await _supabase
//       .from('todos')
//       .update(todo.toJson())
//       .eq('id', todo.id);
//   }

//   Future<void> deleteTodo(String id) async {
//     await _supabase.from('todos').delete().eq('id', id);
//   }
// }
// ... existing code ...
  Stream<List<Todo>> streamTodos() {
    // 테스트용 더미 데이터
    return Stream.value([
      Todo(
        id: '1',
        userId: 'test_user',
        title: '중요하고 긴급한 일',
        quadrant: 'do_first',
        dueDate: DateTime.now().add(const Duration(days: 1)),
      ),
      Todo(
        id: '2',
        userId: 'test_user',
        title: '중요하지만 긴급하지 않은 일',
        quadrant: 'schedule',
        dueDate: DateTime.now().add(const Duration(days: 3)),
      ),
      Todo(
        id: '3',
        userId: 'test_user',
        title: '긴급하지만 중요하지 않은 일',
        quadrant: 'delegate',
        dueDate: DateTime.now().add(const Duration(days: 2)),
      ),
      Todo(
        id: '4',
        userId: 'test_user',
        title: '중요하지도 긴급하지도 않은 일',
        quadrant: 'eliminate',
        dueDate: DateTime.now().add(const Duration(days: 5)),
      ),
    ]);
  }

  Future<void> addTodo(Todo todo) async {
    // 테스트용 더미 구현
    print('Todo 추가됨: ${todo.title}');
  }

  Future<void> updateTodo(Todo todo) async {
    // 테스트용 더미 구현
    print('Todo 업데이트됨: ${todo.title}');
  }

  Future<void> deleteTodo(String id) async {
    // 테스트용 더미 구현
    print('Todo 삭제됨: $id');
  }
}
