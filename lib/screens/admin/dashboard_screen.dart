import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../models/admin/dashboard.dart';
import '../../services/admin/dashboard_service.dart';
import '../../widgets/adminbookcard.dart';
import '../../widgets/adminbottomnav.dart';
import '../../widgets/emptystate.dart';
import '../../widgets/statisticcard.dart';
import '../auth/login_screen.dart';
import 'daftarkost.dart';

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
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
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
      showMessage('Halaman pemesanan akan dibuat berikutnya');
      return;
    }

    if (index == 3) {
      showMessage('Halaman profil admin akan dibuat berikutnya');
    }
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
              return buildLoadingState();
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
                    buildSectionTitle('Ringkasan'),
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
        GestureDetector(
          onTap: logout,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ThemeApp.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ThemeApp.adminCardBorder, width: 1.2),
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
      builder: (context, constraints) {
        const double gap = 14;
        final double cardWidth = (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: stats.map((statistic) {
            return SizedBox(
              width: cardWidth,
              child: StatisticCard(
                title: statistic.title,
                value: statistic.value,
                subtitle: statistic.subtitle,
                icon: statistic.icon,
                color: statistic.iconColor,
                iconBackgroundColor: statistic.iconBackground,
                height: 118,
                borderRadius: 18,
                showShadow: false,
                showBorder: true,
                circularIcon: true,
                iconBoxSize: 54,
                iconSize: 29,
                titleFontSize: 15,
                subtitleFontSize: 15,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget buildBookingList(List<AdminBookingSummary> bookings) {
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
      children: bookings.map((booking) {
        return AdminBookingCard(
          booking: booking,
          margin: const EdgeInsets.only(bottom: 14),
          onTap: () {
            showMessage('Detail pemesanan akan dibuat berikutnya');
          },
        );
      }).toList(),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
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
