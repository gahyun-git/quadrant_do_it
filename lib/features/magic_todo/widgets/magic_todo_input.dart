import 'package:flutter/material.dart';

typedef MagicCallback = void Function(String text);

class MagicTodoInput extends StatelessWidget {
  final MagicCallback? onMagic;
  const MagicTodoInput({super.key, this.onMagic});

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {
              if (onMagic != null) onMagic!(controller.text);
              controller.clear();
            },
            child: const Text('Magic!'),
          ),
        ],
      ),
    );
  }
} 