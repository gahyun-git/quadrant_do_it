import 'package:flutter/material.dart';

class AnimatedFabMenu extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onToggle;
  final List<FabMenuItem> items;
  final VoidCallback? onItemSelected;

  const AnimatedFabMenu({
    super.key,
    required this.isOpen,
    required this.onToggle,
    required this.items,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isOpen) ...[
          ...List.generate(items.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildMenuItem(context, items[index], index),
            );
          }),
        ],
        FloatingActionButton(
          heroTag: 'menu',
          onPressed: onToggle,
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 300),
            turns: isOpen ? 0.5 : 0,
            child: const Icon(Icons.menu),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, FabMenuItem item, int index) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 200 + (index * 50)),
      opacity: isOpen ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: Duration(milliseconds: 200 + (index * 50)),
        offset: isOpen ? Offset.zero : const Offset(0, 0.5),
        child: FloatingActionButton(
          heroTag: item.heroTag,
          onPressed: () {
            item.onPressed();
            onItemSelected?.call();
          },
          child: item.icon,
        ),
      ),
    );
  }
}

class FabMenuItem {
  final String heroTag;
  final Widget icon;
  final VoidCallback onPressed;

  const FabMenuItem({
    required this.heroTag,
    required this.icon,
    required this.onPressed,
  });
} 