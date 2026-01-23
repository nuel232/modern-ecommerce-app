import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final BorderRadiusGeometry? borderRadius;
  final TextStyle? textStyle;

  const MyButton({
    super.key,
    required this.text,
    required this.onTap,
    this.borderRadius,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.primary,
        ),
        margin: EdgeInsets.symmetric(horizontal: 25),
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(text, style: textStyle ?? TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
