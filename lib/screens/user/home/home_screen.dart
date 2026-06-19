import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/kost.dart';
import '../../../models/user.dart';
import '../../../services/kost_service.dart';
import '../kost/daftarkost.dart';
import '../kost/kost_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final KostService kostService = KostService();

  late Future<UserModel> userFuture;
  late Future<List<KostModel>> kostFuture;

  int selectedNavIndex = 0;

  static const Color darkTeal = ThemeApp.buttonColor;
  static const Color locationBlue = Color(0xFF6AB8FF);
  static const Color starColor = Color(0xFFFFB000);
  static const Color softBlue = Color(0xFFD8ECFF);

  @override
  void initState() {
    super.initState();
    userFuture = fetchCurrentUser();
    kostFuture = fetchKosts();
  }

  Future<UserModel> fetchCurrentUser() async {
    try {
      final authUser = supabase.auth.currentUser;

      if (authUser == null) {
        return UserModel.empty();
      }

      final email = authUser.email ?? '';

      if (email.isEmpty) {
        return UserModel.empty();
      }

      final response = await supabase
          .from('users')
          .select('id, role, email, phone, full_name')
          .eq('email', email)
          .maybeSingle();

      if (response == null) {
        return UserModel.empty();
      }

      return UserModel.fromMap(
        Map<String, dynamic>.from(response),
      );
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

  Future<void> refreshData() async {
    setState(() {
      userFuture = fetchCurrentUser();
      kostFuture = fetchKosts();
    });

    await Future.wait([
      userFuture,
      kostFuture,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
      ),
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
                    const SizedBox(height: 30),
                    buildSearchBar(),
                    const SizedBox(height: 26),
                    buildCategoryRow(),
                    const SizedBox(height: 30),
                    buildBookingHistorySection(),
                    const SizedBox(height: 30),
                    buildRecommendationSection(),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: buildBottomNavigationBar(),
      ),
    );
  }

  Widget buildHeader() {
    return FutureBuilder<UserModel>(
      future: userFuture,
      builder: (context, snapshot) {
        final user = snapshot.data ?? UserModel.empty();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildAvatar(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, ${user.fullName}',
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
                    'Mau Cari Kost-kostan?',
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
            const SizedBox(width: 10),
            const Icon(
              Icons.favorite_border_rounded,
              color: darkTeal,
              size: 39,
            ),
            const SizedBox(width: 10),
            Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: darkTeal,
                  size: 41,
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

  Widget buildAvatar() {
    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        color: const Color(0xFFC8DFA4),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.person_rounded,
        color: darkTeal,
        size: 50,
      ),
    );
  }

  Widget buildSearchBar() {
    return GestureDetector(
      onTap: openCariKost,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(36),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: Colors.grey.shade400,
              size: 33,
            ),
            const SizedBox(width: 15),
            Text(
              'Cari kost anda',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 19,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryRow() {
    return SizedBox(
      height: 114,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildCategoryItem(
            icon: Icons.savings_outlined,
            title: 'Termurah',
          ),
          buildCategoryItem(
            icon: Icons.receipt_long_rounded,
            title: 'Tahunan',
          ),
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

  Widget buildCategoryItem({
    required IconData icon,
    required String title,
  }) {
    return GestureDetector(
      onTap: openCariKost,
      child: SizedBox(
        width: 76,
        height: 114,
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
              child: Icon(
                icon,
                color: darkTeal,
                size: 35,
              ),
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
    return FutureBuilder<List<KostModel>>(
      future: kostFuture,
      builder: (context, snapshot) {
        final kosts = snapshot.data ?? [];
        final kost = kosts.isNotEmpty ? kosts.first : KostModel.empty();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riwayat Pemesanan',
              style: TextStyle(
                color: Colors.black,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 15),
            if (snapshot.connectionState == ConnectionState.waiting)
              buildHistoryLoadingCard()
            else if (kosts.isEmpty)
              buildEmptyHistoryCard()
            else
              buildBookingHistoryCard(kost),
          ],
        );
      },
    );
  }

  Widget buildBookingHistoryCard(KostModel kost) {
    return GestureDetector(
      onTap: () {
        openDetailKost(kost.id);
      },
      child: Container(
        width: double.infinity,
        height: 140,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.9),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: buildKostImage(
                imageUrl: kost.imageUrl,
                width: 115,
                height: 120,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kost.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    buildHistoryInfoRow(
                      icon: Icons.calendar_month_rounded,
                      text: '1 Januari 2023 - 1 Januari 2026',
                    ),
                    buildHistoryInfoRow(
                      icon: Icons.location_on_outlined,
                      text: '${kost.location}, Jakarta Selatan',
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
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF0D74FF),
          size: 25,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildHistoryLoadingCard() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.9),
          width: 1.2,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: darkTeal,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget buildEmptyHistoryCard() {
    return Container(
      width: double.infinity,
      height: 140,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.9),
          width: 1.2,
        ),
      ),
      child: const Center(
        child: Text(
          'Belum ada riwayat pemesanan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
          ),
        ),
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
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Text(
                'Rekomendasi Terbaik',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (snapshot.connectionState == ConnectionState.waiting)
              buildRecommendationLoading()
            else if (kosts.isEmpty)
              buildEmptyRecommendationCard()
            else
              SizedBox(
                height: 340,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: kosts.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(width: 16);
                  },
                  itemBuilder: (context, index) {
                    return buildRecommendationCard(kosts[index]);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget buildRecommendationCard(KostModel kost) {
    return GestureDetector(
      onTap: () {
        openDetailKost(kost.id);
      },
      child: Container(
        width: 238,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x17000000),
              blurRadius: 14,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildKostImage(
                imageUrl: kost.imageUrl,
                width: double.infinity,
                height: 150,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 14, 15, 0),
                child: Text(
                  kost.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: locationBlue,
                      size: 27,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        kost.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF303030),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.favorite_border_rounded,
                      color: Color(0xFF707070),
                      size: 39,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 8, 15, 0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: starColor,
                      size: 31,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      formatRating(kost.rating),
                      style: const TextStyle(
                        color: Color(0xFF303030),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 13, 15),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: formatRupiah(kost.price),
                          style: const TextStyle(
                            color: Color(0xFF2D3438),
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const TextSpan(
                          text: ' /Perbulan',
                          style: TextStyle(
                            color: Color(0xFFB0B0B0),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRecommendationLoading() {
    return Container(
      width: 238,
      height: 340,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: darkTeal,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget buildEmptyRecommendationCard() {
    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          'Data kost belum tersedia',
          style: TextStyle(
            color: Colors.black,
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
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
          size: 42,
        ),
      ),
    );
  }

  void openCariKost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CariKostScreen(),
      ),
    );
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

  Widget buildBottomNavigationBar() {
    return Container(
      height: 82,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildNavItem(
              index: 0,
              icon: Icons.home_rounded,
            ),
            buildNavItem(
              index: 1,
              icon: Icons.search_rounded,
            ),
            buildNavItem(
              index: 2,
              icon: Icons.history_rounded,
            ),
            buildNavItem(
              index: 3,
              icon: Icons.person_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNavItem({
    required int index,
    required IconData icon,
  }) {
    final bool isActive = selectedNavIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (index == selectedNavIndex) {
          return;
        }

        if (index == 1) {
          openCariKost();
          return;
        }

        if (index == 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Halaman riwayat belum dibuat'),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }

        if (index == 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Halaman profil belum dibuat'),
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }
      },
      child: SizedBox(
        width: 64,
        height: 64,
        child: Center(
          child: Icon(
            icon,
            size: 38,
            color: isActive ? darkTeal : Colors.grey.shade300,
          ),
        ),
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

  static String formatRating(double value) {
    return '${value.toStringAsFixed(1).replaceAll('.', ',')}/5';
  }
}