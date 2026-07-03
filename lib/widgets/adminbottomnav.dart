import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AdminBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<IconData> icons = [
    Icons.home_rounded,
    Icons.apartment_rounded,
    Icons.assignment_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: const BoxDecoration(
        color: ThemeApp.white,
        border: Border(
          top: BorderSide(
            color: ThemeApp.adminCardBorder,
            width: 1.2,
          ),
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(icons.length, (index) {
            return buildItem(
              index: index,
              icon: icons[index],
              isActive: currentIndex == index,
            );
          }),
        ),
      ),
    );
  }

  Widget buildItem({
    required int index,
    required IconData icon,
    required bool isActive,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onTap(index);
      },
      child: SizedBox(
        width: 64,
        height: 56,
        child: Icon(
          icon,
          color: isActive ? ThemeApp.buttonColor : const Color(0xFFD2D2D2),
          size: 32,
        ),
      ),
    );
  }
}