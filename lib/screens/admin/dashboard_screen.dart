import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  late Future<AdminDashboardData> dashboardFuture;

  static const Color darkTeal = ThemeApp.buttonColor;
  static const Color softBlue = Color(0xFFD8ECFF);
  static const Color cardWhite = Colors.white;

  @override
  void initState() {
    super.initState();
    dashboardFuture = loadDashboardData();
  }

  Future<void> refreshDashboard() async {
    setState(() {
      dashboardFuture = loadDashboardData();
    });

    await dashboardFuture;
  }

  Future<AdminDashboardData> loadDashboardData() async {
    final adminProfile = await fetchAdminProfile();
    final users = await fetchUsers();
    final kosts = await fetchKosts();
    final bookings = await fetchBookings();
    final payments = await fetchPayments();

    final totalPenyewa = users.where((user) {
      return user.role.toLowerCase() == 'penyewa';
    }).length;

    final totalAdmin = users.where((user) {
      return user.role.toLowerCase() == 'admin';
    }).length;

    final totalKost = kosts.length;

    final totalKamarTersedia = kosts.fold<int>(0, (previous, kost) {
      return previous + kost.available;
    });

    final totalPesanan = bookings.length;

    final totalPendapatan = payments.fold<int>(0, (previous, payment) {
      return previous + payment.amount;
    });

    return AdminDashboardData(
      adminName: adminProfile.name,
      totalPenyewa: totalPenyewa,
      totalAdmin: totalAdmin,
      totalKost: totalKost,
      totalKamarTersedia: totalKamarTersedia,
      totalPesanan: totalPesanan,
      totalPendapatan: totalPendapatan,
      kosts: kosts,
      bookings: bookings,
    );
  }

  Future<AdminProfile> fetchAdminProfile() async {
    final authUser = supabase.auth.currentUser;

    if (authUser == null) {
      return const AdminProfile(
        name: 'Admin',
        email: '',
      );
    }

    final email = authUser.email ?? '';

    try {
      final response = await supabase
          .from('users')
          .select('id, full_name, email, role')
          .eq('email', email)
          .maybeSingle();

      if (response == null) {
        return AdminProfile(
          name: getNameFromAuth(authUser),
          email: email,
        );
      }

      return AdminProfile(
        name: response['full_name']?.toString() ?? getNameFromAuth(authUser),
        email: response['email']?.toString() ?? email,
      );
    } catch (error) {
      debugPrint('Fetch admin profile error: $error');

      return AdminProfile(
        name: getNameFromAuth(authUser),
        email: email,
      );
    }
  }

  Future<List<UserModel>> fetchUsers() async {
    try {
      final response = await supabase
          .from('users')
          .select('id, role, email, phone, full_name, created_at')
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;

      return data.map((item) {
        final row = Map<String, dynamic>.from(item as Map);
        return UserModel.fromMap(row);
      }).toList();
    } catch (error) {
      debugPrint('Fetch users error: $error');
      return [];
    }
  }

  Future<List<KostModel>> fetchKosts() async {
    try {
      final response = await supabase
          .from('kosts')
          .select(
            'id, harga, lokasi, rating, owner_id, tersedia, deskripsi, nama_kost, created_at',
          )
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;

      return data.map((item) {
        final row = Map<String, dynamic>.from(item as Map);
        return KostModel.fromMap(row);
      }).toList();
    } catch (error) {
      debugPrint('Fetch kosts error: $error');
      return [];
    }
  }

  Future<List<BookingModel>> fetchBookings() async {
    try {
      final response = await supabase.from('bookings').select();

      final List<dynamic> data = response as List<dynamic>;

      final bookings = data.map((item) {
        final row = Map<String, dynamic>.from(item as Map);
        return BookingModel.fromMap(row);
      }).toList();

      bookings.sort((a, b) {
        return b.createdAt.compareTo(a.createdAt);
      });

      return bookings;
    } catch (error) {
      debugPrint('Fetch bookings error: $error');
      return [];
    }
  }

  Future<List<PaymentModel>> fetchPayments() async {
    try {
      final response = await supabase.from('payments').select();

      final List<dynamic> data = response as List<dynamic>;

      return data.map((item) {
        final row = Map<String, dynamic>.from(item as Map);
        return PaymentModel.fromMap(row);
      }).toList();
    } catch (error) {
      debugPrint('Fetch payments error: $error');
      return [];
    }
  }

  String getNameFromAuth(User user) {
    final metadata = user.userMetadata;

    final nameFromMetadata = metadata?['full_name'] ??
        metadata?['name'] ??
        metadata?['nama'] ??
        metadata?['username'];

    if (nameFromMetadata != null &&
        nameFromMetadata.toString().trim().isNotEmpty) {
      return nameFromMetadata.toString().trim();
    }

    final email = user.email ?? '';

    if (email.contains('@')) {
      final nameFromEmail = email.split('@').first.replaceAll('.', ' ');
      return capitalizeName(nameFromEmail);
    }

    return 'Admin';
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
      backgroundColor: ThemeApp.primaryDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: ThemeApp.backgroundGradient,
        child: SafeArea(
          child: FutureBuilder<AdminDashboardData>(
            future: dashboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: darkTeal,
                  ),
                );
              }

              final data = snapshot.data ?? AdminDashboardData.empty();

              return RefreshIndicator(
                color: darkTeal,
                onRefresh: refreshDashboard,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildHeader(data),
                      const SizedBox(height: 22),
                      buildWelcomeCard(data),
                      const SizedBox(height: 18),
                      buildStatisticGrid(data),
                      const SizedBox(height: 24),
                      buildSectionHeader(
                        title: 'Data Kost',
                        actionText: 'Lihat Semua',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      buildKostList(data.kosts),
                      const SizedBox(height: 24),
                      buildSectionHeader(
                        title: 'Pesanan Terbaru',
                        actionText: 'Lihat Semua',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      buildBookingList(data.bookings),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildHeader(AdminDashboardData data) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFD1E9B7),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.admin_panel_settings_rounded,
            color: darkTeal,
            size: 30,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard Admin',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.adminName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: logout,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: darkTeal,
              size: 25,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildWelcomeCard(AdminDashboardData data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.88),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: softBlue,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.home_work_rounded,
              color: darkTeal,
              size: 31,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat datang kembali!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kelola data kost, penyewa, dan pesanan Barly Kost.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
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

  Widget buildStatisticGrid(AdminDashboardData data) {
    final stats = [
      StatisticModel(
        title: 'Total Penyewa',
        value: data.totalPenyewa.toString(),
        icon: Icons.people_alt_rounded,
      ),
      StatisticModel(
        title: 'Total Kost',
        value: data.totalKost.toString(),
        icon: Icons.home_work_rounded,
      ),
      StatisticModel(
        title: 'Total Pesanan',
        value: data.totalPesanan.toString(),
        icon: Icons.receipt_long_rounded,
      ),
      StatisticModel(
        title: 'Kamar Tersedia',
        value: data.totalKamarTersedia.toString(),
        icon: Icons.meeting_room_rounded,
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
      height: 108,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: softBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              stat.icon,
              color: darkTeal,
              size: 27,
            ),
          ),
          const SizedBox(width: 10),
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
                    color: Colors.black,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  stat.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.88),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              actionText,
              style: const TextStyle(
                color: darkTeal,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildKostList(List<KostModel> kosts) {
    if (kosts.isEmpty) {
      return buildEmptyCard(
        icon: Icons.home_work_outlined,
        text: 'Data kost belum tersedia',
      );
    }

    return Column(
      children: kosts.take(3).map((kost) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: buildKostCard(kost),
        );
      }).toList(),
    );
  }

  Widget buildKostCard(KostModel kost) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: softBlue,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.home_rounded,
              color: darkTeal,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kost.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF6AB8FF),
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        kost.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  '${formatRupiah(kost.price)} /bulan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkTeal,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFB000),
                    size: 19,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    kost.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: softBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${kost.available} kosong',
                  style: const TextStyle(
                    color: darkTeal,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildBookingList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return buildEmptyCard(
        icon: Icons.receipt_long_outlined,
        text: 'Belum ada pesanan masuk',
      );
    }

    return Column(
      children: bookings.take(3).map((booking) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: buildBookingCard(booking),
        );
      }).toList(),
    );
  }

  Widget buildBookingCard(BookingModel booking) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: softBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: darkTeal,
              size: 29,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  booking.createdAtText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: softBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              booking.status,
              style: const TextStyle(
                color: darkTeal,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
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
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: darkTeal,
            size: 27,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String formatRupiah(int value) {
    final text = value.toString();
    final reversed = text.split('').reversed.toList();
    final buffer = StringBuffer();

    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(reversed[i]);
    }

    final result = buffer.toString().split('').reversed.join();
    return 'Rp $result';
  }

  static String formatDate(dynamic value) {
    if (value == null) {
      return '-';
    }

    final parsedDate = DateTime.tryParse(value.toString());

    if (parsedDate == null) {
      return value.toString();
    }

    const months = [
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

    return '${parsedDate.day} ${months[parsedDate.month - 1]} ${parsedDate.year}';
  }

  static String capitalizeName(String value) {
    return value
        .split(' ')
        .where((word) => word.trim().isNotEmpty)
        .map((word) {
      final cleanWord = word.trim();

      if (cleanWord.length == 1) {
        return cleanWord.toUpperCase();
      }

      return cleanWord[0].toUpperCase() + cleanWord.substring(1).toLowerCase();
    }).join(' ');
  }
}

class AdminDashboardData {
  final String adminName;
  final int totalPenyewa;
  final int totalAdmin;
  final int totalKost;
  final int totalKamarTersedia;
  final int totalPesanan;
  final int totalPendapatan;
  final List<KostModel> kosts;
  final List<BookingModel> bookings;

  const AdminDashboardData({
    required this.adminName,
    required this.totalPenyewa,
    required this.totalAdmin,
    required this.totalKost,
    required this.totalKamarTersedia,
    required this.totalPesanan,
    required this.totalPendapatan,
    required this.kosts,
    required this.bookings,
  });

  factory AdminDashboardData.empty() {
    return const AdminDashboardData(
      adminName: 'Admin',
      totalPenyewa: 0,
      totalAdmin: 0,
      totalKost: 0,
      totalKamarTersedia: 0,
      totalPesanan: 0,
      totalPendapatan: 0,
      kosts: [],
      bookings: [],
    );
  }
}

class AdminProfile {
  final String name;
  final String email;

  const AdminProfile({
    required this.name,
    required this.email,
  });
}

class UserModel {
  final String id;
  final String role;
  final String email;
  final String phone;
  final String fullName;

  const UserModel({
    required this.id,
    required this.role,
    required this.email,
    required this.phone,
    required this.fullName,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      role: map['role']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      fullName: map['full_name']?.toString() ?? '',
    );
  }
}

class KostModel {
  final String id;
  final String name;
  final String location;
  final int price;
  final double rating;
  final int available;
  final String description;

  const KostModel({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.available,
    required this.description,
  });

  factory KostModel.fromMap(Map<String, dynamic> map) {
    return KostModel(
      id: map['id']?.toString() ?? '',
      name: map['nama_kost']?.toString() ?? 'Nama kost belum tersedia',
      location: map['lokasi']?.toString() ?? 'Lokasi belum tersedia',
      price: int.tryParse(map['harga']?.toString() ?? '0') ?? 0,
      rating: double.tryParse(map['rating']?.toString() ?? '0') ?? 0,
      available: int.tryParse(map['tersedia']?.toString() ?? '0') ?? 0,
      description: map['deskripsi']?.toString() ?? '',
    );
  }
}

class BookingModel {
  final String id;
  final String title;
  final String status;
  final DateTime createdAt;
  final String createdAtText;

  const BookingModel({
    required this.id,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.createdAtText,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    final createdAtValue = map['created_at'];
    final parsedDate = DateTime.tryParse(createdAtValue?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);

    final rawStatus = map['status']?.toString();

    return BookingModel(
      id: map['id']?.toString() ?? '',
      title: map['nama_kost']?.toString() ??
          map['kost_name']?.toString() ??
          map['id']?.toString() ??
          'Pesanan Kost',
      status: rawStatus == null || rawStatus.trim().isEmpty
          ? 'Baru'
          : rawStatus,
      createdAt: parsedDate,
      createdAtText: _DashboardScreenState.formatDate(createdAtValue),
    );
  }
}

class PaymentModel {
  final String id;
  final int amount;

  const PaymentModel({
    required this.id,
    required this.amount,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    final rawAmount = map['amount'] ??
        map['total'] ??
        map['nominal'] ??
        map['jumlah'] ??
        map['harga'];

    return PaymentModel(
      id: map['id']?.toString() ?? '',
      amount: int.tryParse(rawAmount?.toString() ?? '0') ?? 0,
    );
  }
}

class StatisticModel {
  final String title;
  final String value;
  final IconData icon;

  const StatisticModel({
    required this.title,
    required this.value,
    required this.icon,
  });
}