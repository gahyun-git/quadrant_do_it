import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final calendarEventsProvider = StateNotifierProvider<CalendarEventsNotifier, Map<DateTime, List<Map<String, String>>>>((ref) {
  return CalendarEventsNotifier();
});

class CalendarEventsNotifier extends StateNotifier<Map<DateTime, List<Map<String, String>>>> {
  CalendarEventsNotifier() : super({}) {
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString('calendar_events');
    if (eventsJson != null) {
      final Map<String, dynamic> decoded = json.decode(eventsJson);
      final Map<DateTime, List<Map<String, String>>> events = {};
      decoded.forEach((key, value) {
        final date = DateTime.parse(key);
        events[date] = (value as List).map((e) => Map<String, String>.from(e)).toList();
      });
      state = events;
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> encoded = {};
    state.forEach((key, value) {
      encoded[key.toIso8601String()] = value;
    });
    await prefs.setString('calendar_events', json.encode(encoded));
  }

  void addEvent(DateTime day, String title, String time) {
    final key = DateTime.utc(day.year, day.month, day.day);
    state = {
      ...state,
      key: [...(state[key] ?? []), {'title': title, 'time': time}],
    };
    _saveEvents();
  }

  void editEvent(DateTime day, int index, String title, String time) {
    final key = DateTime.utc(day.year, day.month, day.day);
    if (state[key] != null && index < state[key]!.length) {
      final newEvents = List<Map<String, String>>.from(state[key]!);
      newEvents[index] = {'title': title, 'time': time};
      state = {
        ...state,
        key: newEvents,
      };
      _saveEvents();
    }
  }

  void deleteEvent(DateTime day, int index) {
    final key = DateTime.utc(day.year, day.month, day.day);
    if (state[key] != null && index < state[key]!.length) {
      final newEvents = List<Map<String, String>>.from(state[key]!);
      newEvents.removeAt(index);
      if (newEvents.isEmpty) {
        final newState = Map<DateTime, List<Map<String, String>>>.from(state);
        newState.remove(key);
        state = newState;
      } else {
        state = {
          ...state,
          key: newEvents,
        };
      }
      _saveEvents();
    }
  }
} 