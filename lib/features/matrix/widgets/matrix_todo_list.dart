import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../services/widget_service.dart';

class MatrixTodoList extends StatefulWidget {
  final String quadrant;
  final String title;
  final Color color;

  const MatrixTodoList({
    super.key,
    required this.quadrant,
    required this.title,
    required this.color,
  });

  @override
  State<MatrixTodoList> createState() => _MatrixTodoListState();
}

class _MatrixTodoListState extends State<MatrixTodoList> {
  List<Map<String, dynamic>> _todos = [];

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getString('matrix_categories');
    if (categoriesJson != null) {
      final List<dynamic> categories = json.decode(categoriesJson);
      String categoryId = categories.isNotEmpty ? categories.first['id'] : 'default';
      final key = 'todos_$categoryId';
      final list = prefs.getStringList(key) ?? [];
      setState(() {
        _todos = list
            .map((e) => json.decode(e) as Map<String, dynamic>)
            .where((todo) => todo['quadrant'] == widget.quadrant)
            .toList();
      });
    }
  }

  Future<void> _showAddTodoDialog() async {
    final titleController = TextEditingController();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: Text('${widget.title} 할일 추가'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: '할일을 입력하세요',
                ),
                autofocus: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {
              'title': titleController.text,
            }),
            child: const Text('추가'),
          ),
        ],
      ),
    );

    if (result != null && result['title']!.trim().isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = prefs.getString('matrix_categories');
      if (categoriesJson != null) {
        final List<dynamic> categories = json.decode(categoriesJson);
        String categoryId = categories.isNotEmpty ? categories.first['id'] : 'default';
        final key = 'todos_$categoryId';
        final list = prefs.getStringList(key) ?? [];
        final todo = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': result['title']!.trim(),
          'quadrant': widget.quadrant,
          'isDone': false,
          'date': result['date'] ?? DateTime.now().toIso8601String(),
        };
        list.add(json.encode(todo));
        await prefs.setStringList(key, list);
        _loadTodos();
      }
    }
  }

  Future<void> _showEditTodoDialog(Map<String, dynamic> todo) async {
    final titleController = TextEditingController(text: todo['title']);
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: const Text('할일 수정'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: '할일을 입력하세요',
                ),
                autofocus: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {
              'title': titleController.text,
            }),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (result != null && result['title']!.trim().isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = prefs.getString('matrix_categories');
      if (categoriesJson != null) {
        final List<dynamic> categories = json.decode(categoriesJson);
        String categoryId = categories.isNotEmpty ? categories.first['id'] : 'default';
        final key = 'todos_$categoryId';
        final list = prefs.getStringList(key) ?? [];
        final idx = list.indexWhere((e) => json.decode(e)['id'] == todo['id']);
        if (idx != -1) {
          final updatedTodo = {
            ...todo,
            'title': result['title']!.trim(),
          };
          list[idx] = json.encode(updatedTodo);
          await prefs.setStringList(key, list);
          _loadTodos();
        }
      }
    }
  }

  Future<void> _deleteTodo(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getString('matrix_categories');
    if (categoriesJson != null) {
      final List<dynamic> categories = json.decode(categoriesJson);
      String categoryId = categories.isNotEmpty ? categories.first['id'] : 'default';
      final key = 'todos_$categoryId';
      final list = prefs.getStringList(key) ?? [];
      list.removeWhere((e) => json.decode(e)['id'] == id);
      await prefs.setStringList(key, list);
      await WidgetService.updateTodayTodo(
        list.isNotEmpty ? json.decode(list.last)['title'] : '오늘의 할일 없음',
        list.isNotEmpty ? (json.decode(list.last)['reason'] ?? '') : '매트릭스 요약 없음',
      );
      _loadTodos();
    }
  }

  Future<void> _toggleTodo(Map<String, dynamic> todo) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getString('matrix_categories');
    if (categoriesJson != null) {
      final List<dynamic> categories = json.decode(categoriesJson);
      String categoryId = categories.isNotEmpty ? categories.first['id'] : 'default';
      final key = 'todos_$categoryId';
      final list = prefs.getStringList(key) ?? [];
      final idx = list.indexWhere((e) => json.decode(e)['id'] == todo['id']);
      if (idx != -1) {
        final updatedTodo = {
          ...todo,
          'isDone': !todo['isDone'],
        };
        list[idx] = json.encode(updatedTodo);
        await prefs.setStringList(key, list);
        await WidgetService.updateTodayTodo(updatedTodo['title'], updatedTodo['reason'] ?? '');
        _loadTodos();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onLongPress: () {
            HapticFeedback.mediumImpact();
            print('롱프레스 감지됨');
            _showAddTodoDialog();
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            color: widget.color.withOpacity(0.1),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: widget.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_todos.length}개',
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _todos.length,
            itemBuilder: (context, index) {
              final todo = _todos[index];
              return Dismissible(
                key: ValueKey(todo['id']),
                direction: DismissDirection.horizontal,
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    // 오른쪽으로 스와이프 - 수정
                    await _showEditTodoDialog(todo);
                    return false;
                  } else {
                    // 왼쪽으로 스와이프 - 삭제
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('삭제 확인'),
                        content: Text('정말 "${todo['title']}" 할일을 삭제할까요?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('취소'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('삭제'),
                          ),
                        ],
                      ),
                    ) ?? false;
                  }
                },
                onDismissed: (direction) {
                  if (direction == DismissDirection.endToStart) {
                    _deleteTodo(todo['id']);
                  }
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.blue,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Icon(Icons.edit, color: Colors.white),
                ),
                child: ListTile(
                  leading: Checkbox(
                    value: todo['isDone'] ?? false,
                    onChanged: (_) => _toggleTodo(todo),
                    activeColor: widget.color,
                  ),
                  title: Text(
                    todo['title'],
                    style: TextStyle(
                      decoration: todo['isDone'] == true ? TextDecoration.lineThrough : null,
                      color: todo['isDone'] == true ? Colors.grey : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 