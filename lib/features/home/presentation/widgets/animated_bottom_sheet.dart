import 'package:flutter/material.dart';
import 'package:quadrant_do_it/core/animations/animation_utils.dart';

class AnimatedBottomSheet extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;

  const AnimatedBottomSheet({
    super.key,
    required this.child,
    required this.title,
    this.actions,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    required String title,
    List<Widget>? actions,
  }) {
    return AnimationUtils.showAnimatedBottomSheet<T>(
      context: context,
      child: AnimatedBottomSheet(
        title: title,
        actions: actions,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 헤더
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                if (actions != null) ...actions!,
              ],
            ),
          ),
          const Divider(),
          // 컨텐츠
          Flexible(child: child),
        ],
      ),
    );
  }
} 