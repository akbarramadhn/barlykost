import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/admin/adminbooking.dart';
import '../../services/admin/admin_booking_service.dart';
import '../../widgets/adminbottomnav.dart';
import 'daftarkost.dart';
import 'dashboardadmin.dart';
import 'detailpemesanan.dart';

enum AdminBookingFilter { all, confirmed, waitingPayment }

class AdminBookingScreen extends StatefulWidget {
  final ValueChanged<AdminBooking>? onBookingTap;
  final VoidCallback? onNotificationTap;

  const AdminBookingScreen({
    super.key,
    this.onBookingTap,
    this.onNotificationTap,
  });

  @override
  State<AdminBookingScreen> createState() => _AdminBookingScreenState();
}

class _AdminBookingScreenState extends State<AdminBookingScreen> {
  Future<void> _openBookingDetail(AdminBooking booking) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminBookingDetailScreen(bookingId: booking.id),
      ),
    );

    if (!mounted) {
      return;
    }

    await _refreshData();
  }

  final AdminBookingService _bookingService = AdminBookingService();

  final TextEditingController _searchController = TextEditingController();

  late Future<List<AdminBooking>> _bookingFuture;

  AdminBookingFilter _selectedFilter = AdminBookingFilter.all;

  @override
  void initState() {
    super.initState();
    _bookingFuture = _bookingService.getAllBookings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
      return;
    }

    if (index == 3) {
      _showMessage('Halaman profil admin akan dibuat berikutnya');
    }
  }

  Future<void> _refreshData() async {
    final Future<List<AdminBooking>> newFuture = _bookingService
        .getAllBookings();

    setState(() {
      _bookingFuture = newFuture;
    });

    await newFuture;
  }

  String _formatDate(DateTime? date) {
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

  List<AdminBooking> _filterBookings(List<AdminBooking> bookings) {
    final String keyword = _searchController.text.trim().toLowerCase();

    return bookings.where((AdminBooking booking) {
      final bool matchesKeyword =
          keyword.isEmpty ||
          booking.tenantName.toLowerCase().contains(keyword) ||
          booking.kostName.toLowerCase().contains(keyword);

      bool matchesFilter = true;

      if (_selectedFilter == AdminBookingFilter.confirmed) {
        matchesFilter = booking.isConfirmed;
      }

      if (_selectedFilter == AdminBookingFilter.waitingPayment) {
        matchesFilter = booking.isWaitingPayment;
      }

      return matchesKeyword && matchesFilter;
    }).toList();
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Pemesanan',
            style: TextStyle(
              color: ThemeApp.adminTitle,
              fontSize: 28,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        InkWell(
          onTap:
              widget.onNotificationTap ??
              () {
                _showMessage('Halaman notifikasi belum dibuat');
              },
          borderRadius: ThemeApp.radius(22),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              Icons.notifications_none_rounded,
              size: 30,
              color: ThemeApp.adminTitle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: 56,
      child: TextField(
        controller: _searchController,
        onChanged: (_) {
          setState(() {});
        },
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          color: ThemeApp.textDark,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Cari kost anda',
          hintStyle: const TextStyle(
            color: ThemeApp.textGrey,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 8),
            child: Icon(
              Icons.search_rounded,
              size: 27,
              color: ThemeApp.textGrey,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 50),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 18),
          enabledBorder: OutlineInputBorder(
            borderRadius: ThemeApp.radius(30),
            borderSide: const BorderSide(
              color: ThemeApp.borderGrey,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: ThemeApp.radius(30),
            borderSide: const BorderSide(
              color: ThemeApp.primaryDark,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required AdminBookingFilter filter,
  }) {
    final bool isSelected = _selectedFilter == filter;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      borderRadius: ThemeApp.radius(28),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? ThemeApp.buttonColor : ThemeApp.white,
          borderRadius: ThemeApp.radius(28),
          border: Border.all(
            color: isSelected ? ThemeApp.buttonColor : ThemeApp.borderGrey,
            width: 1.1,
          ),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: isSelected ? ThemeApp.white : ThemeApp.textGrey,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          flex: 8,
          child: _buildFilterButton(
            label: 'Semua',
            filter: AdminBookingFilter.all,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 11,
          child: _buildFilterButton(
            label: 'Dikonfirmasi',
            filter: AdminBookingFilter.confirmed,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 16,
          child: _buildFilterButton(
            label: 'Menunggu Pembayaran',
            filter: AdminBookingFilter.waitingPayment,
          ),
        ),
      ],
    );
  }

  Color _avatarBackground(AdminBooking booking) {
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

  Color _avatarColor(AdminBooking booking) {
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

  Color _statusBackground(AdminBooking booking) {
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

  Color _statusTextColor(AdminBooking booking) {
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

  Widget _buildAvatar(AdminBooking booking) {
    final String imageUrl = booking.tenantProfileImageUrl?.trim() ?? '';

    Widget fallback() {
      return Container(
        color: _avatarBackground(booking),
        alignment: Alignment.center,
        child: Icon(
          Icons.person_outline_rounded,
          color: _avatarColor(booking),
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
                        color: _avatarBackground(booking),
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _avatarColor(booking),
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

  Widget _buildBookingInformation(AdminBooking booking) {
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
          _formatDate(booking.bookingDate ?? booking.startDate),
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

  Widget _buildStatusBadge(AdminBooking booking) {
    final String label = booking.isWaitingPayment
        ? 'Menunggu\nPembayaran'
        : booking.statusLabel;

    return Container(
      width: 96,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
      decoration: BoxDecoration(
        color: _statusBackground(booking),
        borderRadius: ThemeApp.radius(17),
      ),
      child: Text(
        label,
        maxLines: 2,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _statusTextColor(booking),
          fontSize: 10.5,
          height: 1.15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBookingCard(AdminBooking booking) {
    return Material(
      color: ThemeApp.white,
      borderRadius: ThemeApp.radius(22),
      child: InkWell(
        onTap: () {
          if (widget.onBookingTap != null) {
            widget.onBookingTap!(booking);
            return;
          }

          _openBookingDetail(booking);
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
              _buildAvatar(booking),
              const SizedBox(width: 12),
              Expanded(child: _buildBookingInformation(booking)),
              const SizedBox(width: 7),
              _buildStatusBadge(booking),
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
        padding: const EdgeInsets.only(top: 110),
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 58,
            color: ThemeApp.textGrey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Data pemesanan gagal dimuat',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ThemeApp.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ThemeApp.textGrey,
                fontSize: 13,
                height: 1.4,
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
        padding: const EdgeInsets.only(top: 110),
        children: [
          const Icon(
            Icons.assignment_outlined,
            size: 62,
            color: ThemeApp.lightGrey,
          ),
          const SizedBox(height: 14),
          Text(
            isSearching ? 'Pemesanan tidak ditemukan' : 'Belum ada pemesanan',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ThemeApp.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            isSearching
                ? 'Coba gunakan kata pencarian lainnya.'
                : 'Data pemesanan akan muncul di halaman ini.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: ThemeApp.textGrey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(List<AdminBooking> bookings) {
    final List<AdminBooking> filteredBookings = _filterBookings(bookings);

    if (filteredBookings.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: ThemeApp.primaryDark,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 6, 0, 28),
        itemCount: filteredBookings.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: 14);
        },
        itemBuilder: (BuildContext context, int index) {
          return _buildBookingCard(filteredBookings[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeApp.white,
      bottomNavigationBar: AdminBottomNav(
        currentIndex: 2,
        onTap: _handleBottomNavTap,
      ),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 26),
              _buildSearchField(),
              const SizedBox(height: 18),
              _buildFilters(),
              const SizedBox(height: 22),
              Expanded(
                child: FutureBuilder<List<AdminBooking>>(
                  future: _bookingFuture,
                  builder:
                      (
                        BuildContext context,
                        AsyncSnapshot<List<AdminBooking>> snapshot,
                      ) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildLoading();
                        }

                        if (snapshot.hasError) {
                          return _buildError(snapshot.error);
                        }

                        return _buildBookingList(
                          snapshot.data ?? <AdminBooking>[],
                        );
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
