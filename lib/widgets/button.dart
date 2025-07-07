import 'package:flutter/cupertino.dart';

class Button extends StatelessWidget {
  final Function()? onTap;
  final String text;
  final borderRadius;
  final color;
  final textColor;
  final BoxBorder? border;
  const Button({
    super.key,
    required this.onTap,
    required this.text,
    this.borderRadius = 12.0,
    this.color = CupertinoColors.systemBlue,
    this.textColor = CupertinoColors.white,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(horizontal: 25.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
