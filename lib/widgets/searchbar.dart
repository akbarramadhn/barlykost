import 'package:flutter/material.dart';

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
  });

  static const Color primaryDark = Color(0xFF10776F);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textGrey = Color(0xFF777777);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 60,
              padding: const EdgeInsets.only(left: 18, right: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(36),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: primaryDark,
                    size: 33,
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
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: const TextStyle(
                          color: textGrey,
                          fontSize: 19,
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
                      child: const Icon(
                        Icons.close_rounded,
                        color: textGrey,
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: primaryDark,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: primaryDark.withValues(alpha: 0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
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