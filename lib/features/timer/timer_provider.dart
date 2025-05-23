import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:async';
class PomodoroState {
  final int totalSeconds;
  final int seconds;
  final bool isRunning;
  PomodoroState({required this.totalSeconds, required this.seconds, required this.isRunning});

  PomodoroState copyWith({int? totalSeconds, int? seconds, bool? isRunning}) =>
      PomodoroState(
        totalSeconds: totalSeconds ?? this.totalSeconds,
        seconds: seconds ?? this.seconds,
        isRunning: isRunning ?? this.isRunning,
      );
}

class PomodoroNotifier extends StateNotifier<PomodoroState> {
  PomodoroNotifier() : super(PomodoroState(totalSeconds: 25 * 60, seconds: 25 * 60, isRunning: false));
  Timer? timer;

  void start() {
    if (timer != null) return;
    state = state.copyWith(isRunning: true);
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.seconds > 0) {
        state = state.copyWith(seconds: state.seconds - 1);
      } else {
        timer?.cancel();
        timer = null;
        state = state.copyWith(isRunning: false);
      }
    });
  }

  void pause() {
    timer?.cancel();
    timer = null;
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    timer?.cancel();
    timer = null;
    state = state.copyWith(seconds: state.totalSeconds, isRunning: false);
  }

  void setMinutes(int min) {
    timer?.cancel();
    timer = null;
    state = PomodoroState(totalSeconds: min * 60, seconds: min * 60, isRunning: false);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}

final pomodoroProvider = StateNotifierProvider<PomodoroNotifier, PomodoroState>((ref) => PomodoroNotifier());