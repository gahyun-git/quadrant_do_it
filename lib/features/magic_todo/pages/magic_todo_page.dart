import 'package:flutter/material.dart';
import '../widgets/magic_todo_widget.dart';

class MagicTodoPage extends StatelessWidget {
  const MagicTodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: MagicTodoWidget(),
      ),
    );
  }
} 