import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/kost.dart';
import '../../../services/wishlist_service.dart';
import '../../../widgets/bottomnav.dart';
import '../../../widgets/emptystate.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';
import '../kost/daftarkost.dart';
import '../kost/kost_detail.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistService wishlistService = WishlistService();

  late Future<List<KostModel>> wishlistFuture;

  int selectedFilterIndex = 0;
  int selectedNavIndex = 0;

  final List<String> filters = const [
    'Termurah',
    'Termahal',
    'Terbersih',
    'Rating Tertinggi',
  ];

  @override
  void initState() {
    super.initState();
    wishlistFuture = fetchWishlist();
  }

  Future<List<KostModel>> fetchWishlist() async {
    return await wishlistService.fetchWishlistKosts();
  }

  Future<void> refreshData() async {
    setState(() {
      wishlistFuture = fetchWishlist();
    });

    await wishlistFuture;
  }

  List<KostModel> getFilteredWishlist(List<KostModel> kosts) {
    final result = List<KostModel>.from(kosts);

    if (selectedFilterIndex == 0) {
      result.sort((a, b) {
        return a.price.compareTo(b.price);
      });
    }

    if (selectedFilterIndex == 1) {
      result.sort((a, b) {
        return b.price.compareTo(a.price);
      });
    }

    if (selectedFilterIndex == 2) {
      result.sort((a, b) {
        return b.rating.compareTo(a.rating);
      });
    }

    if (selectedFilterIndex == 3) {
      result.sort((a, b) {
        return b.rating.compareTo(a.rating);
      });
    }

    return result;
  }

  Future<void> removeWishlist(KostModel kost) async {
    final success = await wishlistService.removeWishlist(kost.id);

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${kost.name} dihapus dari wishlist'),
          duration: const Duration(seconds: 1),
        ),
      );

      await refreshData();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gagal menghapus wishlist'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Scaffold(
        backgroundColor: ThemeApp.primaryDark,
        body: Column(
          children: [
            buildHeader(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: ThemeApp.backgroundGradient,
                child: FutureBuilder<List<KostModel>>(
                  future: wishlistFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: ThemeApp.buttonColor,
                        ),
                      );
                    }

                    final wishlistKosts = getFilteredWishlist(
                      snapshot.data ?? [],
                    );

                    if (wishlistKosts.isEmpty) {
                      return buildEmptyWishlist();
                    }

                    return buildWishlistContent(wishlistKosts);
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
                'Wishlist',
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
          const SizedBox(width: 42, height: 42),
        ],
      ),
    );
  }

  Widget buildWishlistContent(List<KostModel> kosts) {
    return RefreshIndicator(
      color: ThemeApp.buttonColor,
      onRefresh: refreshData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 118),
        children: [
          buildFilterChips(),
          const SizedBox(height: 20),
          ...kosts.map((kost) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: buildWishlistCard(kost),
            );
          }),
        ],
      ),
    );
  }

  Widget buildFilterChips() {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 12);
        },
        itemBuilder: (context, index) {
          final isSelected = selectedFilterIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilterIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 26),
              decoration: BoxDecoration(
                color: isSelected ? ThemeApp.buttonColor : ThemeApp.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? ThemeApp.buttonColor : ThemeApp.lightGrey,
                  width: 1.4,
                ),
                boxShadow: [
                  ThemeApp.softShadow(
                    alpha: 0.05,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  filters[index],
                  maxLines: 1,
                  style: TextStyle(
                    color: isSelected ? ThemeApp.white : ThemeApp.textGrey,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildWishlistCard(KostModel kost) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: ThemeApp.white,
        borderRadius: BorderRadius.circular(22),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: buildKostImage(
              imageUrl: kost.imageUrl,
              width: double.infinity,
              height: 190,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            kost.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ThemeApp.textDark,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: formatRupiah(kost.price),
                        style: const TextStyle(
                          color: ThemeApp.priceDark,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const TextSpan(
                        text: '/Bulan',
                        style: TextStyle(
                          color: Color(0xFFB0B0B0),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  removeWishlist(kost);
                },
                child: const Icon(
                  Icons.favorite_border_rounded,
                  color: Colors.red,
                  size: 50,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: ThemeApp.locationBlue,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  kost.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ThemeApp.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: ThemeApp.starColor,
                size: 32,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: formatRating(kost.rating),
                        style: const TextStyle(
                          color: ThemeApp.textDark,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const TextSpan(
                        text: ' (100 reviewers)',
                        style: TextStyle(
                          color: Color(0xFFB0B0B0),
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  openDetailKost(kost.id);
                },
                child: const Text(
                  'Lihat Detail',
                  style: TextStyle(
                    color: ThemeApp.locationBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildEmptyWishlist() {
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
              icon: Icons.favorite_border_rounded,
              title: 'Wishlist masih kosong',
              message:
                  'Kost yang kamu sukai akan muncul di sini setelah kamu menambahkannya ke wishlist.',
            ),
          ),
        ],
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
          color: ThemeApp.softBackground,
          child: const Center(
            child: CircularProgressIndicator(
              color: ThemeApp.buttonColor,
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
      color: ThemeApp.softBackground,
      child: const Center(
        child: Icon(
          Icons.home_work_outlined,
          color: ThemeApp.buttonColor,
          size: 48,
        ),
      ),
    );
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

  String formatRating(double value) {
    return '${value.toStringAsFixed(1).replaceAll('.', ',')}/5';
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

  void handleBottomNavTap(int index) {
    if (index == selectedNavIndex) {
      return;
    }

    if (index == 0) {
      Navigator.popUntil(context, (route) => route.isFirst);
      return;
    }

    if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CariKostScreen()),
      );
      return;
    }

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HistoryScreen()),
      );
      return;
    }

    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
      return;
    }
  }
}
