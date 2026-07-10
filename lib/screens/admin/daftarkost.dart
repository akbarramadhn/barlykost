import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/admin/kost.dart';
import '../../services/admin/kost_service.dart';
import '../../widgets/adminbottomnav.dart';
import '../../widgets/adminkostcard.dart';
import 'dashboardadmin.dart';
import 'detailkost.dart';
import 'pemesanan.dart';

class AdminKostScreen extends StatefulWidget {
  final ValueChanged<Kost>? onKostTap;
  final VoidCallback? onAddKost;
  final VoidCallback? onEditKost;
  final VoidCallback? onNotificationTap;

  const AdminKostScreen({
    super.key,
    this.onKostTap,
    this.onAddKost,
    this.onEditKost,
    this.onNotificationTap,
  });

  @override
  State<AdminKostScreen> createState() => _AdminKostScreenState();
}

class _AdminKostScreenState extends State<AdminKostScreen> {
  final KostService _kostService = KostService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Kost>> _kostFuture;

  bool _onlyAvailable = true;

  @override
  void initState() {
    super.initState();
    _kostFuture = _kostService.getAllKosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void handleBottomNavTap(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
      return;
    }

    if (index == 1) {
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
      showMessage('Halaman profil admin akan dibuat berikutnya');
    }
  }

  Future<void> _refreshData() async {
    final Future<List<Kost>> newFuture = _kostService.getAllKosts();

    setState(() {
      _kostFuture = newFuture;
    });

    await newFuture;
  }

  List<Kost> _filterKosts(List<Kost> kosts) {
    final String keyword = _searchController.text.trim().toLowerCase();

    return kosts.where((Kost kost) {
      final bool matchesAvailability = !_onlyAvailable || kost.tersedia > 0;

      final bool matchesKeyword =
          keyword.isEmpty ||
          kost.namaKost.toLowerCase().contains(keyword) ||
          kost.lokasi.toLowerCase().contains(keyword);

      return matchesAvailability && matchesKeyword;
    }).toList();
  }

  Widget _buildNotificationButton() {
    return InkWell(
      onTap:
          widget.onNotificationTap ??
          () {
            showMessage('Halaman notifikasi belum dibuat');
          },
      borderRadius: ThemeApp.radius(30),
      child: const SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 34,
              color: ThemeApp.adminTitle,
            ),
            Positioned(
              top: 5,
              right: 6,
              child: CircleAvatar(
                radius: 5,
                backgroundColor: ThemeApp.adminRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Daftar Kost',
            style: TextStyle(
              fontSize: 28,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: ThemeApp.adminTitle,
            ),
          ),
        ),
        _buildNotificationButton(),
      ],
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: 58,
      child: TextField(
        controller: _searchController,
        onChanged: (_) {
          setState(() {});
        },
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: ThemeApp.textDark,
        ),
        decoration: InputDecoration(
          hintText: 'Cari kost anda',
          hintStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: ThemeApp.textGrey,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 8),
            child: Icon(
              Icons.search_rounded,
              size: 29,
              color: ThemeApp.textGrey,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 52),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color: ThemeApp.textGrey,
                  ),
                ),
          filled: true,
          fillColor: ThemeApp.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          enabledBorder: OutlineInputBorder(
            borderRadius: ThemeApp.radius(32),
            borderSide: const BorderSide(
              color: ThemeApp.borderGrey,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: ThemeApp.radius(32),
            borderSide: const BorderSide(
              color: ThemeApp.primaryDark,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableFilter() {
    return InkWell(
      onTap: () {
        setState(() {
          _onlyAvailable = !_onlyAvailable;
        });
      },
      borderRadius: ThemeApp.radius(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 12),
        decoration: BoxDecoration(
          color: _onlyAvailable ? ThemeApp.buttonColor : ThemeApp.white,
          borderRadius: ThemeApp.radius(30),
          border: Border.all(
            color: _onlyAvailable ? ThemeApp.buttonColor : ThemeApp.borderGrey,
            width: 1.1,
          ),
        ),
        child: Text(
          'Tersedia',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: _onlyAvailable ? ThemeApp.textLight : ThemeApp.textGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return InkWell(
      onTap:
          widget.onEditKost ??
          () {
            showMessage('Fitur edit kost dibuat pada tahap CRUD');
          },
      borderRadius: ThemeApp.radius(30),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: ThemeApp.white,
          shape: BoxShape.circle,
          border: Border.all(color: ThemeApp.borderGrey, width: 1.2),
          boxShadow: [
            ThemeApp.softShadow(
              alpha: 0.04,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.edit_outlined,
          size: 26,
          color: ThemeApp.textDark,
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Row(
      children: [_buildAvailableFilter(), const Spacer(), _buildEditButton()],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: ThemeApp.primaryDark),
    );
  }

  Widget _buildError(Object? error) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: ThemeApp.primaryDark,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 120),
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 58,
            color: ThemeApp.textGrey,
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Data kost gagal dimuat',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: ThemeApp.textDark,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: ThemeApp.textGrey,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: OutlinedButton(
              onPressed: _refreshData,
              style: OutlinedButton.styleFrom(
                foregroundColor: ThemeApp.buttonColor,
                side: const BorderSide(color: ThemeApp.buttonColor),
                shape: RoundedRectangleBorder(
                  borderRadius: ThemeApp.radius(20),
                ),
              ),
              child: const Text('Coba lagi'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    final bool isSearching = _searchController.text.trim().isNotEmpty;

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: ThemeApp.primaryDark,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 120),
        children: [
          const Icon(
            Icons.apartment_outlined,
            size: 62,
            color: ThemeApp.lightGrey,
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              isSearching ? 'Kost tidak ditemukan' : 'Belum ada kost tersedia',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ThemeApp.textDark,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Center(
            child: Text(
              isSearching
                  ? 'Coba gunakan kata pencarian lainnya.'
                  : 'Data kost akan muncul di halaman ini.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: ThemeApp.textGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKostList(List<Kost> kosts) {
    final List<Kost> filteredKosts = _filterKosts(kosts);

    if (filteredKosts.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: ThemeApp.primaryDark,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 6, 0, 110),
        itemCount: filteredKosts.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: 16);
        },
        itemBuilder: (BuildContext context, int index) {
          final Kost kost = filteredKosts[index];

          return AdminKostCard(
            kost: kost,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminKostDetailScreen(kostId: kost.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeApp.white,
      bottomNavigationBar: AdminBottomNav(
        currentIndex: 1,
        onTap: handleBottomNavTap,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            widget.onAddKost ??
            () {
              showMessage('Halaman tambah kost dibuat pada tahap CRUD');
            },
        backgroundColor: ThemeApp.adminBlue,
        foregroundColor: ThemeApp.textLight,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 40),
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 28),
              _buildSearchField(),
              const SizedBox(height: 20),
              _buildFilterSection(),
              const SizedBox(height: 18),
              Expanded(
                child: FutureBuilder<List<Kost>>(
                  future: _kostFuture,
                  builder:
                      (
                        BuildContext context,
                        AsyncSnapshot<List<Kost>> snapshot,
                      ) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildLoading();
                        }

                        if (snapshot.hasError) {
                          return _buildError(snapshot.error);
                        }

                        return _buildKostList(snapshot.data ?? <Kost>[]);
                      },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
