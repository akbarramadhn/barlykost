import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late List<_NotificationItem> notifications;

  bool showUnreadOnly = false;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    notifications = [
      _NotificationItem(
        id: '1',
        title: 'Pemesanan Dikonfirmasi',
        message:
            'Pembayaran Kost Melati sudah dikonfirmasi. Pemesanan kamu telah aktif.',
        createdAt: now.subtract(const Duration(minutes: 8)),
        type: _NotificationType.success,
        isRead: false,
      ),
      _NotificationItem(
        id: '2',
        title: 'Bagikan Pengalamanmu',
        message:
            'Ceritakan pengalamanmu selama menggunakan Kost Melati dengan memberikan ulasan.',
        createdAt: now.subtract(const Duration(hours: 2)),
        type: _NotificationType.review,
        isRead: false,
      ),
      _NotificationItem(
        id: '3',
        title: 'Bukti Pembayaran Terkirim',
        message:
            'Bukti pembayaran kamu sedang diperiksa oleh admin.',
        createdAt: now.subtract(const Duration(days: 1)),
        type: _NotificationType.payment,
        isRead: true,
      ),
      _NotificationItem(
        id: '4',
        title: 'Pemesanan Berhasil',
        message:
            'Pemesanan Kost Melati berhasil dibuat. Silakan lanjutkan pembayaran.',
        createdAt: now.subtract(const Duration(days: 2)),
        type: _NotificationType.booking,
        isRead: true,
      ),
      _NotificationItem(
        id: '5',
        title: 'Pembayaran Ditolak',
        message:
            'Bukti pembayaran belum dapat diterima. Silakan unggah kembali bukti yang sesuai.',
        createdAt: now.subtract(const Duration(days: 4)),
        type: _NotificationType.rejected,
        isRead: true,
      ),
    ];
  }

  List<_NotificationItem> get visibleNotifications {
    if (!showUnreadOnly) {
      return notifications;
    }

    return notifications
        .where((item) => !item.isRead)
        .toList();
  }

  int get unreadCount {
    return notifications
        .where((item) => !item.isRead)
        .length;
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere(
      (item) => item.id == id,
    );

    if (index == -1 || notifications[index].isRead) {
      return;
    }

    setState(() {
      notifications[index] = notifications[index].copyWith(
        isRead: true,
      );
    });
  }

  void markAllAsRead() {
    if (unreadCount == 0) {
      return;
    }

    setState(() {
      notifications = notifications
          .map(
            (item) => item.copyWith(isRead: true),
          )
          .toList();
    });
  }

  String formatTime(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    }

    if (difference.inDays == 1) {
      return 'Kemarin';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  IconData getNotificationIcon(
    _NotificationType type,
  ) {
    switch (type) {
      case _NotificationType.success:
        return Icons.check_circle_rounded;

      case _NotificationType.review:
        return Icons.star_rounded;

      case _NotificationType.payment:
        return Icons.receipt_long_rounded;

      case _NotificationType.booking:
        return Icons.home_work_rounded;

      case _NotificationType.rejected:
        return Icons.cancel_rounded;
    }
  }

  Color getNotificationColor(
    _NotificationType type,
  ) {
    switch (type) {
      case _NotificationType.success:
        return ThemeApp.successGreen;

      case _NotificationType.review:
        return ThemeApp.starColor;

      case _NotificationType.payment:
        return ThemeApp.locationBlue;

      case _NotificationType.booking:
        return ThemeApp.primaryDark;

      case _NotificationType.rejected:
        return ThemeApp.cancelledRed;
    }
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        18,
        48,
        18,
        16,
      ),
      decoration: BoxDecoration(
        color: ThemeApp.white,
        boxShadow: [
          ThemeApp.softShadow(
            alpha: 0.05,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.pop(context);
            },
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: ThemeApp.textDark,
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Notifikasi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ThemeApp.textDark,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '$unreadCount belum dibaca',
                    style: const TextStyle(
                      color: ThemeApp.textGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: markAllAsRead,
            child: SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                Icons.done_all_rounded,
                color: unreadCount == 0
                    ? ThemeApp.lightGrey
                    : ThemeApp.buttonColor,
                size: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFilterButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? ThemeApp.buttonColor
                : ThemeApp.white,
            borderRadius: ThemeApp.radius(22),
            border: Border.all(
              color: selected
                  ? ThemeApp.buttonColor
                  : ThemeApp.borderGrey,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? ThemeApp.white
                  : ThemeApp.textGrey,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        22,
        22,
        22,
        4,
      ),
      child: Row(
        children: [
          buildFilterButton(
            label: 'Semua',
            selected: !showUnreadOnly,
            onTap: () {
              setState(() {
                showUnreadOnly = false;
              });
            },
          ),
          const SizedBox(width: 12),
          buildFilterButton(
            label: 'Belum Dibaca',
            selected: showUnreadOnly,
            onTap: () {
              setState(() {
                showUnreadOnly = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget buildNotificationCard(
    _NotificationItem item,
  ) {
    final color = getNotificationColor(item.type);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        markAsRead(item.id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeApp.white,
          borderRadius: ThemeApp.radius(22),
          border: Border.all(
            color: item.isRead
                ? ThemeApp.white
                : ThemeApp.primaryLight,
          ),
          boxShadow: [
            ThemeApp.softShadow(
              alpha: item.isRead ? 0.05 : 0.09,
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                getNotificationIcon(item.type),
                color: color,
                size: 27,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: ThemeApp.textDark,
                            fontSize: 16,
                            fontWeight: item.isRead
                                ? FontWeight.w700
                                : FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                      ),
                      if (!item.isRead) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 9,
                          height: 9,
                          margin:
                              const EdgeInsets.only(top: 4),
                          decoration: const BoxDecoration(
                            color: ThemeApp.primaryDark,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.message,
                    style: const TextStyle(
                      color: ThemeApp.textGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    formatTime(item.createdAt),
                    style: TextStyle(
                      color: item.isRead
                          ? ThemeApp.textGrey
                          : ThemeApp.primaryDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        22,
        76,
        22,
        100,
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            24,
            46,
            24,
            46,
          ),
          decoration: BoxDecoration(
            color: ThemeApp.white,
            borderRadius: ThemeApp.radius(24),
            boxShadow: [
              ThemeApp.softShadow(
                alpha: 0.06,
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const Column(
            children: [
              Icon(
                Icons.notifications_none_rounded,
                color: ThemeApp.buttonColor,
                size: 68,
              ),
              SizedBox(height: 18),
              Text(
                'Tidak ada notifikasi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ThemeApp.textDark,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Notifikasi terbaru mengenai pemesanan dan pembayaran akan muncul di sini.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ThemeApp.textGrey,
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildNotificationList() {
    final items = visibleNotifications;

    if (items.isEmpty) {
      return buildEmptyState();
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        22,
        18,
        22,
        100,
      ),
      itemCount: items.length,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 14);
      },
      itemBuilder: (context, index) {
        return buildNotificationCard(items[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1),
      ),
      child: Scaffold(
        backgroundColor: ThemeApp.primaryDark,
        body: Column(
          children: [
            buildHeader(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: ThemeApp.backgroundGradient,
                child: Column(
                  children: [
                    buildFilters(),
                    Expanded(
                      child: buildNotificationList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _NotificationType {
  success,
  review,
  payment,
  booking,
  rejected,
}

class _NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final _NotificationType type;
  final bool isRead;

  const _NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.type,
    required this.isRead,
  });

  _NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? createdAt,
    _NotificationType? type,
    bool? isRead,
  }) {
    return _NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}
