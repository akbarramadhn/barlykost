import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/booking.dart';
import '../../../models/user.dart';
import '../../../services/auth_service.dart';
import '../../../services/booking_service.dart';
import '../../../services/wishlist_service.dart';
import '../../../widgets/bottomnav.dart';
import '../../../widgets/emptystate.dart';
import '../../auth/login_screen.dart';
import '../history/history_screen.dart';
import '../kost/daftarkost.dart';
import '../wishlist/wishlist_screen.dart';
import 'editprofile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService authService = AuthService();
  final BookingService bookingService = BookingService();
  final WishlistService wishlistService = WishlistService();

  late Future<_ProfileData> profileFuture;

  int selectedNavIndex = 3;
  bool isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    profileFuture = fetchProfileData();
  }

  Future<_ProfileData> fetchProfileData() async {
    final results = await Future.wait<Object>([
      authService.fetchCurrentUser(),
      bookingService.getCurrentUserBookings(),
      wishlistService.countWishlist(),
    ]);

    final user = results[0] as UserModel;
    final bookings = results[1] as List<Booking>;
    final totalWishlist = results[2] as int;

    final activeBookings = bookings.where((booking) {
      return booking.normalizedStatus == Booking.confirmed;
    }).toList();

    String activeKostLocation = 'Belum ada kost aktif';

    if (activeBookings.isNotEmpty) {
      final location = activeBookings.first.kostLocation.trim();

      if (location.isNotEmpty) {
        activeKostLocation = location;
      }
    }

    return _ProfileData(
      user: user,
      activeKost: activeBookings.length,
      totalHistory: bookings.length,
      activeKostLocation: activeKostLocation,
      totalWishlist: totalWishlist,
    );
  }

  Future<void> refreshData() async {
    final newFuture = fetchProfileData();

    setState(() {
      profileFuture = newFuture;
    });

    await newFuture;
  }

  Future<void> logout() async {
    if (isLoggingOut) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ThemeApp.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Keluar Akun',
            style: TextStyle(
              color: ThemeApp.textDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Apakah kamu yakin ingin keluar dari akun ini?',
            style: TextStyle(
              color: ThemeApp.textGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: ThemeApp.textGrey,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Keluar',
                style: TextStyle(
                  color: ThemeApp.cancelledRed,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    setState(() {
      isLoggingOut = true;
    });

    try {
      await authService.logout();

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
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoggingOut = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            getErrorMessage(error),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
                child: FutureBuilder<_ProfileData>(
                  future: profileFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: ThemeApp.buttonColor,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return buildErrorProfile(
                        getErrorMessage(snapshot.error),
                      );
                    }

                    final data = snapshot.data ?? _ProfileData.empty();

                    if (data.user.id.trim().isEmpty) {
                      return buildEmptyProfile();
                    }

                    return buildProfileContent(data);
                  },
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: selectedNavIndex,
          onTap: handleBottomNavTap,
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 48, 18, 16),
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
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.centerLeft,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: ThemeApp.textDark,
                size: 26,
              ),
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Profile',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ThemeApp.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 42,
            height: 42,
          ),
        ],
      ),
    );
  }

  Widget buildEmptyProfile() {
    return RefreshIndicator(
      color: ThemeApp.buttonColor,
      onRefresh: refreshData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(22, 80, 22, 118),
        children: [
          Container(
            width: double.infinity,
            height: 330,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: ThemeApp.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                ThemeApp.softShadow(
                  alpha: 0.07,
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: const EmptyState(
              icon: Icons.person_off_rounded,
              title: 'Profil tidak ditemukan',
              message:
                  'Data profil kamu belum tersedia. Coba refresh halaman ini atau login ulang.',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildErrorProfile(String message) {
    return RefreshIndicator(
      color: ThemeApp.buttonColor,
      onRefresh: refreshData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(22, 80, 22, 118),
        children: [
          Container(
            width: double.infinity,
            height: 330,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: ThemeApp.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                ThemeApp.softShadow(
                  alpha: 0.07,
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Gagal memuat profil',
              message: message,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfileContent(_ProfileData data) {
    return RefreshIndicator(
      color: ThemeApp.buttonColor,
      onRefresh: refreshData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 118),
        children: [
          buildProfileCard(data.user),
          const SizedBox(height: 18),
          buildActivitySummary(data),
          const SizedBox(height: 18),
          buildInformationCard(data),
          const SizedBox(height: 18),
          buildMenuCard(data.user),
          const SizedBox(height: 22),
          buildLogoutButton(),
        ],
      ),
    );
  }

  Widget buildProfileCard(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      decoration: BoxDecoration(
        color: ThemeApp.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          ThemeApp.softShadow(
            alpha: 0.08,
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          buildProfileAvatar(user),
          const SizedBox(height: 14),
          Text(
            user.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ThemeApp.textDark,
              fontSize: 23,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: ThemeApp.primaryLight.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.displayRole,
              style: const TextStyle(
                color: ThemeApp.buttonColor,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfileAvatar(UserModel user) {
    if (user.profileImageUrl.trim().isNotEmpty) {
      return Container(
        width: 92,
        height: 92,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: ThemeApp.white,
          shape: BoxShape.circle,
          boxShadow: [
            ThemeApp.softShadow(
              alpha: 0.08,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.network(
            user.profileImageUrl,
            width: 86,
            height: 86,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }

              return Container(
                color: ThemeApp.softGreen,
                child: const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: ThemeApp.buttonColor,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: ThemeApp.softGreen,
                child: const Icon(
                  Icons.person_rounded,
                  color: ThemeApp.buttonColor,
                  size: 62,
                ),
              );
            },
          ),
        ),
      );
    }

    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: ThemeApp.softGreen,
        shape: BoxShape.circle,
        border: Border.all(
          color: ThemeApp.white,
          width: 3,
        ),
        boxShadow: [
          ThemeApp.softShadow(
            alpha: 0.08,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(
        Icons.person_rounded,
        color: ThemeApp.buttonColor,
        size: 62,
      ),
    );
  }

  Widget buildActivitySummary(_ProfileData data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: ThemeApp.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          ThemeApp.softShadow(
            alpha: 0.08,
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          buildSummaryItem(
            value: data.activeKost.toString(),
            label: 'Kost Aktif',
            icon: Icons.home_work_rounded,
          ),
          buildDivider(),
          buildSummaryItem(
            value: data.totalHistory.toString(),
            label: 'Riwayat',
            icon: Icons.history_rounded,
          ),
          buildDivider(),
          buildSummaryItem(
            value: data.totalWishlist.toString(),
            label: 'Wishlist',
            icon: Icons.favorite_rounded,
          ),
        ],
      ),
    );
  }

  Widget buildSummaryItem({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: ThemeApp.buttonColor,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ThemeApp.textDark,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ThemeApp.textGrey,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDivider() {
    return Container(
      width: 1,
      height: 54,
      color: ThemeApp.lightGrey,
    );
  }

  Widget buildInformationCard(_ProfileData data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ThemeApp.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          ThemeApp.softShadow(
            alpha: 0.08,
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Akun',
            style: TextStyle(
              color: ThemeApp.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          buildInfoTile(
            icon: Icons.badge_rounded,
            title: 'Nama Lengkap',
            value: data.user.displayName,
          ),
          buildInfoTile(
            icon: Icons.email_rounded,
            title: 'Email',
            value: data.user.displayEmail,
          ),
          buildInfoTile(
            icon: Icons.phone_rounded,
            title: 'No. Telepon',
            value: data.user.displayPhone,
          ),
          buildInfoTile(
            icon: Icons.location_on_rounded,
            title: 'Alamat Kost',
            value: data.activeKostLocation,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    bool isLast = false,
  }) {
    return Container(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : 14,
      ),
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : 14,
      ),
      decoration: BoxDecoration(
        border:
            isLast
                ? null
                : const Border(
                  bottom: BorderSide(
                    color: Color(0xFFEDEDED),
                    width: 1,
                  ),
                ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: ThemeApp.softBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: ThemeApp.buttonColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ThemeApp.textGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value.trim().isEmpty ? '-' : value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ThemeApp.textDark,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuCard(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: ThemeApp.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          ThemeApp.softShadow(
            alpha: 0.08,
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          buildMenuTile(
            icon: Icons.history_rounded,
            title: 'Riwayat Pemesanan',
            onTap: openHistory,
          ),
          buildMenuTile(
            icon: Icons.favorite_rounded,
            title: 'Wishlist Kost',
            onTap: openWishlist,
          ),
          buildMenuTile(
            icon: Icons.edit_rounded,
            title: 'Edit Profil',
            onTap: () {
              openEditProfile(user);
            },
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            border:
                isLast
                    ? null
                    : const Border(
                      bottom: BorderSide(
                        color: Color(0xFFEDEDED),
                        width: 1,
                      ),
                    ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: ThemeApp.buttonColor,
                size: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: ThemeApp.textDark,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: ThemeApp.textGrey,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoggingOut ? null : logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeApp.cancelledRed,
          foregroundColor: ThemeApp.white,
          disabledBackgroundColor: ThemeApp.textGrey,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child:
            isLoggingOut
                ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: ThemeApp.white,
                    strokeWidth: 2,
                  ),
                )
                : const Text(
                  'Keluar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
      ),
    );
  }

  String getErrorMessage(Object? error) {
    final message = error?.toString() ?? '';

    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }

    if (message.trim().isEmpty) {
      return 'Terjadi kesalahan saat memuat profil.';
    }

    return message;
  }

  void openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HistoryScreen(),
      ),
    );
  }

  void openWishlist() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WishlistScreen(),
      ),
    );
  }

  Future<void> openEditProfile(UserModel user) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return EditProfileScreen(
            user: user,
          );
        },
      ),
    );

    if (result == true) {
      await refreshData();
    }
  }

  void handleBottomNavTap(int index) {
    if (index == selectedNavIndex) {
      return;
    }

    if (index == 0) {
      Navigator.popUntil(
        context,
        (route) => route.isFirst,
      );
      return;
    }

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CariKostScreen(),
        ),
      );
      return;
    }

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HistoryScreen(),
        ),
      );
    }
  }
}

class _ProfileData {
  final UserModel user;
  final int activeKost;
  final int totalHistory;
  final int totalWishlist;
  final String activeKostLocation;

  const _ProfileData({
    required this.user,
    required this.activeKost,
    required this.totalHistory,
    required this.totalWishlist,
    required this.activeKostLocation,
  });

  factory _ProfileData.empty() {
    return _ProfileData(
      user: UserModel.empty(),
      activeKost: 0,
      totalHistory: 0,
      totalWishlist: 0,
      activeKostLocation: 'Belum ada kost aktif',
    );
  }
}