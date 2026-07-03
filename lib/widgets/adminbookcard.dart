import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../../models/admin/dashboard.dart';

class AdminBookingCard extends StatelessWidget {
  final AdminBookingSummary booking;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  const AdminBookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final style = booking.statusStyle;

    return Container(
      margin: margin,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
            decoration: BoxDecoration(
              color: ThemeApp.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: ThemeApp.adminCardBorder,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: style.softColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: style.textColor,
                    size: 31,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: buildBookingInfo(),
                ),
                const SizedBox(width: 10),
                buildStatusBadge(),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF9CA0A6),
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBookingInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          booking.userName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: ThemeApp.adminTitle,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          booking.kostName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF555555),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          booking.bookingDateText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF555555),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget buildStatusBadge() {
    final style = booking.statusStyle;

    return Container(
      constraints: const BoxConstraints(
        minWidth: 96,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: style.badgeColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        booking.statusLabel,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: style.textColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.12,
        ),
      ),
    );
  }
}