import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedNavIndex = 0;

  static const Color darkTeal = Color(0xFF07364A);
  static const Color tealStart = Color(0xFF0E7E72);
  static const Color tealEnd = Color(0xFF61E6D4);
  static const Color softBlue = Color(0xFFD8ECFF);

  final TextEditingController searchController = TextEditingController();

  final List<CategoryModel> categories = [
    CategoryModel(title: 'Termurah', icon: Icons.savings_outlined),
    CategoryModel(title: 'Tahunan', icon: Icons.receipt_long_outlined),
    CategoryModel(title: 'Bulanan', icon: Icons.calendar_month_rounded),
    CategoryModel(title: 'Terbersih', icon: Icons.clean_hands_outlined),
  ];

  final List<KostModel> recommendations = [
    KostModel(
      name: 'Kost Hijau Bu Rini',
      location: 'Lenteng Agung',
      rating: '4,5/5',
      price: 'Rp 1.000.000',
      imageUrl:
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
    ),
    KostModel(
      name: 'Kost Ceria Pagi',
      location: 'Jagakarsa',
      rating: '4,9/5',
      price: 'Rp 1.000.000',
      imageUrl:
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tealStart,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [tealStart, tealEnd],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 24, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeader(),
                const SizedBox(height: 28),
                buildSearchBar(),
                const SizedBox(height: 28),
                buildCategoryMenu(),
                const SizedBox(height: 30),
                buildSectionTitle('Riwayat Pemesanan'),
                const SizedBox(height: 14),
                buildHistoryCard(),
                const SizedBox(height: 32),
                buildSectionTitle('Rekomendasi Terbaik'),
                const SizedBox(height: 16),
                buildRecommendationList(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFD1E9B7),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.person, color: darkTeal, size: 40),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isSmallTextArea = constraints.maxWidth < 180;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, Akbar Ramadhan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: isSmallTextArea ? 17 : 19,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Mau Cari Kost-kostan?',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallTextArea ? 16 : 18,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.favorite_border_rounded, color: darkTeal, size: 29),
          const SizedBox(width: 10),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: darkTeal,
                size: 32,
              ),
              Positioned(
                right: 1,
                top: -1,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: darkTeal,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(34),
          border: Border.all(color: const Color(0xFFDADADA), width: 1.3),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: const InputDecorationTheme(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                ),
                child: TextField(
                  controller: searchController,
                  cursorColor: darkTeal,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari kost anda',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double gap = 13;
          final double availableWidth = constraints.maxWidth - (gap * 3);
          final double itemWidth = availableWidth / 4;
          final double boxSize = itemWidth.clamp(60.0, 74.0);

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: categories.map((item) {
              return SizedBox(
                width: itemWidth,
                child: Column(
                  children: [
                    Container(
                      width: boxSize,
                      height: boxSize,
                      decoration: BoxDecoration(
                        color: softBlue,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(
                        item.icon,
                        color: darkTeal,
                        size: boxSize * 0.46,
                      ),
                    ),
                    const SizedBox(height: 11),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget buildHistoryCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.4),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
                width: 108,
                height: 108,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kost Putra Agan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Spacer(),
                  HistoryInfoRow(
                    icon: Icons.calendar_month_rounded,
                    text: '1 Januari 2023 - 1 Januari 2026',
                  ),
                  SizedBox(height: 12),
                  HistoryInfoRow(
                    icon: Icons.location_on_outlined,
                    text: 'Jagakarsa, Jakarta Selatan',
                  ),
                  Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRecommendationList() {
    return SizedBox(
      height: 350,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: recommendations.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 16);
        },
        itemBuilder: (context, index) {
          return buildRecommendationCard(recommendations[index]);
        },
      ),
    );
  }

  Widget buildRecommendationCard(KostModel item) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              item.imageUrl,
              width: double.infinity,
              height: 165,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF6AB8FF),
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF303030),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.favorite_border_rounded,
                    color: Color(0xFF666666),
                    size: 34,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 8, 14, 0),
              child: Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFB000),
                    size: 32,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.rating,
                    style: const TextStyle(
                      color: Color(0xFF303030),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: item.price,
                      style: const TextStyle(
                        color: Color(0xFF2D3438),
                        fontSize: 20,
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
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBottomNavigationBar() {
    return Container(
      height: 82,
      decoration: const BoxDecoration(color: Colors.white),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildNavItem(index: 0, icon: Icons.home_rounded),
            buildNavItem(index: 1, icon: Icons.chat_bubble_rounded),
            buildNavItem(index: 2, icon: Icons.history_rounded),
            buildNavItem(index: 3, icon: Icons.person_rounded),
          ],
        ),
      ),
    );
  }

  Widget buildNavItem({required int index, required IconData icon}) {
    final bool isActive = selectedNavIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedNavIndex = index;
        });
      },
      child: Icon(
        icon,
        size: 36,
        color: isActive ? darkTeal : Colors.grey.shade300,
      ),
    );
  }
}

class HistoryInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const HistoryInfoRow({super.key, required this.icon, required this.text});

  static const Color blueIcon = Color(0xFF168BFF);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: blueIcon, size: 23),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class CategoryModel {
  final String title;
  final IconData icon;

  const CategoryModel({required this.title, required this.icon});
}

class KostModel {
  final String name;
  final String location;
  final String rating;
  final String price;
  final String imageUrl;

  const KostModel({
    required this.name,
    required this.location,
    required this.rating,
    required this.price,
    required this.imageUrl,
  });
}
