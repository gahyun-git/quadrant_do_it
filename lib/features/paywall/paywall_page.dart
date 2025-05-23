import 'package:flutter/material.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프리미엄 구독')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('7일 무료 체험 후 구독 전환', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                title: const Text('월간 구독'),
                subtitle: const Text('매월 자동 결제'),
                trailing: const Text('₩4,900'),
                onTap: () {},
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('연간 구독'),
                subtitle: const Text('연간 결제, 33% 할인'),
                trailing: const Text('₩39,900'),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 24),
            const Text('프리미엄 기능', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('- 무제한 프로젝트\n- 고급 AI 작업 분해\n- 캘린더 연동\n- 위젯 및 키스톤기능 등'),
          ],
        ),
      ),
    );
  }
} 