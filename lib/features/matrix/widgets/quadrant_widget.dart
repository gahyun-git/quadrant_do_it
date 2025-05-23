import 'package:flutter/material.dart';
import 'todo_card.dart';
import 'todo_dialog.dart';

class QuadrantWidget extends StatelessWidget {
  final Map<String, dynamic> quadrant;
  final List<Map<String, dynamic>> todos;
  final Function(String, DateTime?, TimeOfDay?) onAdd;
  final Function(String, String, DateTime?, TimeOfDay?) onEdit;
  final Function(String) onDelete;
  final Function(String, bool?) onToggle;
  final Function(String, String) onMove;
  final Function(Map<String, dynamic>)? onDragStarted;
  final VoidCallback? onDragEnded;

  const QuadrantWidget({
    super.key,
    required this.quadrant,
    required this.todos,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
    required this.onMove,
    this.onDragStarted,
    this.onDragEnded,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) => details.data['quadrant'] != quadrant['key'],
      onAcceptWithDetails: (details) {
        onMove(details.data['id'], quadrant['key']);
      },
      builder: (context, candidate, rejected) => Container(
        decoration: BoxDecoration(
          color: (quadrant['color'] as Color).withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (quadrant['color'] as Color).withAlpha(candidate.isNotEmpty ? 179 : 77),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 24,
                  decoration: BoxDecoration(
                    color: quadrant['color'] as Color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  quadrant['label'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: quadrant['color'] as Color,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () => _showAddDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: todos.isEmpty
                  ? Center(
                      child: Text(
                        '할 일이 없습니다',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    )
                  : ListView(
                      children: todos.map((t) => _buildTodoItem(context, _parseTodo(t))).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _parseTodo(Map<String, dynamic> t) {
    return {
      ...t,
      'date': t['date'] is DateTime
          ? t['date']
          : (t['date'] is String && t['date'] != '' ? DateTime.tryParse(t['date']) : null),
      'time': t['time'] is TimeOfDay
          ? t['time']
          : (t['time'] is String && t['time'].contains(':')
              ? TimeOfDay(
                  hour: int.tryParse(t['time'].split(':')[0]) ?? 0,
                  minute: int.tryParse(t['time'].split(':')[1]) ?? 0,
                )
              : null),
    };
  }

  Widget _buildTodoItem(BuildContext context, Map<String, dynamic> todo) {
    return LongPressDraggable<Map<String, dynamic>>(
      data: todo,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 48,
          child: TodoCard(
            title: todo['title'] as String,
            isDone: todo['isDone'] as bool,
            date: todo['date'] as DateTime?,
            time: todo['time'] as TimeOfDay?,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: TodoCard(
          title: todo['title'] as String,
          isDone: todo['isDone'] as bool,
          date: todo['date'] as DateTime?,
          time: todo['time'] as TimeOfDay?,
        ),
      ),
      child: TodoCard(
        title: todo['title'] as String,
        isDone: todo['isDone'] as bool,
        date: todo['date'] as DateTime?,
        time: todo['time'] as TimeOfDay?,
        onChanged: (val) => onToggle(todo['id'], val),
        onEdit: () => _showEditDialog(context, todo),
        onDelete: () => onDelete(todo['id']),
      ),
      onDragStarted: () => onDragStarted?.call(todo),
      onDragEnd: (_) => onDragEnded?.call(),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => TodoDialog(
        title: '${quadrant['label']}에 할 일 추가',
        initialTitle: '',
        initialDate: null,
        initialTime: null,
      ),
    );

    if (result != null && result['title']!.trim().isNotEmpty) {
      onAdd(
        result['title']!.trim(),
        result['date'] as DateTime?,
        result['time'] as TimeOfDay?,
      );
    }
  }

  Future<void> _showEditDialog(BuildContext context, Map<String, dynamic> todo) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => TodoDialog(
        title: '할 일 수정',
        initialTitle: todo['title'] as String,
        initialDate: todo['date'] as DateTime?,
        initialTime: todo['time'] as TimeOfDay?,
      ),
    );

    if (result != null && result['title']!.trim().isNotEmpty) {
      onEdit(
        todo['id'],
        result['title']!.trim(),
        result['date'] as DateTime?,
        result['time'] as TimeOfDay?,
      );
    }
  }
} 