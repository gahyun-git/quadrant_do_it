import 'package:flutter/material.dart';

class AddTodoDialog extends StatelessWidget {
  const AddTodoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return AlertDialog(
      title: const Text('할 일 추가'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(labelText: '할 일'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
        ElevatedButton(onPressed: () {}, child: const Text('추가')),
      ],
    );
  }
}
