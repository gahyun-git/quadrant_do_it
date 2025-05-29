import 'package:flutter/material.dart';
import 'package:quadrant_do_it/core/animations/animation_utils.dart';

class AnimatedListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const AnimatedListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationUtils.createScaleAnimation(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
} 