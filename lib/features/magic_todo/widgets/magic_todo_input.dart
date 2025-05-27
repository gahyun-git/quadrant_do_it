import 'package:flutter/material.dart';
import '../providers/magic_todo_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MagicTodoInput extends ConsumerWidget {
  final void Function(String text)? onMagic;
  const MagicTodoInput({super.key, this.onMagic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: '예: 논문 준비',
                labelText: 'AI에게 할 일 입력',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              // 매직투두 AI 기능과 연결
              final todos = await ref.read(magicTodoServiceProvider).generateTodos(text);
              ref.read(magicTodoNotifierProvider.notifier).setTodos(todos);
              controller.clear();
              if (onMagic != null) onMagic!(text);
            },
            child: const Text('Magic!'),
          ),
        ],
      ),
    );
  }
} 