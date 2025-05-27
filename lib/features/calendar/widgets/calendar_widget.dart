import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../matrix/matrix_category_provider.dart';
import 'calendar_marker.dart';

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _viewIndex = 0; // 0: 월간, 1: 주간
  final Map<DateTime, List<Map<String, String>>> _events = {
    DateTime.utc(2024, 4, 18): [
      {'title': '회의', 'time': '09:00'},
      {'title': '치과', 'time': '11:00'},
    ],
    DateTime.utc(2024, 4, 19): [
      {'title': '프로젝트 마감', 'time': '17:00'},
    ],
  };

  // todoMap: 날짜별로 todo를 저장
  Map<DateTime, List<Map<String, dynamic>>> _todoMap = {};

  // 1. _events를 SharedPreferences에 저장/불러오기 위한 키
  static const String calendarEventsKey = 'calendar_events';

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _loadAllTodos();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAllTodos();
  }

  Future<void> _loadAllTodos() async {
    await _loadEvents();
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getString('matrix_categories');
    if (categoriesJson == null) return;
    final List<dynamic> categories = json.decode(categoriesJson);
    Map<DateTime, List<Map<String, dynamic>>> map = {};
    for (final cat in categories) {
      final key = 'todos_${cat['id']}';
      final list = prefs.getStringList(key) ?? [];
      for (final e in list) {
        final todo = json.decode(e) as Map<String, dynamic>;
        if (todo['date'] != null && todo['date'] != '') {
          final todoDate = DateTime.tryParse(todo['date']);
          if (todoDate != null) {
            final day = DateTime.utc(todoDate.year, todoDate.month, todoDate.day);
            map.putIfAbsent(day, () => []);
            map[day]!.add(todo);
          }
        }
      }
    }
    setState(() {
      _todoMap = map;
    });
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString(calendarEventsKey);
    if (eventsJson != null) {
      final decoded = json.decode(eventsJson) as Map<String, dynamic>;
      final Map<DateTime, List<Map<String, String>>> loaded = {};
      decoded.forEach((k, v) {
        final date = DateTime.parse(k);
        final list = (v as List).map((e) => Map<String, String>.from(e)).toList();
        loaded[date] = list;
      });
      setState(() {
        _events.clear();
        _events.addAll(loaded);
      });
    }
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> toSave = {};
    _events.forEach((k, v) {
      toSave[k.toIso8601String()] = v;
    });
    await prefs.setString(calendarEventsKey, json.encode(toSave));
  }

  List<Map<String, dynamic>> _getTodosForDay(DateTime day) {
    final key = DateTime.utc(day.year, day.month, day.day);
    return _todoMap[key] ?? [];
  }

  void _addEvent(DateTime day, String event, String time) {
    final key = DateTime.utc(day.year, day.month, day.day);
    setState(() {
      _events.putIfAbsent(key, () => []);
      _events[key]!.add({'title': event, 'time': time});
    });
    _saveEvents();
  }

  void _editEvent(DateTime day, int idx, String newEvent, String newTime) {
    final key = DateTime.utc(day.year, day.month, day.day);
    setState(() {
      _events[key]![idx] = {'title': newEvent, 'time': newTime};
    });
    _saveEvents();
  }

  void _deleteEvent(DateTime day, int idx) {
    final key = DateTime.utc(day.year, day.month, day.day);
    setState(() {
      _events[key]!.removeAt(idx);
      if (_events[key]!.isEmpty) _events.remove(key);
    });
    _saveEvents();
  }

  Future<void> _showAddEventDialog(DateTime day) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleController = TextEditingController();
    DateTime? selectedDate = day;
    TimeOfDay? selectedTime;
    String? selectedQuadrant; // null로 초기화하여 선택사항으로 변경
    final quadrants = [
      {'label': '매트릭스에 추가하지 않음', 'key': null},
      {'label': '중요 & 긴급', 'key': 'do_first'},
      {'label': '중요 & 비긴급', 'key': 'schedule'},
      {'label': '비중요 & 긴급', 'key': 'delegate'},
      {'label': '비중요 & 비긴급', 'key': 'eliminate'},
    ];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.event_note, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('일정 추가', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: '일정',
                    prefixIcon: const Icon(Icons.edit_note),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(selectedDate == null ? '날짜 선택' : '${selectedDate!.year}/${selectedDate!.month}/${selectedDate!.day}'),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          textStyle: const TextStyle(fontWeight: FontWeight.w500),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: isDark
                                    ? ColorScheme.dark(primary: Theme.of(context).colorScheme.primary)
                                    : ColorScheme.light(primary: Theme.of(context).colorScheme.primary),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) setState(() => selectedDate = date);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: Text(selectedTime == null ? '시간 선택' : selectedTime!.format(context)),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          textStyle: const TextStyle(fontWeight: FontWeight.w500),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ?? TimeOfDay.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: isDark
                                    ? ColorScheme.dark(primary: Theme.of(context).colorScheme.primary)
                                    : ColorScheme.light(primary: Theme.of(context).colorScheme.primary),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (time != null) setState(() => selectedTime = time);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.secondary,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, {
                        'title': titleController.text,
                        'date': selectedDate ?? DateTime.now(),
                        'time': selectedTime?.format(context) ?? TimeOfDay.now().format(context),
                        'quadrant': selectedQuadrant,
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: const Text('추가'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result != null && result['title']!.trim().isNotEmpty) {
      // 캘린더에는 항상 추가
      final newEvent = {
        'title': result['title']!.trim(),
        'date': (result['date'] as DateTime?)?.toIso8601String(),
        'time': result['time'] as String,
      };
      final events = _events.values.expand((e) => e).toList();
      final alreadyExists = events.any((e) =>
        e['title'] == newEvent['title'] &&
        e['date'] == newEvent['date'] &&
        e['time'] == newEvent['time']
      );
      if (!alreadyExists) {
        _addEvent(
          result['date'] as DateTime,
          result['title']!.trim(),
          result['time'] as String,
        );
        await _loadAllTodos();
        setState(() {});
      }
      // 매트릭스 todo는 quadrant가 null이 아닌 경우에만 추가
      if (result['quadrant'] != null && result['quadrant'] != '') {
        final prefs = await SharedPreferences.getInstance();
        final categoriesJson = prefs.getString('matrix_categories');
        if (categoriesJson != null) {
          final List<dynamic> categories = json.decode(categoriesJson);
          String categoryId = categories.isNotEmpty ? categories.first['id'] : 'default';
          final key = 'todos_$categoryId';
          final list = prefs.getStringList(key) ?? [];
          final todo = {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'title': result['title']!.trim(),
            'quadrant': result['quadrant'],
            'isDone': false,
            'date': (result['date'] as DateTime?)?.toIso8601String(),
            'time': result['time'],
          };
          final alreadyExists = list.any((e) {
            final t = json.decode(e);
            return t['title'] == todo['title'] && t['date'] == todo['date'] && t['time'] == todo['time'];
          });
          if (!alreadyExists) {
            list.add(json.encode(todo));
            await prefs.setStringList(key, list);
            await _loadAllTodos();
            setState(() {});
          }
        }
      }
    }
  }

  Future<void> _showEditEventDialogUniversal(DateTime day, Map<String, dynamic> event, {bool isTodo = false, String? todoKey}) async {
    final titleController = TextEditingController(text: event['title']);
    DateTime? selectedDate = day;
    TimeOfDay? selectedTime;
    if (event['time'] != null && event['time'] != '') {
      final timeParts = event['time'].split(':');
      if (timeParts.length == 2) {
        selectedTime = TimeOfDay(
          hour: int.tryParse(timeParts[0]) ?? 0,
          minute: int.tryParse(timeParts[1]) ?? 0,
        );
      }
    }
    bool isDone = event['isDone'] == true;
    String? selectedQuadrant = event['quadrant'];
    final quadrants = [
      {'label': '매트릭스에 추가하지 않음', 'key': null},
      {'label': '중요 & 긴급', 'key': 'do_first'},
      {'label': '중요 & 비긴급', 'key': 'schedule'},
      {'label': '비중요 & 긴급', 'key': 'delegate'},
      {'label': '비중요 & 비긴급', 'key': 'eliminate'},
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.edit_note, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('일정 수정'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: '일정',
                    prefixIcon: const Icon(Icons.edit_note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          selectedDate == null 
                            ? '날짜 선택' 
                            : '${selectedDate!.year}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.day.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: isDark
                                    ? ColorScheme.dark(primary: Theme.of(context).colorScheme.primary)
                                    : ColorScheme.light(primary: Theme.of(context).colorScheme.primary),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) setState(() => selectedDate = date);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          selectedTime == null 
                            ? '시간 선택' 
                            : selectedTime!.format(context),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ?? TimeOfDay.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: isDark
                                    ? ColorScheme.dark(primary: Theme.of(context).colorScheme.primary)
                                    : ColorScheme.light(primary: Theme.of(context).colorScheme.primary),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (time != null) setState(() => selectedTime = time);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: selectedQuadrant,
                  decoration: const InputDecoration(
                    labelText: '매트릭스(선택사항)',
                    border: OutlineInputBorder(),
                  ),
                  items: quadrants.map((q) => DropdownMenuItem(
                    value: q['key'] as String?,
                    child: Text(q['label']!),
                  )).toList(),
                  onChanged: (v) => setState(() => selectedQuadrant = v),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: isDone,
                  onChanged: (v) => setState(() => isDone = v ?? false),
                  title: const Text('완료(체크시 취소선)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, {'delete': '1'}),
              child: const Text('삭제'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'title': titleController.text,
                'date': selectedDate,
                'time': selectedTime?.format(context) ?? '',
                'quadrant': selectedQuadrant,
                'isDone': isDone,
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: isDark ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      if (result['delete'] == '1') {
        if (isTodo && todoKey != null) {
          final prefs = await SharedPreferences.getInstance();
          final list = prefs.getStringList(todoKey) ?? [];
          list.removeWhere((e) => json.decode(e)['id'] == event['id']);
          await prefs.setStringList(todoKey, list);
        } else {
          _deleteEvent(day, event['index'] ?? 0);
        }
        _loadAllTodos();
        setState(() {});
      } else if (result['title']!.trim().isNotEmpty) {
        if (isTodo && todoKey != null) {
          final prefs = await SharedPreferences.getInstance();
          final list = prefs.getStringList(todoKey) ?? [];
          final idx = event['index'] ?? 0;
          if (idx >= 0 && idx < list.length) {
            final todo = {
              'id': event['id'],
              'title': result['title']!.trim(),
              'quadrant': result['quadrant'],
              'isDone': result['isDone'],
              'date': (result['date'] as DateTime?)?.toIso8601String(),
              'time': result['time'],
            };
            list[idx] = json.encode(todo);
            await prefs.setStringList(todoKey, list);
          }
        } else {
          _editEvent(day, event['index'] ?? 0, result['title']!.trim(), result['time'] as String);
        }
        _loadAllTodos();
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedDay = _selectedDay ?? _focusedDay;
    final events = [
      ..._getEventsForDay(selectedDay),
      ..._getTodosForDay(selectedDay),
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  '${(_viewIndex == 0 ? _focusedDay : (_selectedDay ?? _focusedDay)).year.toString().padLeft(4, '0')} . ${(_viewIndex == 0 ? _focusedDay : (_selectedDay ?? _focusedDay)).month.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 30.0),
                child: SizedBox(
                  width: 94,
                  height: 40,
                  child: TextButton.icon(
                    icon: const Icon(Icons.today),
                    label: const Text('today'),
                    style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        setState(() {
                          _focusedDay = DateTime.now();
                          _selectedDay = DateTime.now();
                        });
                      },
                    ),
                ),
              ),
              ToggleButtons(
                isSelected: [_viewIndex == 0, _viewIndex == 1],
                onPressed: (i) => setState(() {
                  _viewIndex = i;
                  if (i == 1) {
                    _selectedDay = DateTime.now();
                    _focusedDay = DateTime.now();
                  }
                }),
                borderRadius: BorderRadius.circular(8),
                selectedColor: isDark ? Colors.black : Colors.white,
                fillColor: Theme.of(context).colorScheme.primary,
                color: Theme.of(context).colorScheme.primary,
                constraints: const BoxConstraints(minWidth: 80, minHeight: 40),
                children: [
                  Text('월간', style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _viewIndex == 0 ? (isDark ? Colors.black : Colors.white) : Theme.of(context).colorScheme.primary
                  )),
                  Text('주간', style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _viewIndex == 1 ? (isDark ? Colors.black : Colors.white) : Theme.of(context).colorScheme.primary
                  )),
                ],
              ),
              
              Padding(
                padding: const EdgeInsets.only(left: 50.0),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => _showAddEventDialog(_selectedDay ?? _focusedDay),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_viewIndex == 0)
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            eventLoader: (day) {
              final calendarEvents = _getEventsForDay(day);
              final todos = _getTodosForDay(day);
              return [...calendarEvents, ...todos];
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(color: Colors.red.shade400),
              outsideDaysVisible: false,
              cellMargin: const EdgeInsets.all(2),
              cellPadding: const EdgeInsets.symmetric(vertical: 6),
              defaultTextStyle: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
              selectedTextStyle: TextStyle(
                color: isDark ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
              todayTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            headerVisible: false,
            onFormatChanged: (format) {},
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) => buildCalendarMarker(context, events, _getQuadrantColor),
            ),
          ),
        if (_viewIndex == 0)
          const SizedBox(height: 8),
        Expanded(
          child: _viewIndex == 0
              ? (events.isEmpty
                  ? Center(child: Text('일정이 없습니다', style: TextStyle(color: Colors.grey.shade500)))
                  : ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, i) => Dismissible(
                        key: ValueKey('${selectedDay.toIso8601String()}_${events[i]['title'] ?? events[i].toString()}'),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: Theme.of(context).dialogBackgroundColor,
                              titleTextStyle: Theme.of(context).textTheme.titleLarge,
                              contentTextStyle: Theme.of(context).textTheme.bodyMedium,
                              title: const Text('삭제 확인'),
                              content: Text('정말 "${events[i]['title'] ?? events[i].toString()}" 일정을 삭제할까요?', style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7))),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
                                ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제')),
                              ],
                            ),
                          ) ?? false;
                        },
                        onDismissed: (_) async {
                          if (events[i]['id'] != null) {
                            // todo 삭제
                            await _deleteTodo(events[i]['id']);
                          } else {
                            // calendar 이벤트 삭제
                            _deleteEvent(selectedDay, i);
                          }
                          await _loadAllTodos();
                          setState(() {});
                        },
                        background: Container(
                          color: Theme.of(context).colorScheme.error,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
                        ),
                        child: ListTile(
                          leading: (events[i]['quadrant'] != null)
                            ? Container(
                                width: 14,
                                height: 14,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: _getQuadrantColor(events[i]['quadrant']),
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                          title: Text(
                            events[i]['title'] ?? events[i].toString(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground,
                              decoration: events[i]['isDone'] == true ? TextDecoration.lineThrough : null,
                              fontWeight: events[i]['isDone'] == true ? FontWeight.w400 : FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            events[i]['time'] ?? '',
                            style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7)),
                          ),
                          onTap: () async {
                            if (events[i]['id'] != null) {
                              // todo에서 온 항목
                              final prefs = await SharedPreferences.getInstance();
                              final categoriesJson = prefs.getString('matrix_categories');
                              if (categoriesJson != null) {
                                final List<dynamic> categories = json.decode(categoriesJson);
                                for (final cat in categories) {
                                  final key = 'todos_${cat['id']}';
                                  final list = prefs.getStringList(key) ?? [];
                                  final idx = list.indexWhere((el) => json.decode(el)['id'] == events[i]['id']);
                                  if (idx != -1) {
                                    await _showEditEventDialogUniversal((_selectedDay ?? _focusedDay), {...events[i], 'index': idx}, isTodo: true, todoKey: key);
                                    return;
                                  }
                                }
                              }
                            }
                            // calendar 이벤트
                            await _showEditEventDialogUniversal((_selectedDay ?? _focusedDay), {...events[i], 'index': i});
                          },
                        ),
                      ),
                    ))
              : _buildWeekView(),
        ),
      ],
    );
  }

  Widget _buildWeekView() {
    _loadAllTodos(); // 주간탭에서도 최신 데이터 로드
    final now = _selectedDay ?? _focusedDay;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final thisMonth = now.month;
    final startOfWeek = (_selectedDay ?? _focusedDay).subtract(Duration(days: (_selectedDay ?? _focusedDay).weekday - 1));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    // 주간 이벤트 데이터 가져오기
    List<Map<String, dynamic>> weekEvents = [];
    for (final day in days) {
      final dayEvents = _getEventsForDay(day);
      final dayTodos = _getTodosForDay(day);
      weekEvents.addAll([...dayEvents, ...dayTodos]);
    }

    final day = _selectedDay ?? _focusedDay;
    final selectedDayEvents = [
      ..._getEventsForDay(day),
      ..._getTodosForDay(day),
    ];

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        setState(() {
          if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
            _selectedDay = (_selectedDay ?? _focusedDay).add(const Duration(days: 7));
            _focusedDay = _selectedDay!;
          } else if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
            _selectedDay = (_selectedDay ?? _focusedDay).subtract(const Duration(days: 7));
            _focusedDay = _selectedDay!;
          }
        });
      },
      child: Column(
        children: [
          Container(
            height: 100,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: days.map((d) {
                final isSelected = isSameDay(d, _selectedDay);
                final isToday = isSameDay(d, DateTime.now());
                final events = [
                  ..._getEventsForDay(d),
                  ..._getTodosForDay(d),
                ];
                final isOtherMonth = d.month != thisMonth;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDay = d),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                          : (isToday
                              ? (isDark ? Colors.blueGrey.shade900 : Colors.blue.shade50)
                              : (isOtherMonth ? Colors.grey.shade200 : (isDark ? Colors.grey.shade800 : null))),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : (isToday
                                ? Theme.of(context).colorScheme.secondary
                                : (isOtherMonth ? Colors.grey : (isDark ? Colors.grey.shade700 : Colors.grey.shade300))),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _weekdayKor(d.weekday),
                            style: TextStyle(
                              color: isSelected ? Theme.of(context).colorScheme.primary : (isToday ? Colors.blue : (isOtherMonth ? Colors.grey : Colors.grey)),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${d.day}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Theme.of(context).colorScheme.primary : (isToday ? Colors.blue : (isOtherMonth ? Colors.grey : null)),
                            ),
                          ),
                          if (isOtherMonth)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                '${d.month}월',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (events.isNotEmpty)
                            buildCalendarMarker(context, events, _getQuadrantColor),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          Expanded(
            child: _selectedDay == null
                ? const Center(child: Text('날짜를 선택해주세요'))
                : ListView.builder(
                    itemCount: selectedDayEvents.length,
                    itemBuilder: (context, i) {
                      final event = selectedDayEvents[i];
                      final isDone = event['isDone'] == true;
                      return Dismissible(
                        key: ValueKey('${day.toIso8601String()}_${event['title'] ?? event.toString()}'),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: Theme.of(context).dialogBackgroundColor,
                              titleTextStyle: Theme.of(context).textTheme.titleLarge,
                              contentTextStyle: Theme.of(context).textTheme.bodyMedium,
                              title: const Text('삭제 확인'),
                              content: Text('정말 "${event['title'] ?? event.toString()}" 일정을 삭제할까요?', style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7))),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
                                ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제')),
                              ],
                            ),
                          ) ?? false;
                        },
                        onDismissed: (_) {
                          if (event['id'] != null) {
                            // todo 삭제
                            _deleteTodo(event['id']);
                          } else {
                            // calendar 이벤트 삭제
                            _deleteEvent(day, i);
                          }
                        },
                        background: Container(
                          color: Theme.of(context).colorScheme.error,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
                        ),
                        child: ListTile(
                          leading: (event['quadrant'] != null)
                            ? Container(
                                width: 14,
                                height: 14,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                  color: _getQuadrantColor(event['quadrant']),
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                          title: Text(
                            event['title'] ?? event.toString(),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                              fontWeight: isDone ? FontWeight.w400 : FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            event['time'] ?? '',
                            style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7)),
                          ),
                          onTap: () async {
                            if (event['id'] != null) {
                              // todo에서 온 항목
                              final prefs = await SharedPreferences.getInstance();
                              final categoriesJson = prefs.getString('matrix_categories');
                              if (categoriesJson != null) {
                                final List<dynamic> categories = json.decode(categoriesJson);
                                for (final cat in categories) {
                                  final key = 'todos_${cat['id']}';
                                  final list = prefs.getStringList(key) ?? [];
                                  final idx = list.indexWhere((el) => json.decode(el)['id'] == event['id']);
                                  if (idx != -1) {
                                    await _showEditEventDialogUniversal(day, {...event, 'index': idx}, isTodo: true, todoKey: key);
                                    return;
                                  }
                                }
                              }
                            }
                            // calendar 이벤트
                            await _showEditEventDialogUniversal(day, {...event, 'index': i});
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _weekdayKor(int weekday) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[(weekday - 1) % 7];
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final key = DateTime.utc(day.year, day.month, day.day);
    final events = _events[key] ?? [];
    return events.map((e) => e as Map<String, dynamic>).toList();
  }

  // todo 삭제 함수 추가
  Future<void> _deleteTodo(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getString('matrix_categories');
    if (categoriesJson != null) {
      final List<dynamic> categories = json.decode(categoriesJson);
      for (final cat in categories) {
        final key = 'todos_${cat['id']}';
        final list = prefs.getStringList(key) ?? [];
        list.removeWhere((e) => json.decode(e)['id'] == id);
        await prefs.setStringList(key, list);
      }
    }
    _loadAllTodos();
    setState(() {});
  }

  Color _getQuadrantColor(String? quadrant) {
    if (quadrant == null) return Theme.of(context).colorScheme.primary;
    switch (quadrant) {
      case 'do_first':
        return const Color(0xFFE57373); // 빨강
      case 'schedule':
        return const Color(0xFF64B5F6); // 파랑
      case 'delegate':
        return const Color(0xFFFFB74D); // 오렌지
      case 'eliminate':
        return const Color(0xFF81C784); // 초록 (비중요&비긴급)
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
} 