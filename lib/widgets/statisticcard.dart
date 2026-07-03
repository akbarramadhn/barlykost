import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color? iconBackgroundColor;
  final String? subtitle;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final double height;
  final double borderRadius;
  final bool showShadow;
  final bool showBorder;
  final bool circularIcon;
  final double iconSize;
  final double iconBoxSize;
  final double valueFontSize;
  final double titleFontSize;
  final double subtitleFontSize;

  const StatisticCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color = ThemeApp.primaryDark,
    this.iconBackgroundColor,
    this.subtitle,
    this.onTap,
    this.margin,
    this.height = 108,
    this.borderRadius = 22,
    this.showShadow = true,
    this.showBorder = false,
    this.circularIcon = false,
    this.iconSize = 25,
    this.iconBoxSize = 48,
    this.valueFontSize = 20,
    this.titleFontSize = 12.5,
    this.subtitleFontSize = 11.5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeApp.white,
              borderRadius: BorderRadius.circular(borderRadius),
              border: showBorder
                  ? Border.all(
                      color: ThemeApp.adminCardBorder,
                      width: 1.2,
                    )
                  : null,
              boxShadow: showShadow
                  ? [
                      ThemeApp.softShadow(
                        alpha: 0.07,
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: iconBoxSize,
                  height: iconBoxSize,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor ??
                        color.withValues(alpha: 0.14),
                    shape:
                        circularIcon ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius:
                        circularIcon ? null : BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: iconSize,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ThemeApp.textDark,
                          fontSize: valueFontSize,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ThemeApp.textGrey,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          height: 1.12,
                        ),
                      ),
                      if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: color,
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}