import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonTap;
  final EdgeInsetsGeometry? padding;

  const EmptyState({
    super.key,
    this.icon = Icons.inbox_rounded,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonTap,
    this.padding,
  });

  static const Color primaryDark = Color(0xFF10776F);
  static const Color primaryLight = Color(0xFF5CE7D1);
  static const Color buttonColor = Color(0xFF003B63);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textGrey = Color(0xFF777777);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 28),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: primaryLight.withValues(alpha: 0.20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: primaryDark,
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textDark,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textGrey,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
            if (buttonText != null && buttonText!.trim().isNotEmpty) ...[
              const SizedBox(height: 20),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: onButtonTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    buttonText!,
                    style: const TextStyle(
                      fontSize: 13.5,
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