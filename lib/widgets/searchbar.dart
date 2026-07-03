import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;
  final VoidCallback? onClearTap;
  final bool showFilter;
  final bool showClear;
  final bool readOnly;
  final EdgeInsetsGeometry? margin;
  final Color iconColor;
  final Color filterColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color hintColor;
  final double height;
  final double borderRadius;
  final double fontSize;
  final bool showShadow;

  const SearchBarWidget({
    super.key,
    this.controller,
    this.hintText = 'Cari kost...',
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onFilterTap,
    this.onClearTap,
    this.showFilter = true,
    this.showClear = false,
    this.readOnly = false,
    this.margin,
    this.iconColor = ThemeApp.primaryDark,
    this.filterColor = ThemeApp.primaryDark,
    this.backgroundColor = ThemeApp.white,
    this.borderColor = ThemeApp.borderGrey,
    this.textColor = ThemeApp.textDark,
    this.hintColor = ThemeApp.textGrey,
    this.height = 60,
    this.borderRadius = 36,
    this.fontSize = 19,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: height,
              padding: const EdgeInsets.only(left: 18, right: 18),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: borderColor,
                  width: 1.5,
                ),
                boxShadow: showShadow
                    ? [
                        ThemeApp.softShadow(
                          alpha: 0.07,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: iconColor,
                    size: height >= 56 ? 33 : 28,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      readOnly: readOnly,
                      onTap: onTap,
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: TextStyle(
                          color: hintColor,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                  if (showClear)
                    GestureDetector(
                      onTap: onClearTap,
                      child: Icon(
                        Icons.close_rounded,
                        color: hintColor,
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (showFilter) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: onFilterTap,
              child: Container(
                width: height,
                height: height,
                decoration: BoxDecoration(
                  color: filterColor,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: showShadow
                      ? [
                          BoxShadow(
                            color: filterColor.withValues(alpha: 0.22),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : null,
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: ThemeApp.white,
                  size: 28,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}