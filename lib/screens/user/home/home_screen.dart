import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/penyewa/kost.dart';
import '../../../models/penyewa/booking.dart';
import '../../../models/user.dart';
import '../../../services/penyewa/kost_service.dart';
import '../../../services/penyewa/booking_service.dart';
import '../../../widgets/bottomnav.dart';
import '../../../widgets/emptystate.dart';
import '../../../widgets/kostcard.dart';
import '../../../widgets/searchbar.dart';
import '../history/history_screen.dart';
import '../kost/daftarkost.dart';
import '../kost/kost_detail.dart';
import '../profile/profile_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../notification/notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final KostService kostService = KostService();
  final BookingService bookingService = BookingService();

  late Future<UserModel> userFuture;
  late Future<List<KostModel>> kostFuture;
  late Future<List<Booking>> confirmedBookingFuture;

  int selectedNavIndex = 0;

  static const Color darkTeal = ThemeApp.buttonColor;
  static const Color locationBlue = Color(0xFF6AB8FF);
  static const Color softBlue = Color(0xFFD8ECFF);

  @override
  void initState() {
    super.initState();
    userFuture = fetchCurrentUser();
    kostFuture = fetchKosts();
    confirmedBookingFuture = fetchConfirmedBookings();
  }

  Future<UserModel> fetchCurrentUser() async {
    try {
      final authUser = supabase.auth.currentUser;

      if (authUser == null) {
        return UserModel.empty();
      }

      final email = authUser.email?.trim().toLowerCase() ?? '';

      Map<String, dynamic>? response = await supabase
          .from('users')
          .select(
            'id, role, email, phone, full_name, created_at, profile_image_url',
          )
          .eq('id', authUser.id)
          .maybeSingle();

      if (response != null) {
        return UserModel.fromMap(Map<String, dynamic>.from(response));
      }

      if (email.isEmpty) {
        return UserModel.empty();
      }

      response = await supabase
          .from('users')
          .select(
            'id, role, email, phone, full_name, created_at, profile_image_url',
          )
          .ilike('email', email)
          .maybeSingle();

      if (response == null) {
        return UserModel.empty();
      }

      return UserModel.fromMap(Map<String, dynamic>.from(response));
    } catch (error) {
      debugPrint('Fetch current user error: $error');
      return UserModel.empty();
    }
  }

  Future<List<KostModel>> fetchKosts() async {
    try {
      return await kostService.fetchKostsWithImages();
    } catch (error) {
      debugPrint('Fetch home kost error: $error');
      return [];
    }
  }

  Future<List<Booking>> fetchConfirmedBookings() async {
    try {
      final bookings = await bookingService.getCurrentUserBookings();

      return bookings.where((booking) {
        return booking.normalizedStatus == Booking.confirmed;
      }).toList();
    } catch (error) {
      debugPrint('Fetch confirmed bookings error: $error');
      return [];
    }
  }

  Future<void> refreshData() async {
    setState(() {
      userFuture = fetchCurrentUser();
      kostFuture = fetchKosts();
      confirmedBookingFuture = fetchConfirmedBookings();
    });

    await Future.wait([
      userFuture,
      kostFuture,
      confirmedBookingFuture,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: ThemeApp.backgroundGradient,
          child: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: darkTeal,
              onRefresh: refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildHeader(),
                    const SizedBox(height: 26),
                    buildSearchBar(),
                    const SizedBox(height: 24),
                    buildCategoryRow(),
                    const SizedBox(height: 28),
                    buildBookingHistorySection(),
                    const SizedBox(height: 28),
                    buildRecommendationSection(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
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

  Widget buildHeader() {
    return FutureBuilder<UserModel>(
      future: userFuture,
      builder: (context, snapshot) {
        final user = snapshot.data ?? UserModel.empty();
        final displayName = user.displayName.trim().isEmpty
            ? 'Penyewa'
            : user.displayName.trim();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(onTap: openProfile, child: buildAvatar(user)),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: openProfile,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, $displayName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Mau cari kost-kostan?',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: openWishlist,
              child: const Icon(
                Icons.favorite_border_rounded,
                color: darkTeal,
                size: 38,
              ),
            ),
            const SizedBox(width: 10),
            Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationScreen(),
                      ),
                    );
                  },
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: Icon(
                        Icons.notifications_none_rounded,
                        color: darkTeal,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 1,
                  top: 2,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: const BoxDecoration(
                      color: darkTeal,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget buildAvatar(UserModel user) {
    if (user.profileImageUrl.trim().isNotEmpty) {
      return Container(
        width: 74,
        height: 74,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            ThemeApp.softShadow(
              alpha: 0.08,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.network(
            user.profileImageUrl,
            width: 70,
            height: 70,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }

              return Container(
                color: const Color(0xFFC8DFA4),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: darkTeal,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFFC8DFA4),
                child: const Icon(
                  Icons.person_rounded,
                  color: darkTeal,
                  size: 50,
                ),
              );
            },
          ),
        ),
      );
    }

    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        color: const Color(0xFFC8DFA4),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Icon(Icons.person_rounded, color: darkTeal, size: 50),
    );
  }

  Widget buildSearchBar() {
    return SearchBarWidget(
      hintText: 'Cari kost anda',
      showFilter: false,
      readOnly: true,
      margin: EdgeInsets.zero,
      onTap: openCariKost,
    );
  }

  Widget buildCategoryRow() {
    return SizedBox(
      height: 112,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildCategoryItem(icon: Icons.savings_outlined, title: 'Termurah'),
          buildCategoryItem(icon: Icons.receipt_long_rounded, title: 'Tahunan'),
          buildCategoryItem(
            icon: Icons.calendar_month_rounded,
            title: 'Bulanan',
          ),
          buildCategoryItem(
            icon: Icons.volunteer_activism_rounded,
            title: 'Terbersih',
          ),
        ],
      ),
    );
  }

  Widget buildCategoryItem({required IconData icon, required String title}) {
    return GestureDetector(
      onTap: openCariKost,
      child: SizedBox(
        width: 76,
        height: 112,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: softBlue,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, color: darkTeal, size: 35),
            ),
            const SizedBox(height: 9),
            SizedBox(
              height: 22,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBookingHistorySection() {
    return FutureBuilder<List<Booking>>(
      future: confirmedBookingFuture,
      builder: (context, snapshot) {
        final bookings = snapshot.data ?? [];
        final booking = bookings.isNotEmpty ? bookings.first : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: buildSectionTitle('Riwayat Pemesanan'),
                ),
                if (bookings.isNotEmpty)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: openHistory,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      child: Text(
                        'Lihat Semua',
                        style: TextStyle(
                          color: darkTeal,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            if (snapshot.connectionState == ConnectionState.waiting)
              buildHistoryLoadingCard()
            else if (booking == null)
              buildEmptyHistoryCard()
            else
              buildBookingHistoryCard(booking),
          ],
        );
      },
    );
  }

  Widget buildBookingHistoryCard(Booking booking) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: openHistory,
      onLongPress: () {
        openDetailKost(booking.kostId);
      },
      child: Container(
        width: double.infinity,
        height: 158,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.90),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: buildKostImage(
                imageUrl: booking.kostImageUrl,
                width: 115,
                height: 138,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.kostName.trim().isEmpty
                          ? 'Kost'
                          : booking.kostName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const Spacer(),
                    buildHistoryInfoRow(
                      icon: Icons.calendar_month_rounded,
                      text:
                          '${formatShortDate(booking.startDate)} - ${formatShortDate(booking.endDate)}',
                    ),
                    const SizedBox(height: 8),
                    buildHistoryInfoRow(
                      icon: Icons.location_on_outlined,
                      text: booking.kostLocation.trim().isEmpty
                          ? '-'
                          : booking.kostLocation,
                    ),
                    const SizedBox(height: 8),
                    buildHistoryInfoRow(
                      icon: Icons.check_circle_rounded,
                      text: booking.statusLabel,
                      iconColor: ThemeApp.successGreen,
                      textColor: ThemeApp.successGreen,
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

  Widget buildHistoryInfoRow({
    required IconData icon,
    required String text,
    Color iconColor = locationBlue,
    Color textColor = Colors.black,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  String formatShortDate(DateTime date) {
    const months = [
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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget buildHistoryLoadingCard() {
    return Container(
      width: double.infinity,
      height: 158,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.90),
          width: 1.2,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: darkTeal, strokeWidth: 2),
      ),
    );
  }

  Widget buildEmptyHistoryCard() {
    return Container(
      width: double.infinity,
      height: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.90),
          width: 1.2,
        ),
      ),
      child: const EmptyState(
        icon: Icons.receipt_long_rounded,
        title: 'Belum ada riwayat',
        message: 'Riwayat pemesanan kost kamu akan muncul di sini.',
      ),
    );
  }

  Widget buildRecommendationSection() {
    return FutureBuilder<List<KostModel>>(
      future: kostFuture,
      builder: (context, snapshot) {
        final kosts = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: buildSectionTitle('Rekomendasi Terbaik'),
            ),
            const SizedBox(height: 16),
            if (snapshot.connectionState == ConnectionState.waiting)
              buildRecommendationLoading()
            else if (kosts.isEmpty)
              buildEmptyRecommendationCard()
            else
              SizedBox(
                height: 270,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: kosts.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(width: 16);
                  },
                  itemBuilder: (context, index) {
                    final kost = kosts[index];

                    return KostCard(
                      width: 238,
                      margin: EdgeInsets.zero,
                      namaKost: kost.name,
                      lokasi: kost.location,
                      harga: kost.price,
                      rating: kost.rating,
                      imageUrl: kost.imageUrl,
                      onTap: () {
                        openDetailKost(kost.id);
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget buildRecommendationLoading() {
    return Container(
      width: 238,
      height: 315,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: darkTeal, strokeWidth: 2),
      ),
    );
  }

  Widget buildEmptyRecommendationCard() {
    return Container(
      width: double.infinity,
      height: 210,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const EmptyState(
        icon: Icons.home_work_outlined,
        title: 'Data kost belum tersedia',
        message: 'Nanti daftar rekomendasi kost akan muncul di bagian ini.',
      ),
    );
  }

  Widget buildKostImage({
    required String imageUrl,
    required double width,
    required double height,
  }) {
    if (imageUrl.trim().isEmpty) {
      return buildImagePlaceholder(width: width, height: height);
    }

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return buildImagePlaceholder(width: width, height: height);
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
            child: CircularProgressIndicator(color: darkTeal, strokeWidth: 2),
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
        child: Icon(Icons.home_work_outlined, color: darkTeal, size: 42),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 21,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  void openCariKost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CariKostScreen()),
    );
  }

  void openDetailKost(String kostId) {
    if (kostId.trim().isEmpty) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailKostScreen(kostId: kostId)),
    );
  }

  void openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
  }

  void openWishlist() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WishlistScreen()),
    );
  }

  Future<void> openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );

    if (!mounted) {
      return;
    }

    await refreshData();
  }

  void handleBottomNavTap(int index) {
    if (index == selectedNavIndex) {
      return;
    }

    if (index == 1) {
      openCariKost();
      return;
    }

    if (index == 2) {
      openHistory();
      return;
    }

    if (index == 3) {
      openProfile();
      return;
    }
  }
}
