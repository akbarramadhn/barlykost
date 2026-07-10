import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../models/admin/adminbooking.dart';
import '../../models/admin/dashboard.dart';
import '../../services/admin/admin_booking_service.dart';
import '../../services/admin/dashboard_service.dart';
import '../../widgets/adminbottomnav.dart';
import '../../widgets/emptystate.dart';
import '../../widgets/statisticcard.dart';
import '../auth/login_screen.dart';
import 'daftarkost.dart';
import 'pemesanan.dart';
import 'detailpemesanan.dart';
import 'profile_admin.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<void> openBookingDetail(AdminBooking booking) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminBookingDetailScreen(bookingId: booking.id),
      ),
    );

    if (!mounted) {
      return;
    }

    await refreshDashboard();
  }

  final SupabaseClient supabase = Supabase.instance.client;

  final AdminDashboardService dashboardService = AdminDashboardService();

  final AdminBookingService bookingService = AdminBookingService();

  late Future<AdminDashboardData> dashboardFuture;

  late Future<List<AdminBooking>> latestBookingsFuture;

  @override
  void initState() {
    super.initState();

    dashboardFuture = dashboardService.getDashboardData();

    latestBookingsFuture = bookingService.getLatestBookings(limit: 2);
  }

  Future<void> refreshDashboard() async {
    final Future<AdminDashboardData> newDashboardFuture = dashboardService
        .getDashboardData();

    final Future<List<AdminBooking>> newBookingsFuture = bookingService
        .getLatestBookings(limit: 2);

    setState(() {
      dashboardFuture = newDashboardFuture;
      latestBookingsFuture = newBookingsFuture;
    });

    await Future.wait([newDashboardFuture, newBookingsFuture]);
  }

  Future<void> logout() async {
    await supabase.auth.signOut();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void openBookingScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminBookingScreen()),
    );
  }

  void handleBottomNavTap(int index) {
    if (index == 0) {
      return;
    }

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminKostScreen()),
      );
      return;
    }

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminBookingScreen()),
      );
      return;
    }

    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeApp.white,
      body: SafeArea(
        child: FutureBuilder<AdminDashboardData>(
          future: dashboardFuture,
          builder:
              (
                BuildContext context,
                AsyncSnapshot<AdminDashboardData> snapshot,
              ) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return buildLoadingState();
                }

                if (snapshot.hasError) {
                  return buildErrorState();
                }

                final AdminDashboardData data =
                    snapshot.data ?? AdminDashboardData.empty();

                return RefreshIndicator(
                  color: ThemeApp.buttonColor,
                  onRefresh: refreshDashboard,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildHeader(data),
                        const SizedBox(height: 26),
                        buildWelcomeCard(data),
                        const SizedBox(height: 32),
                        buildSectionTitle('Ringkasan'),
                        const SizedBox(height: 16),
                        buildStatisticGrid(data),
                        const SizedBox(height: 34),
                        buildSectionHeader(
                          title: 'Pemesanan Terbaru',
                          actionText: 'Lihat semua',
                          onTap: openBookingScreen,
                        ),
                        const SizedBox(height: 16),
                        buildLatestBookings(),
                      ],
                    ),
                  ),
                );
              },
        ),
      ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: 0,
        onTap: handleBottomNavTap,
      ),
    );
  }

  Widget buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: ThemeApp.buttonColor,
        strokeWidth: 2,
      ),
    );
  }

  Widget buildErrorState() {
    return EmptyState(
      icon: Icons.error_outline_rounded,
      title: 'Dashboard gagal dimuat',
      message: 'Periksa koneksi atau pengaturan akses data admin.',
      buttonText: 'Coba Lagi',
      onButtonTap: refreshDashboard,
      iconColor: ThemeApp.adminRed,
      iconBackgroundColor: ThemeApp.adminSoftRed,
    );
  }

  Widget buildHeader(AdminDashboardData data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  color: ThemeApp.adminTitle,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                data.adminName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ThemeApp.adminSubtitle,
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildWelcomeCard(AdminDashboardData data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [ThemeApp.primaryDark, ThemeApp.primaryLight],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat datang,',
                  style: TextStyle(
                    color: ThemeApp.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.adminName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ThemeApp.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Kelola data kost dan pemesanan dengan mudah.',
                  style: TextStyle(
                    color: ThemeApp.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.22,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.home_work_outlined,
            color: ThemeApp.white.withValues(alpha: 0.35),
            size: 88,
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: ThemeApp.adminTitle,
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget buildSectionHeader({
    required String title,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: ThemeApp.adminTitle,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: const TextStyle(
              color: ThemeApp.adminSubtitle,
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildStatisticGrid(AdminDashboardData data) {
    final List<AdminStatisticSummary> stats = [
      AdminStatisticSummary(
        title: 'Total Kost',
        value: data.totalKost.toString(),
        subtitle: 'Aktif',
        icon: Icons.apartment_rounded,
        iconColor: ThemeApp.adminPurple,
        iconBackground: ThemeApp.adminSoftPurple,
      ),
      AdminStatisticSummary(
        title: 'Total Pesanan',
        value: data.totalPesanan.toString(),
        subtitle: 'Bulan ini',
        icon: Icons.assignment_rounded,
        iconColor: ThemeApp.adminGreen,
        iconBackground: ThemeApp.adminSoftGreen,
      ),
      AdminStatisticSummary(
        title: 'Total User',
        value: data.totalUser.toString(),
        subtitle: 'Aktif',
        icon: Icons.person_outline_rounded,
        iconColor: ThemeApp.adminOrange,
        iconBackground: ThemeApp.adminSoftOrange,
      ),
      AdminStatisticSummary(
        title: 'Pendapatan',
        value: formatNumber(data.totalPendapatanBulanIni),
        subtitle: 'Bulan ini',
        icon: Icons.account_balance_wallet_rounded,
        iconColor: ThemeApp.adminBlue,
        iconBackground: ThemeApp.adminSoftBlue,
      ),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double gap = 12;

        final double cardWidth = (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: stats.map((AdminStatisticSummary statistic) {
            return SizedBox(
              width: cardWidth,
              child: StatisticCard(
                title: statistic.title,
                value: statistic.value,
                subtitle: statistic.subtitle,
                icon: statistic.icon,
                color: statistic.iconColor,
                iconBackgroundColor: statistic.iconBackground,
                height: 148,
                borderRadius: 20,
                showShadow: false,
                showBorder: true,
                circularIcon: true,
                iconBoxSize: 50,
                iconSize: 27,
                titleFontSize: 14,
                subtitleFontSize: 13.5,
                valueFontSize: 21,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget buildLatestBookings() {
    return FutureBuilder<List<AdminBooking>>(
      future: latestBookingsFuture,
      builder:
          (BuildContext context, AsyncSnapshot<List<AdminBooking>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: CircularProgressIndicator(
                    color: ThemeApp.buttonColor,
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return EmptyState(
                icon: Icons.cloud_off_outlined,
                title: 'Pemesanan gagal dimuat',
                message: 'Tarik halaman ke bawah untuk mencoba kembali.',
                iconColor: ThemeApp.adminRed,
                iconBackgroundColor: ThemeApp.adminSoftRed,
                compact: true,
              );
            }

            final List<AdminBooking> bookings =
                snapshot.data ?? <AdminBooking>[];

            if (bookings.isEmpty) {
              return const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Belum ada pesanan',
                message: 'Pesanan terbaru akan tampil di sini.',
                iconColor: ThemeApp.adminPurple,
                iconBackgroundColor: ThemeApp.adminSoftPurple,
                compact: true,
              );
            }

            return Column(
              children: bookings.map((AdminBooking booking) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: buildBookingCard(booking),
                );
              }).toList(),
            );
          },
    );
  }

  Widget buildBookingCard(AdminBooking booking) {
    return Material(
      color: ThemeApp.white,
      borderRadius: ThemeApp.radius(22),
      child: InkWell(
        onTap: () {
          openBookingDetail(booking);
        },
        borderRadius: ThemeApp.radius(22),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 110),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
          decoration: BoxDecoration(
            color: ThemeApp.white,
            borderRadius: ThemeApp.radius(22),
            border: Border.all(color: ThemeApp.adminCardBorder, width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildBookingAvatar(booking),
              const SizedBox(width: 12),
              Expanded(child: buildBookingInformation(booking)),
              const SizedBox(width: 7),
              buildStatusBadge(booking),
              const SizedBox(width: 2),
              const Icon(
                Icons.chevron_right_rounded,
                color: ThemeApp.textGrey,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBookingAvatar(AdminBooking booking) {
    final String imageUrl = booking.tenantProfileImageUrl?.trim() ?? '';

    Widget fallback() {
      return Container(
        color: avatarBackground(booking),
        alignment: Alignment.center,
        child: Icon(
          Icons.person_outline_rounded,
          color: avatarColor(booking),
          size: 30,
        ),
      );
    }

    return ClipOval(
      child: SizedBox(
        width: 52,
        height: 52,
        child: imageUrl.isEmpty
            ? fallback()
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder:
                    (
                      BuildContext context,
                      Widget child,
                      ImageChunkEvent? loadingProgress,
                    ) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return Container(
                        color: avatarBackground(booking),
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: avatarColor(booking),
                          ),
                        ),
                      );
                    },
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      return fallback();
                    },
              ),
      ),
    );
  }

  Widget buildBookingInformation(AdminBooking booking) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 22,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              booking.tenantName,
              maxLines: 1,
              style: const TextStyle(
                color: ThemeApp.adminTitle,
                fontSize: 16,
                height: 1.2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          height: 20,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              booking.kostName,
              maxLines: 1,
              style: const TextStyle(
                color: ThemeApp.textGrey,
                fontSize: 13.5,
                height: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formatBookingDate(booking.bookingDate ?? booking.startDate),
          maxLines: 1,
          style: const TextStyle(
            color: ThemeApp.textGrey,
            fontSize: 13,
            height: 1.2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget buildStatusBadge(AdminBooking booking) {
    final String label = booking.isWaitingPayment
        ? 'Menunggu\nPembayaran'
        : booking.statusLabel;

    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
      decoration: BoxDecoration(
        color: statusBackground(booking),
        borderRadius: ThemeApp.radius(17),
      ),
      child: Text(
        label,
        maxLines: 2,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: statusTextColor(booking),
          fontSize: 10.5,
          height: 1.15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color avatarBackground(AdminBooking booking) {
    if (booking.isConfirmed) {
      return ThemeApp.adminSoftGreen;
    }

    if (booking.isCompleted) {
      return ThemeApp.adminSoftOrange;
    }

    if (booking.isRejected || booking.isCancelled) {
      return ThemeApp.adminSoftRed;
    }

    return ThemeApp.adminSoftPurple;
  }

  Color avatarColor(AdminBooking booking) {
    if (booking.isConfirmed) {
      return ThemeApp.adminGreen;
    }

    if (booking.isCompleted) {
      return ThemeApp.adminOrange;
    }

    if (booking.isRejected || booking.isCancelled) {
      return ThemeApp.adminRed;
    }

    return ThemeApp.adminPurple;
  }

  Color statusBackground(AdminBooking booking) {
    if (booking.isCompleted) {
      return ThemeApp.adminSoftBlue;
    }

    if (booking.isConfirmed) {
      return ThemeApp.adminSoftGreen;
    }

    if (booking.isRejected || booking.isCancelled) {
      return ThemeApp.adminSoftRed;
    }

    return ThemeApp.adminSoftOrange;
  }

  Color statusTextColor(AdminBooking booking) {
    if (booking.isCompleted) {
      return ThemeApp.adminBlue;
    }

    if (booking.isConfirmed) {
      return ThemeApp.adminGreen;
    }

    if (booking.isRejected || booking.isCancelled) {
      return ThemeApp.adminRed;
    }

    return ThemeApp.pendingOrange;
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  String formatBookingDate(DateTime? date) {
    if (date == null) {
      return '-';
    }

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

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  String formatNumber(int value) {
    final String text = value.toString();

    final List<String> reversed = text.split('').reversed.toList();

    final StringBuffer buffer = StringBuffer();

    for (int index = 0; index < reversed.length; index++) {
      if (index > 0 && index % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(reversed[index]);
    }

    return buffer.toString().split('').reversed.join();
  }
}
