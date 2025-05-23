import 'package:flutter/material.dart';
import 'widgets/pomodoro_timer.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('포모도로 타이머')),
      body: const Center(child: PomodoroTimer()),
    );
  }
}
