import 'package:flutter/material.dart';

class ColoredTab extends Container implements PreferredSizeWidget {
  ColoredTab({required this.color, required this.child, super.key});

  @override
  final Color color;
  final Tab child;

  @override
  Size get preferredSize => child.preferredSize;

  @override
  Widget build(BuildContext context) => Container(
    color: color,
    child: child,
  );
}