import 'package:flutter/material.dart';
import 'widgets/social_login_button.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Color(0xFF181818) : Color(0xFFF7F7F7),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'matrix\ntodo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 48),
              SocialLoginButton(type: SocialType.google),
              const SizedBox(height: 16),
              SocialLoginButton(type: SocialType.kakao),
              const SizedBox(height: 16),
              SocialLoginButton(type: SocialType.apple),
              const SizedBox(height: 16),
              SocialLoginButton(type: SocialType.email),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isLoading;

  const _SocialLoginButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor:
              color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
          textStyle: const TextStyle(fontSize: 16),
        ),
        icon: isLoading
            ? const SizedBox(
                width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(isLoading ? '잠시만 기다려주세요...' : label),
        onPressed: isLoading ? null : onPressed,
      ),
    );
  }
}