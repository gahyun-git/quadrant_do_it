import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../timer_provider.dart';

class PomodoroTimer extends ConsumerWidget {
  const PomodoroTimer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);
    final minutes = (state.seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (state.seconds % 60).toString().padLeft(2, '0');
    final percent = state.seconds / state.totalSeconds;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: state.isRunning ? null : () async {
              int selected = state.totalSeconds ~/ 60;
              final min = await showDialog<int>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('타이머 시간 설정'),
                  content: StatefulBuilder(
                    builder: (context, setStateDialog) {
                      return DropdownButton<int>(
                        value: selected,
                        items: [1, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60]
                            .map((m) => DropdownMenuItem(value: m, child: Text('$m분')))
                            .toList(),
                        onChanged: (v) => setStateDialog(() => selected = v!),
                      );
                    },
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
                    ElevatedButton(onPressed: () => Navigator.pop(context, selected), child: const Text('설정')),
                  ],
                ),
              );
              if (min != null) notifier.setMinutes(min);
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 240,
                  height: 240,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1.0, end: percent),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      return CustomPaint(
                        painter: _PomodoroCirclePainter(percent: value),
                      );
                    },
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$minutes:$secs', style: const TextStyle(fontSize: 54, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (!state.isRunning)
                      const Text('시간을 누르면 변경', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(state.isRunning ? Icons.pause : Icons.play_arrow, size: 40),
                onPressed: state.isRunning ? notifier.pause : notifier.start,
              ),
              const SizedBox(width: 32),
              IconButton(
                icon: const Icon(Icons.stop, size: 40),
                onPressed: notifier.reset,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PomodoroCirclePainter extends CustomPainter {
  final double percent;
  _PomodoroCirclePainter({required this.percent});
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = Colors.grey.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22;
    final fgPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    // 전체(빨강) 먼저 그림
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.141592/2,
      2 * 3.141592,
      false,
      fgPaint,
    );
    // 남은 부분(검정)으로 덮어줌
    if (percent < 1.0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.141592/2 + 2 * 3.141592 * (1 - percent),
        2 * 3.141592 * percent,
        false,
        bgPaint,
      );
    }
  }
  @override
  bool shouldRepaint(covariant _PomodoroCirclePainter old) => old.percent != percent;
}
