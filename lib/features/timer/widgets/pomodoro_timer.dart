import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../timer_provider.dart';
import 'package:flutter/cupertino.dart';

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
              final min = await showModalBottomSheet<int>(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  int tempSelected = selected;
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).dialogBackgroundColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('타이머 시간 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 180,
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(initialItem: selected - 1),
                            itemExtent: 40,
                            onSelectedItemChanged: (i) => tempSelected = i + 1,
                            children: List.generate(120, (i) => Center(child: Text('${i + 1}분', style: const TextStyle(fontSize: 20)))),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('취소'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, tempSelected),
                              child: const Text('설정'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
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
    final fgPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;
    final bgPaint = Paint()
      ..color = Colors.black // 배경색(다크모드면 Theme 적용 가능)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    // 항상 전체 빨간 띠를 그림
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.141592/2,
      2 * 3.141592,
      false,
      fgPaint,
    );
    // 진행된 부분만 검정색(배경색)으로 덮어서 반시계방향으로 줄어드는 효과
    if (percent < 1.0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.141592/2,
        -2 * 3.141592 * (1 - percent),
        false,
        bgPaint,
      );
    }
  }
  @override
  bool shouldRepaint(covariant _PomodoroCirclePainter old) => old.percent != percent;
}
