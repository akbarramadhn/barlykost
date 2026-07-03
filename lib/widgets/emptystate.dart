import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonTap;
  final EdgeInsetsGeometry? padding;
  final Color iconColor;
  final Color? iconBackgroundColor;
  final Color titleColor;
  final Color messageColor;
  final Color buttonColor;
  final double iconSize;
  final double iconBoxSize;
  final double titleFontSize;
  final double messageFontSize;
  final bool compact;

  const EmptyState({
    super.key,
    this.icon = Icons.inbox_rounded,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonTap,
    this.padding,
    this.iconColor = ThemeApp.primaryDark,
    this.iconBackgroundColor,
    this.titleColor = ThemeApp.textDark,
    this.messageColor = ThemeApp.textGrey,
    this.buttonColor = ThemeApp.buttonColor,
    this.iconSize = 42,
    this.iconBoxSize = 86,
    this.titleFontSize = 18,
    this.messageFontSize = 13.5,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 28),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? iconBoxSize * 0.82 : iconBoxSize,
              height: compact ? iconBoxSize * 0.82 : iconBoxSize,
              decoration: BoxDecoration(
                color: iconBackgroundColor ??
                    iconColor.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: compact ? iconSize * 0.84 : iconSize,
              ),
            ),
            SizedBox(height: compact ? 12 : 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: titleColor,
                fontSize: compact ? titleFontSize - 1 : titleFontSize,
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: messageColor,
                fontSize: compact ? messageFontSize - 0.5 : messageFontSize,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
            if (buttonText != null && buttonText!.trim().isNotEmpty) ...[
              SizedBox(height: compact ? 16 : 20),
              SizedBox(
                height: compact ? 42 : 46,
                child: ElevatedButton(
                  onPressed: onButtonTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: ThemeApp.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    buttonText!,
                    style: TextStyle(
                      fontSize: compact ? 13 : 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}