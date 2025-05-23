import 'package:flutter/material.dart';
import 'widgets/todo_card.dart';
import 'widgets/quadrant_widget.dart';
import 'matrix_category_provider.dart';
import '../../models/matrix_category.dart';
import 'matrix_category_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MatrixPage extends ConsumerStatefulWidget {
  final MatrixCategory category;
  const MatrixPage({super.key, required this.category});

  @override
  ConsumerState<MatrixPage> createState() => _MatrixPageState();
}

class _MatrixPageState extends ConsumerState<MatrixPage> {
  List<Map<String, dynamic>> _todos = [];
  bool _isDragging = false;
  Map<String, dynamic>? _draggingTodo;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'todos_${widget.category.id}';
    final list = prefs.getStringList(key) ?? [];
    setState(() {
      _todos = list.map((e) => json.decode(e) as Map<String, dynamic>).toList();
    });
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'todos_${widget.category.id}';
    await prefs.setStringList(key, _todos.map((e) => json.encode(e)).toList());
  }

  @override
  void didUpdateWidget(MatrixPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category.id != widget.category.id) {
      _loadTodos();
    }
  }

  void _addTodo(String title, String quadrant, DateTime? date, TimeOfDay? time) {
    setState(() {
      _todos.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title,
        'quadrant': quadrant,
        'isDone': false,
        'date': date?.toIso8601String(),
        'time': time != null ? '${time.hour}:${time.minute}' : null,
      });
    });
    _saveTodos();
  }

  void _editTodo(String id, String newTitle, DateTime? date, TimeOfDay? time) {
    setState(() {
      final idx = _todos.indexWhere((t) => t['id'] == id);
      if (idx != -1) {
        _todos[idx]['title'] = newTitle;
        _todos[idx]['date'] = date?.toIso8601String();
        _todos[idx]['time'] = time != null ? '${time.hour}:${time.minute}' : null;
      }
    });
    _saveTodos();
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((t) => t['id'] == id);
    });
    _saveTodos();
  }

  void _toggleDone(String id, bool? value) {
    setState(() {
      final idx = _todos.indexWhere((t) => t['id'] == id);
      if (idx != -1) _todos[idx]['isDone'] = value ?? false;
    });
    _saveTodos();
  }

  void _moveTodo(String id, String newQuadrant) {
    setState(() {
      final idx = _todos.indexWhere((t) => t['id'] == id);
      if (idx != -1) _todos[idx]['quadrant'] = newQuadrant;
    });
    _saveTodos();
  }

  final List<Map<String, dynamic>> quadrants = const [
    {'label': '중요 & 긴급', 'key': 'do_first', 'color': Color(0xFFEF4444)},
    {'label': '중요 & 비긴급', 'key': 'schedule', 'color': Color(0xFF3B82F6)},
    {'label': '비중요 & 긴급', 'key': 'delegate', 'color': Color(0xFFF59E42)},
    {'label': '비중요 & 비긴급', 'key': 'eliminate', 'color': Color(0xFF10B981)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () async {
            // 매트릭스 선택 다이얼로그를 showModalBottomSheet로 변경
            final selected = await showModalBottomSheet<String>(
              context: context,
              builder: (ctx) => _MatrixSelectBottomSheet(selectedId: widget.category.id),
            );
            if (selected != null && selected != widget.category.id) {
              ref.read(selectedMatrixCategoryIdProvider.notifier).state = selected;
              // 화면 pop 없음 (상태만 변경)
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: '카테고리 관리',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const MatrixCategoryListPage(),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: QuadrantWidget(
                          quadrant: quadrants[0],
                          todos: _todos.where((t) => t['quadrant'] == quadrants[0]['key']).toList(),
                          onAdd: (title, date, time) => _addTodo(title, quadrants[0]['key'], date, time),
                          onEdit: _editTodo,
                          onDelete: _deleteTodo,
                          onToggle: _toggleDone,
                          onMove: _moveTodo,
                          onDragStarted: (todo) => setState(() { _isDragging = true; _draggingTodo = todo; }),
                          onDragEnded: () => setState(() { _isDragging = false; _draggingTodo = null; }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuadrantWidget(
                          quadrant: quadrants[1],
                          todos: _todos.where((t) => t['quadrant'] == quadrants[1]['key']).toList(),
                          onAdd: (title, date, time) => _addTodo(title, quadrants[1]['key'], date, time),
                          onEdit: _editTodo,
                          onDelete: _deleteTodo,
                          onToggle: _toggleDone,
                          onMove: _moveTodo,
                          onDragStarted: (todo) => setState(() { _isDragging = true; _draggingTodo = todo; }),
                          onDragEnded: () => setState(() { _isDragging = false; _draggingTodo = null; }),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: QuadrantWidget(
                          quadrant: quadrants[2],
                          todos: _todos.where((t) => t['quadrant'] == quadrants[2]['key']).toList(),
                          onAdd: (title, date, time) => _addTodo(title, quadrants[2]['key'], date, time),
                          onEdit: _editTodo,
                          onDelete: _deleteTodo,
                          onToggle: _toggleDone,
                          onMove: _moveTodo,
                          onDragStarted: (todo) => setState(() { _isDragging = true; _draggingTodo = todo; }),
                          onDragEnded: () => setState(() { _isDragging = false; _draggingTodo = null; }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuadrantWidget(
                          quadrant: quadrants[3],
                          todos: _todos.where((t) => t['quadrant'] == quadrants[3]['key']).toList(),
                          onAdd: (title, date, time) => _addTodo(title, quadrants[3]['key'], date, time),
                          onEdit: _editTodo,
                          onDelete: _deleteTodo,
                          onToggle: _toggleDone,
                          onMove: _moveTodo,
                          onDragStarted: (todo) => setState(() { _isDragging = true; _draggingTodo = todo; }),
                          onDragEnded: () => setState(() { _isDragging = false; _draggingTodo = null; }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isDragging)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60), // 네비게이션바 위
                child: DragTarget<Map<String, dynamic>>(
                  onWillAccept: (data) => true,
                  onAccept: (data) {
                    _deleteTodo(data['id']);
                    setState(() { _isDragging = false; _draggingTodo = null; });
                  },
                  builder: (context, candidate, rejected) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: candidate.isNotEmpty ? Colors.red : Colors.grey.shade300,
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (candidate.isNotEmpty)
                            BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 16),
                        ],
                      ),
                      child: Icon(Icons.delete, color: candidate.isNotEmpty ? Colors.white : Colors.black54, size: 40),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MatrixSelectBottomSheet extends ConsumerWidget {
  final String selectedId;
  const _MatrixSelectBottomSheet({required this.selectedId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(matrixCategoryListProvider);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          const Text('매트릭스 선택', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ...categories.map((cat) => ListTile(
            leading: cat.id == selectedId ? const Icon(Icons.check, color: Colors.blue) : null,
            title: Text(cat.name, style: TextStyle(fontWeight: cat.id == selectedId ? FontWeight.bold : FontWeight.normal)),
            onTap: () {
              Navigator.of(context).pop(cat.id);
            },
          )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}