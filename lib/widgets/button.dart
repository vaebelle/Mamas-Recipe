import 'package:flutter/cupertino.dart';
import 'package:mama_recipe/widgets/sharedPreference.dart';

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
    final isDarkMode = SharedPreferencesHelper.instance.isDarkMode;

    Color finalColor = color;
    Color finalTextColor = textColor;
    BoxBorder? finalBorder = border;

    if (color == CupertinoColors.white && isDarkMode) {
      finalColor = const Color(0xFF2C2C2E);
      finalTextColor = CupertinoColors.white;
      finalBorder = Border.all(color: const Color(0xFF38383A), width: 1.0);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(horizontal: 25.0),
        decoration: BoxDecoration(
          color: finalColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: finalBorder,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: finalTextColor,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
