import 'package:flutter/cupertino.dart';

class Button extends StatelessWidget {
  final Function()? onTap;
  final String text;
  const Button({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(horizontal: 25.0),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBlue,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
