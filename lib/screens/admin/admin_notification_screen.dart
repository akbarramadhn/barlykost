import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/admin/admin_notification.dart';
import '../../services/admin/admin_notification_service.dart';
import '../../screens/admin/detailpemesanan.dart';
import '../../screens/admin/verifikasipembayaran.dart';

class AdminNotificationScreen extends StatefulWidget {
  const AdminNotificationScreen({super.key});

  @override
  State<AdminNotificationScreen> createState() =>
      _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends State<AdminNotificationScreen> {
  final AdminNotificationService _notificationService =
      AdminNotificationService();

  late Future<List<AdminNotification>> _notificationFuture;

  bool _showActionOnly = false;

  @override
  void initState() {
    super.initState();
    _notificationFuture = _notificationService.getAdminNotifications();
  }

  Future<void> _refreshData() async {
    final Future<List<AdminNotification>> newFuture = _notificationService
        .getAdminNotifications();

    setState(() {
      _notificationFuture = newFuture;
    });

    await newFuture;
  }

  Future<void> _openNotification(AdminNotification item) async {
    final bool? changed;

    if (item.type == AdminNotificationType.paymentVerification) {
      changed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AdminPaymentVerificationScreen(bookingId: item.bookingId),
        ),
      );
    } else {
      changed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => AdminBookingDetailScreen(bookingId: item.bookingId),
        ),
      );
    }

    if (changed == true && mounted) {
      await _refreshData();
    }
  }

  IconData _notificationIcon(AdminNotificationType type) {
    switch (type) {
      case AdminNotificationType.paymentVerification:
        return Icons.fact_check_rounded;

      case AdminNotificationType.newBooking:
        return Icons.assignment_rounded;

      case AdminNotificationType.confirmed:
        return Icons.check_circle_rounded;

      case AdminNotificationType.rejected:
        return Icons.cancel_rounded;

      case AdminNotificationType.cancelled:
        return Icons.event_busy_rounded;

      case AdminNotificationType.completed:
        return Icons.task_alt_rounded;
    }
  }

  Color _notificationColor(AdminNotificationType type) {
    switch (type) {
      case AdminNotificationType.paymentVerification:
        return ThemeApp.adminOrange;

      case AdminNotificationType.newBooking:
        return ThemeApp.adminPurple;

      case AdminNotificationType.confirmed:
        return ThemeApp.adminGreen;

      case AdminNotificationType.rejected:
      case AdminNotificationType.cancelled:
        return ThemeApp.adminRed;

      case AdminNotificationType.completed:
        return ThemeApp.adminBlue;
    }
  }

  Color _notificationBackground(AdminNotificationType type) {
    switch (type) {
      case AdminNotificationType.paymentVerification:
        return ThemeApp.adminSoftOrange;

      case AdminNotificationType.newBooking:
        return ThemeApp.adminSoftPurple;

      case AdminNotificationType.confirmed:
        return ThemeApp.adminSoftGreen;

      case AdminNotificationType.rejected:
      case AdminNotificationType.cancelled:
        return ThemeApp.adminSoftRed;

      case AdminNotificationType.completed:
        return ThemeApp.adminSoftBlue;
    }
  }

  String _formatTime(DateTime date) {
    final Duration difference = DateTime.now().difference(date);

    if (difference.isNegative) {
      return _formatDate(date);
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

    return _formatDate(date);
  }

  String _formatDate(DateTime date) {
    const List<String> months = [
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

  String _errorMessage(Object? error) {
    final String message = error?.toString().trim() ?? '';

    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }

    if (message.isEmpty) {
      return 'Terjadi kesalahan saat mengambil notifikasi admin.';
    }

    return message;
  }

  Widget _buildHeader(int actionCount) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          borderRadius: ThemeApp.radius(20),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: ThemeApp.adminTitle,
              size: 21,
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              const Text(
                'Notifikasi Admin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ThemeApp.adminTitle,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (actionCount > 0) ...[
                const SizedBox(height: 3),
                Text(
                  '$actionCount perlu tindakan',
                  style: const TextStyle(
                    color: ThemeApp.adminSubtitle,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        InkWell(
          onTap: _refreshData,
          borderRadius: ThemeApp.radius(20),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              Icons.refresh_rounded,
              color: ThemeApp.buttonColor,
              size: 25,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: ThemeApp.radius(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? ThemeApp.buttonColor : ThemeApp.white,
            borderRadius: ThemeApp.radius(24),
            border: Border.all(
              color: selected ? ThemeApp.buttonColor : ThemeApp.adminCardBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? ThemeApp.white : ThemeApp.adminSubtitle,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        _buildFilterButton(
          label: 'Semua',
          selected: !_showActionOnly,
          onTap: () {
            setState(() {
              _showActionOnly = false;
            });
          },
        ),
        const SizedBox(width: 12),
        _buildFilterButton(
          label: 'Perlu Tindakan',
          selected: _showActionOnly,
          onTap: () {
            setState(() {
              _showActionOnly = true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildNotificationCard(AdminNotification item) {
    final Color color = _notificationColor(item.type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _openNotification(item);
        },
        borderRadius: ThemeApp.radius(22),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: ThemeApp.white,
            borderRadius: ThemeApp.radius(22),
            border: Border.all(
              color: item.requiresAction
                  ? color.withValues(alpha: 0.45)
                  : ThemeApp.adminCardBorder,
              width: item.requiresAction ? 1.3 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _notificationBackground(item.type),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _notificationIcon(item.type),
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              color: ThemeApp.adminTitle,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              height: 1.25,
                            ),
                          ),
                        ),
                        if (item.requiresAction) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 9,
                            height: 9,
                            margin: const EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(
                              color: color,
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
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 11),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatTime(item.createdAt),
                            style: const TextStyle(
                              color: ThemeApp.adminSubtitle,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          item.requiresAction ? 'Verifikasi' : 'Lihat Detail',
                          style: TextStyle(
                            color: color,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: color,
                          size: 19,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required String message,
    IconData icon = Icons.notifications_none_rounded,
  }) {
    return RefreshIndicator(
      color: ThemeApp.buttonColor,
      onRefresh: _refreshData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 72),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 42, 24, 42),
            decoration: BoxDecoration(
              color: ThemeApp.white,
              borderRadius: ThemeApp.radius(22),
              border: Border.all(color: ThemeApp.adminCardBorder),
            ),
            child: Column(
              children: [
                Icon(icon, color: ThemeApp.adminPurple, size: 64),
                const SizedBox(height: 17),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: ThemeApp.adminTitle,
                    fontSize: 18,
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<AdminNotification> notifications) {
    final List<AdminNotification> visibleItems = _showActionOnly
        ? notifications
              .where((AdminNotification item) => item.requiresAction)
              .toList()
        : notifications;

    if (visibleItems.isEmpty) {
      return _buildEmptyState(
        title: _showActionOnly ? 'Tidak ada tindakan' : 'Belum ada notifikasi',
        message: _showActionOnly
            ? 'Semua pembayaran yang masuk sudah selesai diperiksa.'
            : 'Pemesanan dan pembayaran terbaru akan muncul di halaman ini.',
      );
    }

    return RefreshIndicator(
      color: ThemeApp.buttonColor,
      onRefresh: _refreshData,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 18, bottom: 30),
        itemCount: visibleItems.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: 14);
        },
        itemBuilder: (BuildContext context, int index) {
          return _buildNotificationCard(visibleItems[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeApp.white,
      body: SafeArea(
        child: FutureBuilder<List<AdminNotification>>(
          future: _notificationFuture,
          builder:
              (
                BuildContext context,
                AsyncSnapshot<List<AdminNotification>> snapshot,
              ) {
                final List<AdminNotification> notifications =
                    snapshot.data ?? [];

                final int actionCount = notifications
                    .where((AdminNotification item) => item.requiresAction)
                    .length;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    children: [
                      _buildHeader(actionCount),
                      const SizedBox(height: 24),
                      _buildFilters(),
                      const SizedBox(height: 4),
                      Expanded(
                        child:
                            snapshot.connectionState == ConnectionState.waiting
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: ThemeApp.buttonColor,
                                ),
                              )
                            : snapshot.hasError
                            ? _buildEmptyState(
                                title: 'Gagal memuat notifikasi',
                                message: _errorMessage(snapshot.error),
                                icon: Icons.error_outline_rounded,
                              )
                            : _buildNotificationList(notifications),
                      ),
                    ],
                  ),
                );
              },
        ),
      ),
    );
  }
}
