import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../models/admin/dashboard.dart';
import '../../services/admin/dashboard_service.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final AdminDashboardService dashboardService = AdminDashboardService();

  late Future<AdminDashboardData> dashboardFuture;

  @override
  void initState() {
    super.initState();
    dashboardFuture = dashboardService.getDashboardData();
  }

  Future<void> refreshDashboard() async {
    setState(() {
      dashboardFuture = dashboardService.getDashboardData();
    });

    await dashboardFuture;
  }

  Future<void> logout() async {
    await supabase.auth.signOut();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeApp.white,
      body: SafeArea(
        child: FutureBuilder<AdminDashboardData>(
          future: dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: ThemeApp.buttonColor,
                  strokeWidth: 2,
                ),
              );
            }

            if (snapshot.hasError) {
              return buildErrorState();
            }

            final data = snapshot.data ?? AdminDashboardData.empty();

            return RefreshIndicator(
              color: ThemeApp.buttonColor,
              onRefresh: refreshDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildHeader(data),
                    const SizedBox(height: 26),
                    buildWelcomeCard(data),
                    const SizedBox(height: 32),
                    const Text(
                      'Ringkasan',
                      style: TextStyle(
                        color: ThemeApp.adminTitle,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    buildStatisticGrid(data),
                    const SizedBox(height: 34),
                    buildSectionHeader(
                      title: 'Pemesanan Terbaru',
                      actionText: 'Lihat semua',
                      onTap: () {
                        showMessage(
                          'Halaman daftar pemesanan akan dibuat berikutnya',
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    buildBookingList(data.latestBookings),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: buildAdminBottomNav(),
    );
  }

  Widget buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: ThemeApp.cancelledRed,
              size: 48,
            ),
            const SizedBox(height: 14),
            const Text(
              'Dashboard gagal dimuat',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ThemeApp.adminTitle,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Periksa koneksi atau pengaturan akses data admin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ThemeApp.textGrey,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 180,
              height: 48,
              child: ElevatedButton(
                onPressed: refreshDashboard,
                child: const Text('Coba Lagi'),
              ),
            ),
          ],
        ),
      ),
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
        GestureDetector(
          onTap: logout,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ThemeApp.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: ThemeApp.adminCardBorder,
                width: 1.2,
              ),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: ThemeApp.buttonColor,
              size: 23,
            ),
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
          colors: [
            ThemeApp.primaryDark,
            ThemeApp.primaryLight,
          ],
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

  Widget buildStatisticGrid(AdminDashboardData data) {
    final stats = [
      StatisticModel(
        title: 'Total Kost',
        value: data.totalKost.toString(),
        subtitle: 'Aktif',
        icon: Icons.apartment_rounded,
        iconColor: ThemeApp.adminPurple,
        iconBackground: ThemeApp.adminSoftPurple,
      ),
      StatisticModel(
        title: 'Total Pesanan',
        value: data.totalPesanan.toString(),
        subtitle: 'Bulan ini',
        icon: Icons.assignment_rounded,
        iconColor: ThemeApp.adminGreen,
        iconBackground: ThemeApp.adminSoftGreen,
      ),
      StatisticModel(
        title: 'Total User',
        value: data.totalUser.toString(),
        subtitle: 'Aktif',
        icon: Icons.person_outline_rounded,
        iconColor: ThemeApp.adminOrange,
        iconBackground: ThemeApp.adminSoftOrange,
      ),
      StatisticModel(
        title: 'Pendapatan',
        value: formatNumber(data.totalPendapatanBulanIni),
        subtitle: 'Bulan ini',
        icon: Icons.account_balance_wallet_rounded,
        iconColor: ThemeApp.adminBlue,
        iconBackground: ThemeApp.adminSoftBlue,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const double gap = 14;
        final double cardWidth = (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: stats.map((stat) {
            return SizedBox(
              width: cardWidth,
              child: buildStatisticCard(stat),
            );
          }).toList(),
        );
      },
    );
  }

  Widget buildStatisticCard(StatisticModel stat) {
    return Container(
      height: 118,
      padding: const EdgeInsets.all(16),
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
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: stat.iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              stat.icon,
              color: stat.iconColor,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ThemeApp.adminTitle,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  stat.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  stat.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: stat.iconColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget buildBookingList(List<AdminBookingSummary> bookings) {
    if (bookings.isEmpty) {
      return buildEmptyCard(
        icon: Icons.receipt_long_outlined,
        text: 'Belum ada pesanan masuk',
      );
    }

    return Column(
      children: bookings.map((booking) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: buildBookingCard(booking),
        );
      }).toList(),
    );
  }

  Widget buildBookingCard(AdminBookingSummary booking) {
    final style = booking.statusStyle;

    return Container(
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
            child: Column(
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
            ),
          ),
          const SizedBox(width: 10),
          Container(
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
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF9CA0A6),
            size: 30,
          ),
        ],
      ),
    );
  }

  Widget buildEmptyCard({
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
          Icon(
            icon,
            color: ThemeApp.buttonColor,
            size: 27,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: ThemeApp.adminTitle,
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAdminBottomNav() {
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
          children: [
            buildBottomNavItem(
              icon: Icons.home_rounded,
              isActive: true,
              onTap: () {},
            ),
            buildBottomNavItem(
              icon: Icons.apartment_rounded,
              isActive: false,
              onTap: () {
                showMessage('Halaman daftar kost akan dibuat berikutnya');
              },
            ),
            buildBottomNavItem(
              icon: Icons.assignment_rounded,
              isActive: false,
              onTap: () {
                showMessage('Halaman pemesanan akan dibuat berikutnya');
              },
            ),
            buildBottomNavItem(
              icon: Icons.person_rounded,
              isActive: false,
              onTap: () {
                showMessage('Halaman profil admin akan dibuat berikutnya');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBottomNavItem({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
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

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String formatNumber(int value) {
    final text = value.toString();
    final reversed = text.split('').reversed.toList();
    final buffer = StringBuffer();

    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(reversed[i]);
    }

    return buffer.toString().split('').reversed.join();
  }
}

class StatisticModel {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  const StatisticModel({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });
}