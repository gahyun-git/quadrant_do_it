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
      onWillAccept: (data) => data != null && data['quadrant'] != quadrant['key'],
      onAccept: (data) => onMove(data['id'], quadrant['key']),
      builder: (context, candidate, rejected) {
        final isActive = candidate.isNotEmpty;
        return Container(
          decoration: BoxDecoration(
            color: quadrant['color'].withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? quadrant['color'] : quadrant['color'].withOpacity(0.3),
              width: isActive ? 3 : 1.5,
            ),
          ),
          margin: const EdgeInsets.all(2),
          child: Column(
            children: [
              GestureDetector(
                onLongPress: () => _showAddDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Text(
                        quadrant['label'],
                        style: TextStyle(
                          color: quadrant['color'],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${todos.length}개',
                        style: TextStyle(
                          color: quadrant['color'],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: todos.isEmpty
                    ? Center(
                        child: Text(
                          '할 일이 없습니다',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      )
                    : ListView(
                        children: todos.map((t) {
                          final todo = _parseTodo(t);
                          return Dismissible(
                            key: ValueKey(todo['id']),
                            direction: DismissDirection.horizontal,
                            confirmDismiss: (direction) async {
                              if (direction != DismissDirection.endToStart) {
                                // 왼쪽 스와이프 - 삭제
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
                              } else {
                                // 오른쪽 스와이프 - 수정
                                await _showEditDialog(context, todo);
                                return false;
                              }
                            },
                            onDismissed: (direction) {
                              if (direction == DismissDirection.endToStart) {
                                onDelete(todo['id']);
                              }
                            },
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            secondaryBackground: Container(
                              color: Colors.blue,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: const Icon(Icons.edit, color: Colors.white),
                            ),
                            child: LongPressDraggable<Map<String, dynamic>>(
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
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        );
      },
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

  Future<void> _showAddDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => TodoDialog(
        title: '${quadrant['label']}',
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