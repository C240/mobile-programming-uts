import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/utils/category_utils.dart';

class CategoryAvatar extends StatelessWidget {
  final String category;
  final double radius;

  const CategoryAvatar({super.key, required this.category, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final color = colorForCategory(category);
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Icon(iconForCategory(category), color: color),
    );
  }
}