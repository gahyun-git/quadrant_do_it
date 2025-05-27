import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/magic_todo_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/widget_service.dart';
import '../../../services/ai/magic_todo_service.dart';

class MagicTodoWidget extends ConsumerStatefulWidget {
  const MagicTodoWidget({super.key});

  @override
  ConsumerState<MagicTodoWidget> createState() => _MagicTodoWidgetState();
}

class _MagicTodoWidgetState extends ConsumerState<MagicTodoWidget> {
  final TextEditingController _inputController = TextEditingController();
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _dummyResponses = [
    {
      'input': '프로젝트 마감 준비',
      'todos': [
        {
          'title': '요구사항 문서 검토',
          'quadrant': 'do_first',
          'priority': 1,
          'reason': '프로젝트의 기본이 되는 요구사항을 먼저 확인해야 합니다.',
        },
        {
          'title': '팀원들과 진행상황 미팅',
          'quadrant': 'schedule',
          'priority': 2,
          'reason': '전체 진행상황을 파악하고 다음 단계를 계획해야 합니다.',
        },
        {
          'title': '테스트 계획 수립',
          'quadrant': 'delegate',
          'priority': 3,
          'reason': 'QA팀에 전달할 테스트 계획을 준비합니다.',
        },
      ],
    },
    {
      'input': '웹사이트 리뉴얼',
      'todos': [
        {
          'title': '디자인 시안 검토',
          'quadrant': 'do_first',
          'priority': 1,
          'reason': '디자인이 전체 개발의 기준이 됩니다.',
        },
        {
          'title': '개발 일정 수립',
          'quadrant': 'schedule',
          'priority': 2,
          'reason': '팀원들의 작업 일정을 조율해야 합니다.',
        },
        {
          'title': '콘텐츠 작성',
          'quadrant': 'delegate',
          'priority': 3,
          'reason': '콘텐츠 팀에 전달할 내용을 준비합니다.',
        },
      ],
    },
  ];

  Future<void> _processInput() async {
    setState(() {
      _isProcessing = true;
    });
    final input = _inputController.text.trim();
    // 실제 Gemini 기반 매직투두 호출
    try {
      final todos = await MagicTodoService().generateTodos(input);
      ref.read(magicTodoNotifierProvider.notifier).setTodos(todos);
    } catch (e) {
      // 에러 시 더미 데이터 사용
      final random = Random();
      final response = _dummyResponses[random.nextInt(_dummyResponses.length)];
      final todos = List<Map<String, dynamic>>.from(response['todos']);
      ref.read(magicTodoNotifierProvider.notifier).setTodos(todos);
    }
    setState(() {
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todos = ref.watch(magicTodoNotifierProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(loc.magicTodo, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _inputController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: loc.inputHint,
                      prefixIcon: const Icon(Icons.auto_awesome),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                      ),
                    ),
                    minLines: 1,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () {
                            if (_inputController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(loc.inputHint)),
                              );
                              return;
                            }
                            _processInput();
                          },
                    icon: const Icon(Icons.auto_fix_high),
                    label: _isProcessing ? Text(loc.analyzing) : Text(loc.analyze),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (todos.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Theme.of(context).colorScheme.surface,
                    child: ListTile(
                      title: Text(
                        todo['title'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${loc.priority}: ${todo['priority']}'),
                          Text('${loc.reason}: ${todo['reason']}'),
                          Text('${loc.quadrant}: ${_getQuadrantLabel(todo['quadrant'], loc)}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_task),
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () => _addToMatrix(todo),
                        tooltip: loc.addToMatrix,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addToMatrix(Map<String, dynamic> todo) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = prefs.getString('matrix_categories');
    if (categoriesJson != null) {
      final List<dynamic> categories = json.decode(categoriesJson);
      String categoryId = categories.isNotEmpty ? categories.first['id'] : 'default';
      final key = 'todos_$categoryId';
      final list = prefs.getStringList(key) ?? [];
      final newTodo = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': todo['title'],
        'quadrant': todo['quadrant'],
        'isDone': false,
        'priority': todo['priority'],
        'reason': todo['reason'],
      };
      list.add(json.encode(newTodo));
      await prefs.setStringList(key, list);
      await WidgetService.updateTodayTodo(todo['title'], todo['reason']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${todo['title']} ${AppLocalizations.of(context)!.addToMatrix}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _getQuadrantLabel(String quadrant, AppLocalizations loc) {
    switch (quadrant) {
      case 'do_first':
        return loc.do_first;
      case 'schedule':
        return loc.schedule;
      case 'delegate':
        return loc.delegate;
      case 'eliminate':
        return loc.eliminate;
      default:
        return quadrant;
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
} 