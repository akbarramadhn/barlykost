import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/bottomnav.dart';
import '../../../widgets/emptystate.dart';
import '../kost/daftarkost.dart';
import '../kost/kost_detail.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  late Future<List<_HistoryItem>> historyFuture;

  int selectedNavIndex = 2;

  static const Color darkTeal = ThemeApp.buttonColor;
  static const Color locationBlue = Color(0xFF6AB8FF);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textGrey = Color(0xFF777777);
  static const Color successGreen = Color(0xFF0A9B25);
  static const Color pendingOrange = Color(0xFFFF9800);
  static const Color dangerRed = Color(0xFFE53935);

  @override
  void initState() {
    super.initState();
    historyFuture = fetchHistory();
  }

  Future<List<_HistoryItem>> fetchHistory() async {
    try {
      final authUser = supabase.auth.currentUser;

      if (authUser == null) {
        return [];
      }

      final email = authUser.email ?? '';

      if (email.trim().isEmpty) {
        return [];
      }

      final userResponse = await supabase
          .from('users')
          .select('id, email, full_name')
          .eq('email', email)
          .maybeSingle();

      if (userResponse == null) {
        return [];
      }

      final userId = userResponse['id']?.toString() ?? '';

      if (userId.trim().isEmpty) {
        return [];
      }

      final bookingResponse = await supabase
          .from('bookings')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final bookings = List<Map<String, dynamic>>.from(
        bookingResponse.map((item) => Map<String, dynamic>.from(item)),
      );

      final List<_HistoryItem> result = [];

      for (final booking in bookings) {
        final kostId = booking['kost_id']?.toString() ?? '';

        if (kostId.trim().isEmpty) {
          continue;
        }

        final kostResponse = await supabase
            .from('kosts')
            .select('id, nama_kost, lokasi, harga, rating, tersedia')
            .eq('id', kostId)
            .maybeSingle();

        if (kostResponse == null) {
          continue;
        }

        final imageResponse = await supabase
            .from('kost_images')
            .select('image_url')
            .eq('kost_id', kostId)
            .limit(1);

        String imageUrl = '';

        if (imageResponse.isNotEmpty) {
          imageUrl = imageResponse.first['image_url']?.toString() ?? '';
        }

        result.add(
          _HistoryItem(
            bookingId: booking['id']?.toString() ?? '',
            kostId: kostId,
            kostName: kostResponse['nama_kost']?.toString() ?? 'Nama kost',
            location: kostResponse['lokasi']?.toString() ?? '-',
            imageUrl: imageUrl,
            status: booking['status']?.toString() ?? 'pending',
            startDate: getDateValue(
              booking,
              [
                'start_date',
                'check_in_date',
                'tanggal_mulai',
                'tanggal_masuk',
              ],
            ),
            endDate: getDateValue(
              booking,
              [
                'end_date',
                'check_out_date',
                'tanggal_selesai',
                'tanggal_keluar',
              ],
            ),
            totalPrice: getNumberValue(
              booking,
              [
                'total_price',
                'total_harga',
                'amount',
                'harga_total',
              ],
            ),
            createdAt: booking['created_at']?.toString() ?? '',
          ),
        );
      }

      return result;
    } catch (error) {
      debugPrint('Fetch history error: $error');
      return [];
    }
  }

  String getDateValue(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return '';
  }

  num getNumberValue(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value is num) {
        return value;
      }

      if (value != null) {
        return num.tryParse(value.toString()) ?? 0;
      }
    }

    return 0;
  }

  Future<void> refreshData() async {
    setState(() {
      historyFuture = fetchHistory();
    });

    await historyFuture;
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
      ),
      child: Scaffold(
        backgroundColor: ThemeApp.primaryDark,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: ThemeApp.backgroundGradient,
          child: SafeArea(
            bottom: false,
            child: FutureBuilder<List<_HistoryItem>>(
              future: historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: darkTeal,
                    ),
                  );
                }

                final histories = snapshot.data ?? [];

                return RefreshIndicator(
                  color: darkTeal,
                  onRefresh: refreshData,
                  child: Column(
                    children: [
                      buildTopBar(),
                      Expanded(
                        child: histories.isEmpty
                            ? buildEmptyHistory()
                            : buildHistoryList(histories),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: selectedNavIndex,
          onTap: handleBottomNavTap,
        ),
      ),
    );
  }

  Widget buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: SizedBox(
        height: 54,
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pop(context);
              },
              child: const SizedBox(
                width: 46,
                height: 46,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF303030),
                  size: 30,
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Riwayat',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 46),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyHistory() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 90, 22, 28),
      children: [
        Container(
          width: double.infinity,
          height: 320,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const EmptyState(
            icon: Icons.history_rounded,
            title: 'Belum ada riwayat',
            message:
                'Riwayat pemesanan kost kamu akan muncul setelah kamu melakukan booking.',
          ),
        ),
      ],
    );
  }

  Widget buildHistoryList(List<_HistoryItem> histories) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 118),
      itemCount: histories.length,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 16);
      },
      itemBuilder: (context, index) {
        return buildHistoryCard(histories[index]);
      },
    );
  }

  Widget buildHistoryCard(_HistoryItem item) {
    return GestureDetector(
      onTap: () {
        openDetailKost(item.kostId);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: buildKostImage(
                imageUrl: item.imageUrl,
                width: 112,
                height: 128,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: SizedBox(
                height: 128,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildStatusBadge(item.status),
                    const SizedBox(height: 8),
                    Text(
                      item.kostName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    buildInfoRow(
                      icon: Icons.calendar_month_rounded,
                      iconColor: locationBlue,
                      text: buildDateText(item),
                    ),
                    const SizedBox(height: 7),
                    buildInfoRow(
                      icon: Icons.location_on_outlined,
                      iconColor: locationBlue,
                      text: item.location,
                    ),
                    const Spacer(),
                    Text(
                      item.totalPrice > 0
                          ? formatRupiah(item.totalPrice)
                          : 'Harga menyesuaikan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ThemeApp.buttonColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatusBadge(String status) {
    final label = getStatusLabel(status);
    final color = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 21,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF303030),
              fontSize: 13.8,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildKostImage({
    required String imageUrl,
    required double width,
    required double height,
  }) {
    if (imageUrl.trim().isEmpty) {
      return buildImagePlaceholder(
        width: width,
        height: height,
      );
    }

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return buildImagePlaceholder(
          width: width,
          height: height,
        );
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }

        return Container(
          width: width,
          height: height,
          color: const Color(0xFFEAF6F4),
          child: const Center(
            child: CircularProgressIndicator(
              color: darkTeal,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }

  Widget buildImagePlaceholder({
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFEAF6F4),
      child: const Center(
        child: Icon(
          Icons.home_work_outlined,
          color: darkTeal,
          size: 38,
        ),
      ),
    );
  }

  String buildDateText(_HistoryItem item) {
    if (item.startDate.trim().isNotEmpty && item.endDate.trim().isNotEmpty) {
      return '${formatDate(item.startDate)} - ${formatDate(item.endDate)}';
    }

    if (item.startDate.trim().isNotEmpty) {
      return 'Mulai ${formatDate(item.startDate)}';
    }

    if (item.createdAt.trim().isNotEmpty) {
      return 'Dibuat ${formatDate(item.createdAt)}';
    }

    return 'Tanggal belum tersedia';
  }

  String formatDate(String value) {
    try {
      final date = DateTime.parse(value);
      final months = [
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
    } catch (_) {
      return value;
    }
  }

  String getStatusLabel(String status) {
    final normalized = status.toLowerCase().trim();

    if (normalized == 'approved' ||
        normalized == 'accepted' ||
        normalized == 'confirmed' ||
        normalized == 'success' ||
        normalized == 'selesai') {
      return 'Selesai';
    }

    if (normalized == 'rejected' ||
        normalized == 'cancelled' ||
        normalized == 'canceled' ||
        normalized == 'ditolak' ||
        normalized == 'batal') {
      return 'Dibatalkan';
    }

    if (normalized == 'paid' || normalized == 'lunas') {
      return 'Lunas';
    }

    return 'Menunggu';
  }

  Color getStatusColor(String status) {
    final normalized = status.toLowerCase().trim();

    if (normalized == 'approved' ||
        normalized == 'accepted' ||
        normalized == 'confirmed' ||
        normalized == 'success' ||
        normalized == 'selesai' ||
        normalized == 'paid' ||
        normalized == 'lunas') {
      return successGreen;
    }

    if (normalized == 'rejected' ||
        normalized == 'cancelled' ||
        normalized == 'canceled' ||
        normalized == 'ditolak' ||
        normalized == 'batal') {
      return dangerRed;
    }

    return pendingOrange;
  }

  String formatRupiah(num value) {
    final raw = value.round().toString();
    String result = '';
    int counter = 0;

    for (int i = raw.length - 1; i >= 0; i--) {
      result = raw[i] + result;
      counter++;

      if (counter % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }

    return 'Rp $result';
  }

  void openDetailKost(String kostId) {
    if (kostId.trim().isEmpty) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailKostScreen(
          kostId: kostId,
        ),
      ),
    );
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

    if (index == 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Halaman wishlist akan disambungkan setelah dirapikan'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    if (index == 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Halaman profil akan disambungkan setelah dirapikan'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}

class _HistoryItem {
  final String bookingId;
  final String kostId;
  final String kostName;
  final String location;
  final String imageUrl;
  final String status;
  final String startDate;
  final String endDate;
  final num totalPrice;
  final String createdAt;

  const _HistoryItem({
    required this.bookingId,
    required this.kostId,
    required this.kostName,
    required this.location,
    required this.imageUrl,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.createdAt,
  });
}