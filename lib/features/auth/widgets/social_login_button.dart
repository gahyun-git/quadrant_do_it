import 'package:flutter/material.dart';

enum SocialType { google, kakao, apple, email }

class SocialLoginButton extends StatelessWidget {
  final SocialType type;
  const SocialLoginButton({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;
    IconData icon;
    switch (type) {
      case SocialType.google:
        text = 'Google로 계속하기';
        color = Colors.white;
        icon = Icons.g_mobiledata;
        break;
      case SocialType.kakao:
        text = 'Kakao로 계속하기';
        color = Color(0xFFFEE500);
        icon = Icons.chat_bubble;
        break;
      case SocialType.apple:
        text = 'Apple로 계속하기';
        color = Colors.black;
        icon = Icons.apple;
        break;
      case SocialType.email:
        text = '이메일로 계속하기';
        color = Colors.grey;
        icon = Icons.email;
        break;
    }
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: type == SocialType.apple ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        icon: Icon(icon, size: 24),
        label: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        onPressed: () {
          // TODO: 실제 소셜 로그인 연동
        },
      ),
    );
  }
} 