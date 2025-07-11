import 'package:flutter/cupertino.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool isDestructive;
  final Color? titleColor; // New parameter
  final Color? subtitleColor; // New parameter
  final Color? backgroundColor; // New parameter
  final Color? separatorColor; // New parameter

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.isDestructive = false,
    this.titleColor, // New parameter
    this.subtitleColor, // New parameter
    this.backgroundColor, // New parameter
    this.separatorColor, // New parameter
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: backgroundColor != null
            ? BoxDecoration(
                color: backgroundColor,
                border: Border(
                  bottom: BorderSide(
                    color: separatorColor ?? CupertinoColors.separator,
                    width: 0.5,
                  ),
                ),
              )
            : BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: separatorColor ?? CupertinoColors.separator,
                    width: 0.5,
                  ),
                ),
              ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor ?? CupertinoColors.systemBlue,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: CupertinoColors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: isDestructive
                          ? CupertinoColors.systemRed
                          : (titleColor ?? CupertinoColors.label),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor ?? CupertinoColors.secondaryLabel,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (onTap != null && trailing == null)
              Icon(
                CupertinoIcons.chevron_right,
                color:
                    titleColor?.withOpacity(0.6) ??
                    CupertinoColors.tertiaryLabel,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color? backgroundColor; // New parameter
  final Color? titleColor; // New parameter

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.backgroundColor, // New parameter
    this.titleColor, // New parameter
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            backgroundColor ?? CupertinoColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? CupertinoColors.secondaryLabel,
                ),
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}
