import 'package:flutter/cupertino.dart';
import 'package:mama_recipe/widgets/sharedPreference.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Button extends StatelessWidget {
  final Function()? onTap;
  final String text;
  final Color? color;
  final Color? textColor;
  final double? borderRadius;
  final Border? border;
  final String? iconPath; // Add this parameter for icon support

  const Button({
    super.key,
    required this.onTap,
    required this.text,
    this.color,
    this.textColor,
    this.borderRadius = 12.0,
    this.border,
    this.iconPath, // Add this parameter
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = SharedPreferencesHelper.instance.isDarkMode;

    Color finalColor = color ?? CupertinoColors.black;
    Color finalTextColor = textColor ?? CupertinoColors.white;
    BoxBorder? finalBorder = border;

    if (color == CupertinoColors.white && isDarkMode) {
      finalColor = const Color(0xFF2C2C2E);
      finalTextColor = CupertinoColors.white;
      finalBorder = Border.all(color: const Color(0xFF38383A), width: 1.0);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 11,
          horizontal: 20,
        ), // REDUCED PADDING
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: finalColor,
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          border: finalBorder,
        ),
        child: Center(
          child: iconPath != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(iconPath!, width: 20, height: 20),
                    const SizedBox(width: 10),
                    Text(
                      text,
                      style: TextStyle(
                        color: finalTextColor,
                        fontWeight:
                            FontWeight.w500, // REVERTED TO ORIGINAL BOLD
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
              : Text(
                  text,
                  style: TextStyle(
                    color: finalTextColor,
                    fontWeight: FontWeight.w500, // REVERTED TO ORIGINAL BOLD
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}
