import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mama_recipe/widgets/sharedPreference.dart';

class CustomTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  final double borderRadius;
  final String pathName;
  final double iconSize;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.borderRadius = 12.0,
    this.pathName = ' ',
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = SharedPreferencesHelper.instance.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color(0xFF2C2C2E)
              : CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: CupertinoColors.systemGrey4, width: 1.0),
        ),
        child: CupertinoTextField(
          controller: controller,
          obscureText: obscureText,
          placeholder: hintText,
          placeholderStyle: TextStyle(
            color: isDarkMode
                ? const Color(0xFFAEAEB2)
                : CupertinoColors.systemGrey2,
          ),
          style: TextStyle(
            color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          prefix: pathName != ' '
              ? Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: SvgPicture.asset(
                    pathName,
                    width: iconSize,
                    height: iconSize,
                    color: isDarkMode
                        ? const Color(0xFFAEAEB2)
                        : CupertinoColors.systemGrey2,
                  ),
                )
              : null,
          decoration: null,
        ),
      ),
    );
  }
}
