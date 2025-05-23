import 'package:flutter/material.dart';
import 'widgets/magic_todo_input.dart';

class MagicTodoPage extends StatefulWidget {
  const MagicTodoPage({super.key});

  @override
  State<MagicTodoPage> createState() => _MagicTodoPageState();
}

class _MagicTodoPageState extends State<MagicTodoPage> {
  final List<String> _magicTodos = [
    '자료조사',
    '초안 작성',
    '교수님 피드백 받기',
    '최종본 제출',
  ];

  void _addMagicTodo(String text) {
    setState(() {
      _magicTodos.add(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Magic Todo (AI)')),
      body: Column(
        children: [
          MagicTodoInput(onMagic: (text) {
            if (text.trim().isNotEmpty) _addMagicTodo(text.trim());
          }),
          Expanded(
            child: ListView.builder(
              itemCount: _magicTodos.length,
              itemBuilder: (_, i) => ListTile(
                leading: const Icon(Icons.check_box_outline_blank),
                title: Text(_magicTodos[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 