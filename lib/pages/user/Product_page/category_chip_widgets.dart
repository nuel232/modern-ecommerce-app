import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CategoryChipWidgets extends StatelessWidget {
  final String categoryId;
  final String categoryName;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChipWidgets({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
