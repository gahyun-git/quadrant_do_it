import 'package:flutter/material.dart';
import 'package:quadrant_do_it/core/animations/animation_utils.dart';
import 'package:quadrant_do_it/features/home/presentation/widgets/animated_bottom_sheet.dart';
import 'package:quadrant_do_it/features/home/presentation/widgets/animated_list_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('애니메이션 예제'),
      ),
      body: ListView(
        children: [
          AnimatedListItem(
            title: '첫 번째 항목',
            subtitle: '클릭하면 상세 페이지로 이동합니다',
            onTap: () {
              Navigator.of(context).push(
                AnimationUtils.createPageRoute(
                  page: const DetailPage(title: '첫 번째 항목'),
                ),
              );
            },
          ),
          AnimatedListItem(
            title: '두 번째 항목',
            subtitle: '클릭하면 상세 페이지로 이동합니다',
            onTap: () {
              Navigator.of(context).push(
                AnimationUtils.createPageRoute(
                  page: const DetailPage(title: '두 번째 항목'),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AnimatedBottomSheet.show(
            context: context,
            title: '새 항목 추가',
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: '제목',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: '설명',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('저장'),
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String title;

  const DetailPage({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('$title 상세 페이지'),
      ),
    );
  }
} 