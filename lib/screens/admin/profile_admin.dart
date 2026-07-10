import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/admin/admin_profile.dart';
import '../../services/admin/admin_profile_service.dart';
import '../../widgets/adminbottomnav.dart';
import '../auth/login_screen.dart';
import 'daftarkost.dart';
import 'dashboardadmin.dart';
import 'pemesanan.dart';
import 'edit_profile.dart';
import 'changepassword.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final AdminProfileService _profileService = AdminProfileService();

  late Future<AdminProfile> _profileFuture;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = _profileService.getCurrentAdminProfile();
  }

  Future<void> _refreshProfile() async {
    final Future<AdminProfile> newFuture = _profileService
        .getCurrentAdminProfile();

    setState(() {
      _profileFuture = newFuture;
    });

    await newFuture;
  }

  Future<void> _openEditProfile(AdminProfile profile) async {
    final bool? updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminEditProfileScreen(profile: profile),
      ),
    );

    if (!mounted || updated != true) {
      return;
    }

    await _refreshProfile();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openChangePassword() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AdminChangePasswordScreen()),
    );
  }

  Future<void> _logout() async {
    if (_isLoggingOut) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: ThemeApp.white,
          shape: RoundedRectangleBorder(borderRadius: ThemeApp.radius(20)),
          title: const Text(
            'Keluar dari akun',
            style: TextStyle(
              color: ThemeApp.adminTitle,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Apakah kamu yakin ingin keluar dari akun admin?',
            style: TextStyle(
              color: ThemeApp.textGrey,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeApp.cancelledRed,
                foregroundColor: ThemeApp.white,
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await _profileService.signOut();

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoggingOut = false;
      });

      _showMessage(error.toString());
    }
  }

  void _handleBottomNavTap(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
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
      return;
    }
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  String _formatJoinedDate(DateTime? date) {
    if (date == null) {
      return '-';
    }

    const List<String> months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 88,
      child: Row(
        children: [
          InkWell(
            onTap: _handleBack,
            borderRadius: ThemeApp.radius(20),
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: ThemeApp.textDark,
                size: 25,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Profil Admin',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ThemeApp.textDark,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 42, height: 42),
        ],
      ),
    );
  }

  Widget _buildAvatar(AdminProfile profile) {
    final String imageUrl = profile.profileImageUrl?.trim() ?? '';

    return Container(
      width: 74,
      height: 74,
      decoration: const BoxDecoration(
        color: ThemeApp.white,
        shape: BoxShape.circle,
      ),
      child: imageUrl.isEmpty
          ? const Icon(
              Icons.person_outline_rounded,
              color: ThemeApp.primaryDark,
              size: 48,
            )
          : ClipOval(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      return const Icon(
                        Icons.person_outline_rounded,
                        color: ThemeApp.primaryDark,
                        size: 48,
                      );
                    },
              ),
            ),
    );
  }

  Widget _buildProfileBanner(AdminProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      decoration: BoxDecoration(
        color: ThemeApp.primaryDark,
        borderRadius: ThemeApp.radius(22),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 34,
            top: -22,
            child: Icon(
              Icons.change_history_rounded,
              color: ThemeApp.white.withValues(alpha: 0.06),
              size: 128,
            ),
          ),
          Row(
            children: [
              _buildAvatar(profile),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName,
                      maxLines: 1,
                      softWrap: false,
                      style: const TextStyle(
                        color: ThemeApp.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 23,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          profile.email,
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(
                            color: ThemeApp.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: ThemeApp.white,
                size: 23,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInformationRow({
    required IconData icon,
    required String label,
    required String value,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 28,
                child: Icon(icon, color: ThemeApp.textGrey, size: 25),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 6,
                child: SizedBox(
                  height: 24,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      style: const TextStyle(
                        color: ThemeApp.textDark,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 7,
                child: SizedBox(
                  height: 24,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      value,
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: ThemeApp.textDark,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: ThemeApp.adminCardBorder),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: ThemeApp.radius(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Icon(icon, color: ThemeApp.textGrey, size: 27),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    style: const TextStyle(
                      color: ThemeApp.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: ThemeApp.textGrey,
                  size: 21,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: ThemeApp.adminCardBorder),
      ],
    );
  }

  Widget _buildInformationCard(AdminProfile profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
      decoration: BoxDecoration(
        color: ThemeApp.white,
        borderRadius: ThemeApp.radius(22),
        border: Border.all(color: ThemeApp.adminCardBorder, width: 1),
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
          const SizedBox(height: 18),
          _buildInformationRow(
            icon: Icons.person_outline_rounded,
            label: 'Nama Lengkap',
            value: profile.fullName,
          ),
          _buildInformationRow(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: profile.email,
          ),
          _buildInformationRow(
            icon: Icons.phone_rounded,
            label: 'No. Telepon',
            value: profile.phone,
          ),
          _buildInformationRow(
            icon: Icons.calendar_month_outlined,
            label: 'Bergabung Sejak',
            value: _formatJoinedDate(profile.joinedAt),
            showDivider: false,
          ),
          const SizedBox(height: 30),
          const Text(
            'Aksi Cepat',
            style: TextStyle(
              color: ThemeApp.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _buildActionTile(
            icon: Icons.lock_rounded,
            label: 'Ubah Password',
            onTap: _openChangePassword,
          ),
          _buildActionTile(
            icon: Icons.edit_outlined,
            label: 'Edit Profil',
            showDivider: false,
            onTap: () {
              _openEditProfile(profile);
            },
          ),
          const SizedBox(height: 34),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed: _isLoggingOut ? null : _logout,
              style: OutlinedButton.styleFrom(
                foregroundColor: ThemeApp.cancelledRed,
                disabledForegroundColor: ThemeApp.textGrey,
                side: const BorderSide(
                  color: ThemeApp.cancelledRed,
                  width: 1.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: ThemeApp.radius(12),
                ),
              ),
              child: _isLoggingOut
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: ThemeApp.cancelledRed,
                        strokeWidth: 2.2,
                      ),
                    )
                  : const Text(
                      'Keluar',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AdminProfile profile) {
    return RefreshIndicator(
      onRefresh: _refreshProfile,
      color: ThemeApp.primaryDark,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
        children: [
          _buildHeader(),
          const SizedBox(height: 14),
          InkWell(
            onTap: () {
              _openEditProfile(profile);
            },
            borderRadius: ThemeApp.radius(22),
            child: _buildProfileBanner(profile),
          ),
          const SizedBox(height: 24),
          _buildInformationCard(profile),
        ],
      ),
    );
  }

  Widget _buildError(Object? error) {
    return RefreshIndicator(
      onRefresh: _refreshProfile,
      color: ThemeApp.primaryDark,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 130, 24, 40),
        children: [
          const Icon(
            Icons.person_off_outlined,
            size: 62,
            color: ThemeApp.textGrey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Profil admin gagal dimuat',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ThemeApp.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ThemeApp.textGrey,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: OutlinedButton(
              onPressed: _refreshProfile,
              style: OutlinedButton.styleFrom(
                foregroundColor: ThemeApp.buttonColor,
                side: const BorderSide(color: ThemeApp.buttonColor),
                shape: RoundedRectangleBorder(
                  borderRadius: ThemeApp.radius(18),
                ),
              ),
              child: const Text('Coba lagi'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeApp.white,
      bottomNavigationBar: AdminBottomNav(
        currentIndex: 3,
        onTap: _handleBottomNavTap,
      ),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<AdminProfile>(
          future: _profileFuture,
          builder:
              (BuildContext context, AsyncSnapshot<AdminProfile> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: ThemeApp.primaryDark,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _buildError(snapshot.error);
                }

                return _buildContent(snapshot.data!);
              },
        ),
      ),
    );
  }
}
