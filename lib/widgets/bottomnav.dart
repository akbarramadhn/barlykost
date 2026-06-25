import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int index) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const Color darkTeal = ThemeApp.buttonColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildNavItem(
              index: 0,
              icon: Icons.home_rounded,
            ),
            buildNavItem(
              index: 1,
              icon: Icons.search_rounded,
            ),
            buildNavItem(
              index: 2,
              icon: Icons.history_rounded,
            ),
            buildNavItem(
              index: 3,
              icon: Icons.person_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNavItem({
    required int index,
    required IconData icon,
  }) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onTap(index);
      },
      child: SizedBox(
        width: 64,
        height: 64,
        child: Center(
          child: Icon(
            icon,
            size: 38,
            color: isActive ? darkTeal : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}