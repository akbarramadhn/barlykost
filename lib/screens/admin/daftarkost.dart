import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/admin/dashboard.dart';
import '../../services/admin/kost_service.dart';
import '../../widgets/adminbottomnav.dart';
import '../../widgets/emptystate.dart';
import '../../widgets/searchbar.dart';
import 'dashboard_screen.dart';

class AdminKostScreen extends StatefulWidget {
  const AdminKostScreen({super.key});

  @override
  State<AdminKostScreen> createState() => _AdminKostScreenState();
}

class _AdminKostScreenState extends State<AdminKostScreen> {
  final AdminKostService kostService = AdminKostService();
  final TextEditingController searchController = TextEditingController();

  late Future<List<AdminKostSummary>> kostFuture;
  String searchKeyword = '';

  @override
  void initState() {
    super.initState();
    kostFuture = getKostList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<List<AdminKostSummary>> getKostList() {
    return kostService.getKostList();
  }

  Future<void> refreshKost() async {
    setState(() {
      kostFuture = getKostList();
    });

    await kostFuture;
  }

  void handleBottomNavTap(int index) {
    if (index == 1) {
      return;
    }

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
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

  List<AdminKostSummary> filterKost(List<AdminKostSummary> kostList) {
    final keyword = searchKeyword.toLowerCase().trim();

    if (keyword.isEmpty) {
      return kostList;
    }

    return kostList.where((kost) {
      final name = kost.name.toLowerCase();
      final location = kost.location.toLowerCase();
      final description = kost.description.toLowerCase();

      return name.contains(keyword) ||
          location.contains(keyword) ||
          description.contains(keyword);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeApp.white,
      body: SafeArea(
        child: FutureBuilder<List<AdminKostSummary>>(
          future: kostFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return buildLoadingState();
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }

            final kostList = filterKost(snapshot.data ?? []);

            return RefreshIndicator(
              color: ThemeApp.buttonColor,
              onRefresh: refreshKost,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildHeader(),
                    const SizedBox(height: 24),
                    SearchBarWidget(
                      controller: searchController,
                      hintText: 'Cari kost',
                      showFilter: false,
                      showClear: searchKeyword.isNotEmpty,
                      height: 54,
                      fontSize: 16,
                      borderRadius: 18,
                      iconColor: ThemeApp.adminPurple,
                      showShadow: false,
                      onChanged: (value) {
                        setState(() {
                          searchKeyword = value;
                        });
                      },
                      onClearTap: () {
                        searchController.clear();
                        setState(() {
                          searchKeyword = '';
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    buildKostList(kostList),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AdminBottomNav(
        currentIndex: 1,
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
      title: 'Data kost gagal dimuat',
      message: 'Periksa koneksi atau pengaturan tabel kost.',
      buttonText: 'Coba Lagi',
      onButtonTap: refreshKost,
      iconColor: ThemeApp.adminRed,
      iconBackgroundColor: ThemeApp.adminSoftRed,
    );
  }

  Widget buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar Kost',
                style: TextStyle(
                  color: ThemeApp.adminTitle,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Kelola semua data kost',
                style: TextStyle(
                  color: ThemeApp.adminSubtitle,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            showMessage('Form tambah kost akan dibuat berikutnya');
          },
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: ThemeApp.buttonColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: ThemeApp.white,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildKostList(List<AdminKostSummary> kostList) {
    if (kostList.isEmpty) {
      return EmptyState(
        icon: Icons.apartment_rounded,
        title: searchKeyword.isEmpty
            ? 'Belum ada kost'
            : 'Kost tidak ditemukan',
        message: searchKeyword.isEmpty
            ? 'Data kost yang ditambahkan admin akan tampil di sini.'
            : 'Coba gunakan kata kunci pencarian lain.',
        iconColor: ThemeApp.adminPurple,
        iconBackgroundColor: ThemeApp.adminSoftPurple,
        compact: true,
      );
    }

    return Column(
      children: kostList.map((kost) {
        return buildKostCard(kost);
      }).toList(),
    );
  }

  Widget buildKostCard(AdminKostSummary kost) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () {
            showMessage('Detail kost akan dibuat berikutnya');
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeApp.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: ThemeApp.adminCardBorder, width: 1.2),
            ),
            child: Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: ThemeApp.adminSoftPurple,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.apartment_rounded,
                    color: ThemeApp.adminPurple,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(child: buildKostInfo(kost)),
                const SizedBox(width: 10),
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

  Widget buildKostInfo(AdminKostSummary kost) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          kost.name,
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
          kost.location,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF555555),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                'Rp ${formatNumber(kost.price)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ThemeApp.adminPurple,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.meeting_room_outlined,
              color: kost.available > 0
                  ? ThemeApp.adminGreen
                  : ThemeApp.adminRed,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              '${kost.available}',
              style: TextStyle(
                color: kost.available > 0
                    ? ThemeApp.adminGreen
                    : ThemeApp.adminRed,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
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
