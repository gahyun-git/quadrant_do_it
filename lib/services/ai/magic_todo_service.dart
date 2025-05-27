import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/magic_todo/providers/magic_todo_provider.dart';

/// Gemini 기반 매직투두 서비스 구현
class MagicTodoService implements MagicTodoAIService {
  // TODO: 여기에 실제 Gemini API Key를 입력하세요.
  static const String _apiKey = 'YOUR_GEMINI_API_KEY'; // <-- 실제 키 입력
  static const String _endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=';

  @override
  Future<List<Map<String, dynamic>>> generateTodos(String input) async {
    if (input.trim().isEmpty) return [];
    final prompt =
        '아래 입력을 아이젠하워 매트릭스(중요&긴급, 중요&비긴급, 비중요&긴급, 비중요&비긴급) 기준으로 3~5개의 할일로 분류해서 JSON 배열로 반환해줘. 각 할일은 title, quadrant, priority(1~5), reason 필드를 포함해야 해.\n입력: $input';
    final body = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ]
    };
    final url = Uri.parse('$_endpoint$_apiKey');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      // Gemini 응답에서 JSON 파싱
      try {
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        final todos = json.decode(text);
        if (todos is List) {
          return List<Map<String, dynamic>>.from(todos);
        }
      } catch (e) {
        // 파싱 실패 시 빈 리스트 반환
        return [];
      }
    }
    return [];
  }
} 