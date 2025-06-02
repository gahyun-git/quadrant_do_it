import 'package:flutter/material.dart';

class AnimationUtils {
  // 페이지 전환 애니메이션
  static PageRouteBuilder<T> createPageRoute<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        
        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // 리스트 아이템 스케일 애니메이션
  static Widget createScaleAnimation({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: (_) {
          // 스케일 애니메이션 시작
          child = AnimatedScale(
            scale: 1.05,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            child: child,
          );
        },
        onTapUp: (_) {
          // 스케일 애니메이션 종료
          child = AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            child: child,
          );
        },
        onTap: onTap,
        child: child,
      ),
    );
  }

  // BottomSheet 애니메이션
  static Future<T?> showAnimatedBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => child,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 400),
      ),
    );
  }
} 