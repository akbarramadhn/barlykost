import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  final Color color;
  final Color iconBackgroundColor;

  final double? height;
  final double borderRadius;
  final double iconBoxSize;
  final double iconSize;
  final double titleFontSize;
  final double subtitleFontSize;
  final double valueFontSize;

  final bool showShadow;
  final bool showBorder;
  final bool circularIcon;

  const StatisticCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.iconBackgroundColor,
    this.height,
    this.borderRadius = 20,
    this.iconBoxSize = 50,
    this.iconSize = 27,
    this.titleFontSize = 14,
    this.subtitleFontSize = 13.5,
    this.valueFontSize = 21,
    this.showShadow = false,
    this.showBorder = true,
    this.circularIcon = true,
  });

  Widget _buildIcon() {
    return Container(
      width: iconBoxSize,
      height: iconBoxSize,
      decoration: BoxDecoration(
        color: iconBackgroundColor,
        shape: circularIcon ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circularIcon
            ? null
            : BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: iconSize,
        color: color,
      ),
    );
  }

  Widget _buildValue() {
    return SizedBox(
      width: double.infinity,
      height: 28,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          value,
          maxLines: 1,
          style: TextStyle(
            color: ThemeApp.adminTitle,
            fontSize: valueFontSize,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      maxLines: 2,
      softWrap: true,
      overflow: TextOverflow.visible,
      style: TextStyle(
        color: ThemeApp.textGrey,
        fontSize: titleFontSize,
        fontWeight: FontWeight.w700,
        height: 1.15,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      subtitle,
      maxLines: 2,
      softWrap: true,
      overflow: TextOverflow.visible,
      style: TextStyle(
        color: color,
        fontSize: subtitleFontSize,
        fontWeight: FontWeight.w800,
        height: 1.15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 15,
      ),
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
                  alpha: 0.06,
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildIcon(),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildValue(),
                const SizedBox(height: 5),
                _buildTitle(),
                const SizedBox(height: 5),
                _buildSubtitle(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}