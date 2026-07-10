import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/penyewa/app_notification.dart';
import '../../../services/penyewa/notification_service.dart';
import '../history/history_screen.dart';
import '../review/tulis_ulasan.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState
    extends State<NotificationScreen> {
  final NotificationService notificationService =
      NotificationService();

  late Future<List<AppNotification>>
      notificationFuture;

  bool showActionOnly = false;

  @override
  void initState() {
    super.initState();
    notificationFuture = fetchNotifications();
  }

  Future<List<AppNotification>>
      fetchNotifications() {
    return notificationService
        .getCurrentUserNotifications();
  }

  Future<void> refreshData() async {
    final newFuture = fetchNotifications();

    setState(() {
      notificationFuture = newFuture;
    });

    await newFuture;
  }

  Future<void> openNotification(
    AppNotification item,
  ) async {
    if (item.type == AppNotificationType.review) {
      final bool? created =
          await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) {
            return TulisUlasanScreen(
              bookingId: item.bookingId,
              kostId: item.kostId,
              kostName: item.kostName,
            );
          },
        ),
      );

      if (created == true && mounted) {
        await refreshData();
      }

      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HistoryScreen(),
      ),
    );

    if (mounted) {
      await refreshData();
    }
  }

  IconData getNotificationIcon(
    AppNotificationType type,
  ) {
    switch (type) {
      case AppNotificationType.pendingPayment:
        return Icons.account_balance_wallet_rounded;

      case AppNotificationType.waitingVerification:
        return Icons.hourglass_top_rounded;

      case AppNotificationType.confirmed:
        return Icons.check_circle_rounded;

      case AppNotificationType.rejected:
        return Icons.cancel_rounded;

      case AppNotificationType.cancelled:
        return Icons.event_busy_rounded;

      case AppNotificationType.completed:
        return Icons.task_alt_rounded;

      case AppNotificationType.review:
        return Icons.star_rounded;
    }
  }

  Color getNotificationColor(
    AppNotificationType type,
  ) {
    switch (type) {
      case AppNotificationType.pendingPayment:
      case AppNotificationType.waitingVerification:
        return ThemeApp.pendingOrange;

      case AppNotificationType.confirmed:
      case AppNotificationType.completed:
        return ThemeApp.successGreen;

      case AppNotificationType.rejected:
      case AppNotificationType.cancelled:
        return ThemeApp.cancelledRed;

      case AppNotificationType.review:
        return ThemeApp.starColor;
    }
  }

  String formatTime(DateTime date) {
    final difference =
        DateTime.now().difference(date);

    if (difference.isNegative) {
      return formatDate(date);
    }

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

    return formatDate(date);
  }

  String formatDate(DateTime date) {
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

  Widget buildHeader(int notificationCount) {
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
                const SizedBox(height: 2),
                Text(
                  '$notificationCount pembaruan',
                  style: const TextStyle(
                    color: ThemeApp.textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: refreshData,
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                Icons.refresh_rounded,
                color: ThemeApp.buttonColor,
                size: 26,
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
          duration:
              const Duration(milliseconds: 180),
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
            selected: !showActionOnly,
            onTap: () {
              setState(() {
                showActionOnly = false;
              });
            },
          ),
          const SizedBox(width: 12),
          buildFilterButton(
            label: 'Perlu Tindakan',
            selected: showActionOnly,
            onTap: () {
              setState(() {
                showActionOnly = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget buildNotificationCard(
    AppNotification item,
  ) {
    final Color color =
        getNotificationColor(item.type);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        openNotification(item);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeApp.white,
          borderRadius: ThemeApp.radius(22),
          border: Border.all(
            color: item.requiresAction
                ? ThemeApp.primaryLight
                : ThemeApp.white,
          ),
          boxShadow: [
            ThemeApp.softShadow(
              alpha: 0.07,
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
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
                          style: const TextStyle(
                            color: ThemeApp.textDark,
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                      ),
                      if (item.requiresAction) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 9,
                          height: 9,
                          margin: const EdgeInsets.only(
                            top: 4,
                          ),
                          decoration:
                              const BoxDecoration(
                            color:
                                ThemeApp.primaryDark,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatTime(
                            item.createdAt,
                          ),
                          style: const TextStyle(
                            color: ThemeApp.textGrey,
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        item.type ==
                                AppNotificationType
                                    .review
                            ? 'Tulis Ulasan'
                            : 'Lihat Riwayat',
                        style: const TextStyle(
                          color:
                              ThemeApp.locationBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: ThemeApp.locationBlue,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState({
    required String title,
    required String message,
  }) {
    return RefreshIndicator(
      color: ThemeApp.buttonColor,
      onRefresh: refreshData,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
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
            child: Column(
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: ThemeApp.buttonColor,
                  size: 68,
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: ThemeApp.textDark,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
      ),
    );
  }

  Widget buildErrorState(String message) {
    return buildEmptyState(
      title: 'Gagal memuat notifikasi',
      message: message,
    );
  }

  Widget buildNotificationList(
    List<AppNotification> notifications,
  ) {
    final List<AppNotification> visibleItems =
        showActionOnly
            ? notifications
                .where(
                  (item) => item.requiresAction,
                )
                .toList()
            : notifications;

    if (visibleItems.isEmpty) {
      return buildEmptyState(
        title: showActionOnly
            ? 'Tidak ada tindakan'
            : 'Belum ada notifikasi',
        message: showActionOnly
            ? 'Semua pemesanan kamu sudah tidak memerlukan tindakan.'
            : 'Pembaruan pemesanan dan pembayaran akan muncul di sini.',
      );
    }

    return RefreshIndicator(
      color: ThemeApp.buttonColor,
      onRefresh: refreshData,
      child: ListView.separated(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          22,
          18,
          22,
          100,
        ),
        itemCount: visibleItems.length,
        separatorBuilder: (context, index) {
          return const SizedBox(height: 14);
        },
        itemBuilder: (context, index) {
          return buildNotificationCard(
            visibleItems[index],
          );
        },
      ),
    );
  }

  String getErrorMessage(Object? error) {
    final String message =
        error?.toString() ?? '';

    if (message.startsWith('Exception: ')) {
      return message.replaceFirst(
        'Exception: ',
        '',
      );
    }

    if (message.trim().isEmpty) {
      return 'Terjadi kesalahan saat mengambil data notifikasi.';
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1),
      ),
      child: FutureBuilder<List<AppNotification>>(
        future: notificationFuture,
        builder: (context, snapshot) {
          final int count =
              snapshot.data?.length ?? 0;

          return Scaffold(
            backgroundColor: ThemeApp.primaryDark,
            body: Column(
              children: [
                buildHeader(count),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration:
                        ThemeApp.backgroundGradient,
                    child: snapshot.connectionState ==
                            ConnectionState.waiting
                        ? const Center(
                            child:
                                CircularProgressIndicator(
                              color:
                                  ThemeApp.buttonColor,
                            ),
                          )
                        : snapshot.hasError
                            ? buildErrorState(
                                getErrorMessage(
                                  snapshot.error,
                                ),
                              )
                            : Column(
                                children: [
                                  buildFilters(),
                                  Expanded(
                                    child:
                                        buildNotificationList(
                                      snapshot.data ??
                                          [],
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
