import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// 카카오 로그인 패키지: flutter_kakao_login 또는 kakao_flutter_sdk
// import 'package:flutter_kakao_login/flutter_kakao_login.dart';
// 이메일 로그인은 firebase_auth 등 사용 가능

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
        onPressed: () async {
          switch (type) {
            case SocialType.google:
              // TODO: 실제 Google OAuth 연동
              // GoogleSignIn _googleSignIn = GoogleSignIn(
              //   clientId: 'YOUR_GOOGLE_CLIENT_ID', // <-- 여기에 실제 클라이언트 ID 입력
              // );
              // final account = await _googleSignIn.signIn();
              // if (account != null) { /* 로그인 성공 처리 */ }
              break;
            case SocialType.kakao:
              // TODO: 실제 Kakao OAuth 연동
              // final kakao = FlutterKakaoLogin();
              // final result = await kakao.logIn();
              // if (result.status == KakaoLoginStatus.loggedIn) { /* 로그인 성공 처리 */ }
              break;
            case SocialType.apple:
              // TODO: 실제 Apple OAuth 연동
              // final credential = await SignInWithApple.getAppleIDCredential(
              //   scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
              // );
              // if (credential != null) { /* 로그인 성공 처리 */ }
              break;
            case SocialType.email:
              // TODO: 이메일 로그인(예: Firebase Auth 등)
              // Navigator.push(context, MaterialPageRoute(builder: (_) => EmailLoginPage()));
              break;
          }
        },
      ),
    );
  }
} 