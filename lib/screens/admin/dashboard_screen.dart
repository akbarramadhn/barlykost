import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  bool isLoading = true;
  String? errorMessage;

  String adminName = 'Admin';

  int totalKost = 0;
  int totalBookingBulanIni = 0;
  int totalUserAktif = 0;
  double pendapatanBulanIni = 0;

  List<Map<String, dynamic>> latestBookings = [];
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> kosts = [];

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      await loadAdminData();

      final List<Map<String, dynamic>> kostRows = await fetchRows('kosts');
      final List<Map<String, dynamic>> bookingRows = await fetchRows('bookings');
      final List<Map<String, dynamic>> userRows = await fetchRows('users');
      final List<Map<String, dynamic>> paymentRows = await fetchRows('payments');

      final DateTime now = DateTime.now();

      final List<Map<String, dynamic>> bookingBulanIni =
          bookingRows.where((booking) {
        final DateTime? date = readDate(
          booking,
          [
            'created_at',
            'booking_date',
            'tanggal_pemesanan',
            'start_date',
            'check_in_date',
          ],
        );

        if (date == null) {
          return true;
        }

        return date.month == now.month && date.year == now.year;
      }).toList();

      final List<Map<String, dynamic>> paymentBulanIni =
          paymentRows.where((payment) {
        final DateTime? date = readDate(
          payment,
          [
            'created_at',
            'payment_date',
            'paid_at',
            'tanggal_pembayaran',
          ],
        );

        if (date == null) {
          return true;
        }

        return date.month == now.month && date.year == now.year;
      }).toList();

      double totalRevenue = 0;

      for (final Map<String, dynamic> payment in paymentBulanIni) {
        if (isSuccessPayment(payment)) {
          totalRevenue += readDouble(
            payment,
            [
              'total_amount',
              'amount',
              'total_payment',
              'total_pembayaran',
              'total_price',
              'price',
              'nominal',
            ],
          );
        }
      }

      bookingRows.sort((a, b) {
        final DateTime dateA = readDate(
              a,
              [
                'created_at',
                'booking_date',
                'tanggal_pemesanan',
                'start_date',
              ],
            ) ??
            DateTime(2000);

        final DateTime dateB = readDate(
              b,
              [
                'created_at',
                'booking_date',
                'tanggal_pemesanan',
                'start_date',
              ],
            ) ??
            DateTime(2000);

        return dateB.compareTo(dateA);
      });

      setState(() {
        kosts = kostRows;
        users = userRows;
        latestBookings = bookingRows.take(3).toList();

        totalKost = kostRows.length;
        totalBookingBulanIni = bookingBulanIni.length;

        totalUserAktif = userRows.where((user) {
          final String role = readString(
            user,
            ['role'],
            defaultValue: '',
          ).toLowerCase();

          return role != 'admin';
        }).length;

        pendapatanBulanIni = totalRevenue;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> loadAdminData() async {
    final User? currentUser = supabase.auth.currentUser;

    if (currentUser == null) {
      return;
    }

    Map<String, dynamic>? adminData = await supabase
        .from('users')
        .select('*')
        .eq('id', currentUser.id)
        .maybeSingle();

    adminData ??= await supabase
        .from('users')
        .select('*')
        .ilike('email', currentUser.email ?? '')
        .maybeSingle();

    if (adminData != null) {
      adminName = readString(
        adminData,
        ['full_name', 'name', 'nama_lengkap'],
        defaultValue: 'Admin',
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchRows(String tableName) async {
    final dynamic response = await supabase.from(tableName).select('*');

    return (response as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> logout(BuildContext context) async {
    final AuthService authService = AuthService();

    try {
      await authService.logout();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String readString(
    Map<String, dynamic> data,
    List<String> keys, {
    String defaultValue = '-',
  }) {
    for (final String key in keys) {
      final dynamic value = data[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return defaultValue;
  }

  double readDouble(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final String key in keys) {
      final dynamic value = data[key];

      if (value == null) {
        continue;
      }

      if (value is num) {
        return value.toDouble();
      }

      final String cleanValue = value
          .toString()
          .replaceAll('Rp', '')
          .replaceAll('.', '')
          .replaceAll(',', '')
          .trim();

      return double.tryParse(cleanValue) ?? 0;
    }

    return 0;
  }

  DateTime? readDate(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final String key in keys) {
      final dynamic value = data[key];

      if (value == null) {
        continue;
      }

      final DateTime? parsedDate = DateTime.tryParse(value.toString());

      if (parsedDate != null) {
        return parsedDate;
      }
    }

    return null;
  }

  bool isSuccessPayment(Map<String, dynamic> payment) {
    final String status = readString(
      payment,
      ['status', 'payment_status'],
      defaultValue: '',
    ).toLowerCase();

    if (status.isEmpty) {
      return true;
    }

    if (status.contains('paid') ||
        status.contains('success') ||
        status.contains('berhasil') ||
        status.contains('selesai') ||
        status.contains('confirmed') ||
        status.contains('dikonfirmasi') ||
        status.contains('verified')) {
      return true;
    }

    return false;
  }

  String getUserName(Map<String, dynamic> booking) {
    final String directName = readString(
      booking,
      [
        'full_name',
        'name',
        'tenant_name',
        'nama_penyewa',
        'user_name',
      ],
      defaultValue: '',
    );

    if (directName.isNotEmpty) {
      return directName;
    }

    final String userId = readString(
      booking,
      [
        'user_id',
        'penyewa_id',
        'tenant_id',
      ],
      defaultValue: '',
    );

    for (final Map<String, dynamic> user in users) {
      if (readString(user, ['id'], defaultValue: '') == userId) {
        return readString(
          user,
          ['full_name', 'name', 'nama_lengkap'],
          defaultValue: 'Penyewa',
        );
      }
    }

    return 'Penyewa';
  }

  String getKostName(Map<String, dynamic> booking) {
    final String directKostName = readString(
      booking,
      [
        'kost_name',
        'nama_kost',
        'kost',
      ],
      defaultValue: '',
    );

    if (directKostName.isNotEmpty) {
      return directKostName;
    }

    final String kostId = readString(
      booking,
      [
        'kost_id',
        'boarding_house_id',
      ],
      defaultValue: '',
    );

    for (final Map<String, dynamic> kost in kosts) {
      if (readString(kost, ['id'], defaultValue: '') == kostId) {
        return readString(
          kost,
          ['name', 'kost_name', 'nama_kost', 'title'],
          defaultValue: 'Kost',
        );
      }
    }

    return 'Kost';
  }

  String formatDate(DateTime? date) {
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

  String formatRupiah(double value) {
    final String number = value.toInt().toString();
    final StringBuffer result = StringBuffer();

    int counter = 0;

    for (int i = number.length - 1; i >= 0; i--) {
      result.write(number[i]);
      counter++;

      if (counter == 3 && i != 0) {
        result.write('.');
        counter = 0;
      }
    }

    return result.toString().split('').reversed.join();
  }

  String formatStatus(String status) {
    final String lowerStatus = status.toLowerCase();

    if (lowerStatus.contains('waiting') ||
        lowerStatus.contains('pending') ||
        lowerStatus.contains('menunggu')) {
      return 'Menunggu\nPembayaran';
    }

    if (lowerStatus.contains('confirm') ||
        lowerStatus.contains('dikonfirmasi') ||
        lowerStatus.contains('verified')) {
      return 'Dikonfirmasi';
    }

    if (lowerStatus.contains('complete') || lowerStatus.contains('selesai')) {
      return 'Selesai';
    }

    if (lowerStatus.contains('cancel') || lowerStatus.contains('batal')) {
      return 'Dibatalkan';
    }

    if (lowerStatus.contains('reject') || lowerStatus.contains('tolak')) {
      return 'Ditolak';
    }

    if (status.trim().isEmpty) {
      return 'Menunggu';
    }

    return status;
  }

  Color statusTextColor(String status) {
    final String lowerStatus = status.toLowerCase();

    if (lowerStatus.contains('waiting') ||
        lowerStatus.contains('pending') ||
        lowerStatus.contains('menunggu')) {
      return const Color(0xFFB26300);
    }

    if (lowerStatus.contains('confirm') ||
        lowerStatus.contains('dikonfirmasi') ||
        lowerStatus.contains('verified')) {
      return const Color(0xFF2DA44E);
    }

    if (lowerStatus.contains('complete') || lowerStatus.contains('selesai')) {
      return const Color(0xFF235BFF);
    }

    if (lowerStatus.contains('cancel') ||
        lowerStatus.contains('batal') ||
        lowerStatus.contains('reject') ||
        lowerStatus.contains('tolak')) {
      return Colors.red;
    }

    return Colors.grey;
  }

  Color statusBackgroundColor(String status) {
    final String lowerStatus = status.toLowerCase();

    if (lowerStatus.contains('waiting') ||
        lowerStatus.contains('pending') ||
        lowerStatus.contains('menunggu')) {
      return const Color(0xFFFFDFA8);
    }

    if (lowerStatus.contains('confirm') ||
        lowerStatus.contains('dikonfirmasi') ||
        lowerStatus.contains('verified')) {
      return const Color(0xFFD8F2DC);
    }

    if (lowerStatus.contains('complete') || lowerStatus.contains('selesai')) {
      return const Color(0xFFDDE6FF);
    }

    if (lowerStatus.contains('cancel') ||
        lowerStatus.contains('batal') ||
        lowerStatus.contains('reject') ||
        lowerStatus.contains('tolak')) {
      return const Color(0xFFFFDADA);
    }

    return const Color(0xFFE8E8E8);
  }

  Color bookingIconColor(int index) {
    if (index == 0) {
      return const Color(0xFF4D35E8);
    }

    if (index == 1) {
      return const Color(0xFF2DA44E);
    }

    return const Color(0xFFFF8A22);
  }

  Color bookingIconBackground(int index) {
    if (index == 0) {
      return const Color(0xFFDCD4FF);
    }

    if (index == 1) {
      return const Color(0xFFD8F2DC);
    }

    return const Color(0xFFFFE1C6);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const AdminBottomNavigation(),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: ThemeApp.primaryDark,
                ),
              )
            : errorMessage != null
                ? buildErrorView()
                : buildDashboardContent(),
      ),
    );
  }

  Widget buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ThemeApp.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ThemeApp.textGrey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: loadDashboardData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDashboardContent() {
    return RefreshIndicator(
      color: ThemeApp.primaryDark,
      onRefresh: loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(),
            const SizedBox(height: 28),
            buildWelcomeCard(),
            const SizedBox(height: 32),

            const Text(
              'Ringkasan',
              style: TextStyle(
                fontSize: 22,
                color: Color(0xFF080B17),
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    icon: Icons.apartment_rounded,
                    iconColor: Color(0xFF5846B8),
                    iconBackground: Color(0xFFDCD4FF),
                    value: totalKost.toString(),
                    title: 'Total\nKamar',
                    subtitle: 'Aktif',
                    subtitleColor: Color(0xFF4D35E8),
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: SummaryCard(
                    icon: Icons.assignment_rounded,
                    iconColor: Color(0xFF2DA44E),
                    iconBackground: Color(0xFFD8F2DC),
                    value: totalBookingBulanIni.toString(),
                    title: 'Total\nPesanan',
                    subtitle: 'Bulan ini',
                    subtitleColor: Color(0xFF2DA44E),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    icon: Icons.person_outline_rounded,
                    iconColor: Color(0xFFC07A46),
                    iconBackground: Color(0xFFFFE1C6),
                    value: totalUserAktif.toString(),
                    title: 'Total\nPenyewa',
                    subtitle: 'Aktif',
                    subtitleColor: Color(0xFF4D35E8),
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: SummaryCard(
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: Color(0xFF235BFF),
                    iconBackground: Color(0xFFDDE6FF),
                    value: formatRupiah(pendapatanBulanIni),
                    title: 'Pendapatan',
                    subtitle: 'Bulan ini',
                    subtitleColor: Color(0xFF235BFF),
                    isMoney: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 36),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Text(
                    'Pemesanan Terbaru',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 21,
                      color: Color(0xFF080B17),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Halaman semua pemesanan belum dibuat',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Lihat semua',
                    style: TextStyle(
                      color: Color(0xFF4D35E8),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            latestBookings.isEmpty
                ? const EmptyBookingCard()
                : Column(
                    children: latestBookings.asMap().entries.map((entry) {
                      final int index = entry.key;
                      final Map<String, dynamic> booking = entry.value;

                      final DateTime? bookingDate = readDate(
                        booking,
                        [
                          'created_at',
                          'booking_date',
                          'tanggal_pemesanan',
                          'start_date',
                        ],
                      );

                      final String rawStatus = readString(
                        booking,
                        ['status', 'booking_status'],
                        defaultValue: 'Menunggu',
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: BookingItem(
                          name: getUserName(booking),
                          kostName: getKostName(booking),
                          date: formatDate(bookingDate),
                          status: formatStatus(rawStatus),
                          statusTextColor: statusTextColor(rawStatus),
                          statusBackgroundColor:
                              statusBackgroundColor(rawStatus),
                          iconColor: bookingIconColor(index),
                          iconBackground: bookingIconBackground(index),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF080B17),
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                adminName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4D35E8),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => logout(context),
          icon: const Icon(
            Icons.logout_rounded,
            color: Color(0xFF080B17),
          ),
        ),
      ],
    );
  }

  Widget buildWelcomeCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 172,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF147F75),
            Color(0xFF5CE7D1),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -10,
            child: Icon(
              Icons.home_work_outlined,
              size: 108,
              color: Colors.white.withOpacity(0.24),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(right: 82),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Selamat datang,',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '$adminName 👋',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Kelola data kost dan pemesanan\ndengan mudah.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String value;
  final String title;
  final String subtitle;
  final Color subtitleColor;
  final bool isMoney;

  const SummaryCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.value,
    required this.title,
    required this.subtitle,
    required this.subtitleColor,
    this.isMoney = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE1E1E1),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF080B17),
                    fontSize: isMoney ? 18 : 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: isMoney ? -0.6 : -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    color: Color(0xFF4A4A4A),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BookingItem extends StatelessWidget {
  final String name;
  final String kostName;
  final String date;
  final String status;
  final Color statusTextColor;
  final Color statusBackgroundColor;
  final Color iconColor;
  final Color iconBackground;

  const BookingItem({
    super.key,
    required this.name,
    required this.kostName,
    required this.date,
    required this.status,
    required this.statusTextColor,
    required this.statusBackgroundColor,
    required this.iconColor,
    required this.iconBackground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE1E1E1),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline_rounded,
              color: iconColor,
              size: 31,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16.5,
                    color: Color(0xFF080B17),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  kostName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    color: Color(0xFF4A4A4A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: Color(0xFF4A4A4A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            constraints: const BoxConstraints(
              minWidth: 74,
              maxWidth: 104,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: statusBackgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              status,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: statusTextColor,
                fontSize: 12.5,
                height: 1.15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFA7A7A7),
            size: 32,
          ),
        ],
      ),
    );
  }
}

class EmptyBookingCard extends StatelessWidget {
  const EmptyBookingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE1E1E1),
          width: 1.2,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 42,
            color: ThemeApp.textGrey,
          ),
          SizedBox(height: 10),
          Text(
            'Belum ada pemesanan',
            style: TextStyle(
              color: ThemeApp.textDark,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Data pemesanan terbaru akan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ThemeApp.textGrey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminBottomNavigation extends StatelessWidget {
  const AdminBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.symmetric(
        horizontal: 34,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(30),
        ),
        border: Border.all(
          color: const Color(0xFFE1E1E1),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Icon(
            Icons.home_rounded,
            color: Color(0xFF0A3348),
            size: 36,
          ),
          Icon(
            Icons.apartment_rounded,
            color: Color(0xFFD6D6D6),
            size: 34,
          ),
          Icon(
            Icons.assignment_rounded,
            color: Color(0xFFD6D6D6),
            size: 34,
          ),
          Icon(
            Icons.person_rounded,
            color: Color(0xFFD6D6D6),
            size: 36,
          ),
        ],
      ),
    );
  }
}