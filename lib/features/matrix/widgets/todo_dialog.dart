import 'package:flutter/material.dart';

class TodoDialog extends StatefulWidget {
  final String title;
  final String initialTitle;
  final DateTime? initialDate;
  final TimeOfDay? initialTime;

  const TodoDialog({
    super.key,
    required this.title,
    required this.initialTitle,
    this.initialDate,
    this.initialTime,
  });

  @override
  State<TodoDialog> createState() => _TodoDialogState();
}

class _TodoDialogState extends State<TodoDialog> {
  late TextEditingController _controller;
  late DateTime? _selectedDate;
  late TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
    _selectedDate = widget.initialDate;
    _selectedTime = widget.initialTime;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: '할 일',
                prefixIcon: const Icon(Icons.task_alt),
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
                    label: Text(_selectedDate == null ? '날짜 선택' : '${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
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
                      if (date != null) setState(() => _selectedDate = date);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Text(_selectedTime == null ? '시간 선택' : _selectedTime!.format(context)),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      textStyle: const TextStyle(fontWeight: FontWeight.w500),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    ),
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime ?? TimeOfDay.now(),
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
                      if (time != null) setState(() => _selectedTime = time);
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
                    'title': _controller.text,
                    'date': _selectedDate ?? DateTime.now(),
                    'time': _selectedTime,
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: const Text('저장'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 