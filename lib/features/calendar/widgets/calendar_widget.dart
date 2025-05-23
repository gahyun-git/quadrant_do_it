import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../matrix/matrix_category_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _loadAllTodos();
  }

  Future<void> _loadAllTodos() async {
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
  }

  void _editEvent(DateTime day, int idx, String newEvent, String newTime) {
    final key = DateTime.utc(day.year, day.month, day.day);
    setState(() {
      _events[key]![idx] = {'title': newEvent, 'time': newTime};
    });
  }

  void _deleteEvent(DateTime day, int idx) {
    final key = DateTime.utc(day.year, day.month, day.day);
    setState(() {
      _events[key]!.removeAt(idx);
      if (_events[key]!.isEmpty) _events.remove(key);
    });
  }

  Future<void> _showAddEventDialog(DateTime day) async {
    final titleController = TextEditingController();
    DateTime? selectedDate = day;
    TimeOfDay? selectedTime;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.event_note, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('일정 추가'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: '일정',
                  hintText: '일정을 입력하세요',
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
                            final isDark = Theme.of(context).brightness == Brightness.dark;
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
                            final isDark = Theme.of(context).brightness == Brightness.dark;
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'title': titleController.text,
                'date': selectedDate,
                'time': selectedTime?.format(context) ?? '',
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );

    if (result != null && result['title']!.trim().isNotEmpty) {
      _addEvent(
        result['date'] as DateTime,
        result['title']!.trim(),
        result['time'] as String,
      );
    }
  }

  Future<void> _showEditEventDialog(DateTime day, int idx) async {
    final event = _getEventsForDay(day)[idx];
    final titleController = TextEditingController(text: event['title']);
    DateTime? selectedDate = day;
    TimeOfDay? selectedTime;
    if (event['time'] != null) {
      final timeParts = event['time']!.split(':');
      selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    }

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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: '일정',
                  hintText: '일정을 입력하세요',
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
                            final isDark = Theme.of(context).brightness == Brightness.dark;
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
                            final isDark = Theme.of(context).brightness == Brightness.dark;
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, {'delete': '1'}),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('삭제'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'title': titleController.text,
                'date': selectedDate,
                'time': selectedTime?.format(context) ?? '',
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
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
        _deleteEvent(day, idx);
      } else if (result['title']!.trim().isNotEmpty) {
        _editEvent(
          result['date'] as DateTime,
          idx,
          result['title']!.trim(),
          result['time'] as String,
        );
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
              Text(
                '${(_viewIndex == 0 ? _focusedDay : (_selectedDay ?? _focusedDay)).year.toString().padLeft(4, '0')} . ${(_viewIndex == 0 ? _focusedDay : (_selectedDay ?? _focusedDay)).month.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 1.2,
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
                onPressed: (i) => setState(() => _viewIndex = i),
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
                padding: const EdgeInsets.only(left: 60.0),
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
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(events.length > 3 ? 3 : events.length, (idx) =>
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 0.5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isDark
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
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
                        onDismissed: (_) => _deleteEvent(selectedDay, i),
                        background: Container(
                          color: Theme.of(context).colorScheme.error,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
                        ),
                        child: ListTile(
                          title: Text(
                            events[i]['title'] ?? events[i].toString(),
                            style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                          ),
                          subtitle: Text(
                            events[i]['time'] ?? '',
                            style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7)),
                          ),
                          onTap: () async {
                            await _showEditEventDialog(selectedDay, i);
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
    final now = _selectedDay ?? _focusedDay;
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: days.map((d) {
              final isSelected = isSameDay(d, _selectedDay);
              final isToday = isSameDay(d, DateTime.now());
              final events = _getEventsForDay(d);
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
                            : (isDark ? Colors.grey.shade800 : null)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : (isToday
                              ? Theme.of(context).colorScheme.secondary
                              : (isDark ? Colors.grey.shade700 : Colors.grey.shade300)),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _weekdayKor(d.weekday),
                          style: TextStyle(
                            color: isSelected ? Theme.of(context).colorScheme.primary : (isToday ? Colors.blue : Colors.grey),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${d.day}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Theme.of(context).colorScheme.primary : (isToday ? Colors.blue : null),
                          ),
                        ),
                        if (events.isNotEmpty)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : (isToday
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.error),
                              shape: BoxShape.circle,
                            ),
                          ),
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
                  itemCount: _getEventsForDay(_selectedDay!).length,
                  itemBuilder: (context, i) => Dismissible(
                    key: ValueKey('${_selectedDay!.toIso8601String()}_${_getEventsForDay(_selectedDay!)[i]['title'] ?? _getEventsForDay(_selectedDay!)[i].toString()}'),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: Theme.of(context).dialogBackgroundColor,
                          titleTextStyle: Theme.of(context).textTheme.titleLarge,
                          contentTextStyle: Theme.of(context).textTheme.bodyMedium,
                          title: const Text('삭제 확인'),
                          content: Text('정말 "${_getEventsForDay(_selectedDay!)[i]['title'] ?? _getEventsForDay(_selectedDay!)[i].toString()}" 일정을 삭제할까요?', style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7))),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
                            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제')),
                          ],
                        ),
                      ) ?? false;
                    },
                    onDismissed: (_) => _deleteEvent(_selectedDay!, i),
                    background: Container(
                      color: Theme.of(context).colorScheme.error,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
                    ),
                    child: ListTile(
                      title: Text(
                        _getEventsForDay(_selectedDay!)[i]['title'] ?? _getEventsForDay(_selectedDay!)[i].toString(),
                        style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                      ),
                      subtitle: Text(
                        _getEventsForDay(_selectedDay!)[i]['time'] ?? '',
                        style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7)),
                      ),
                      onTap: () async {
                        await _showEditEventDialog(_selectedDay!, i);
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  String _weekdayKor(int weekday) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[(weekday - 1) % 7];
  }

  List<Map<String, String>> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }
} 