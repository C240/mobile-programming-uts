import 'package:flutter/material.dart';
import 'package:mobile_programming_uts/utils/category_utils.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorForCategory(label);
    return FilterChip(
      label: Text(label),
      avatar: Icon(iconForCategory(label), color: color),
      selected: selected,
      selectedColor: color.withValues(alpha: 0.16),
      onSelected: onSelected,
    );
  }
}