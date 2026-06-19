import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/kost.dart';
import '../../../services/kost_service.dart';
import 'kost_detail.dart';

class CariKostScreen extends StatefulWidget {
  const CariKostScreen({super.key});

  @override
  State<CariKostScreen> createState() => _CariKostScreenState();
}

class _CariKostScreenState extends State<CariKostScreen> {
  final KostService kostService = KostService();
  final TextEditingController searchController = TextEditingController();

  late Future<List<KostModel>> kostFuture;

  int selectedFilterIndex = 0;
  int selectedNavIndex = 1;

  static const Color darkTeal = ThemeApp.buttonColor;
  static const Color softGrey = Color(0xFF777777);
  static const Color starColor = Color(0xFFFFB000);
  static const Color locationBlue = Color(0xFF6AB8FF);

  final List<String> filters = const [
    'Rekomendasi',
    'Termurah',
    'Termahal',
  ];

  @override
  void initState() {
    super.initState();

    kostFuture = fetchKosts();

    searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<List<KostModel>> fetchKosts() async {
    try {
      return await kostService.fetchKostsWithImages();
    } catch (error) {
      debugPrint('Fetch cari kost error: $error');
      return [];
    }
  }

  Future<void> refreshData() async {
    setState(() {
      kostFuture = fetchKosts();
    });

    await kostFuture;
  }

  List<KostModel> getFilteredKosts(List<KostModel> kosts) {
    final keyword = searchController.text.trim().toLowerCase();

    List<KostModel> result = kosts.where((kost) {
      final name = kost.name.toLowerCase();
      final location = kost.location.toLowerCase();

      return name.contains(keyword) || location.contains(keyword);
    }).toList();

    if (selectedFilterIndex == 0) {
      result.sort((a, b) {
        return b.rating.compareTo(a.rating);
      });
    }

    if (selectedFilterIndex == 1) {
      result.sort((a, b) {
        return a.price.compareTo(b.price);
      });
    }

    if (selectedFilterIndex == 2) {
      result.sort((a, b) {
        return b.price.compareTo(a.price);
      });
    }

    return result;
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
            child: FutureBuilder<List<KostModel>>(
              future: kostFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: darkTeal,
                    ),
                  );
                }

                final kosts = getFilteredKosts(snapshot.data ?? []);

                return RefreshIndicator(
                  color: darkTeal,
                  onRefresh: refreshData,
                  child: Column(
                    children: [
                      buildTopBar(),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildSearchBar(),
                              const SizedBox(height: 22),
                              buildFilterButtons(),
                              const SizedBox(height: 20),
                              buildKostList(kosts),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: buildBottomNavigationBar(),
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
              onTap: () {
                Navigator.pop(context);
              },
              child: const SizedBox(
                width: 46,
                height: 46,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF303030),
                  size: 32,
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Cari kost',
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

  Widget buildSearchBar() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: const Color(0xFFDADADA),
          width: 1.3,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: Colors.grey.shade500,
            size: 32,
          ),
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
                    color: Colors.grey.shade500,
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
    );
  }

  Widget buildFilterButtons() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 10);
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
              padding: const EdgeInsets.symmetric(horizontal: 22),
              decoration: BoxDecoration(
                color: isSelected ? darkTeal : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected ? darkTeal : const Color(0xFFDADADA),
                  width: 1.4,
                ),
              ),
              child: Center(
                child: Text(
                  filters[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : softGrey,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildKostList(List<KostModel> kosts) {
    if (kosts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text(
          'Data kost belum tersedia',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return Column(
      children: kosts.map((kost) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: buildKostCard(kost),
        );
      }).toList(),
    );
  }

  Widget buildKostCard(KostModel kost) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailKostScreen(
              kostId: kost.id,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 168,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: buildKostImage(
                imageUrl: kost.imageUrl,
                width: 116,
                height: 148,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kost.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: locationBlue,
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            kost.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF303030),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: starColor,
                          size: 27,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            '${formatRating(kost.rating)} (reviewers)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF555555),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.meeting_room_outlined,
                          color: darkTeal,
                          size: 19,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${kost.available} kamar tersedia',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF555555),
                              fontSize: 13.2,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: formatRupiah(kost.price),
                              style: const TextStyle(
                                color: Color(0xFF2D3438),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const TextSpan(
                              text: ' /Perbulan',
                              style: TextStyle(
                                color: Color(0xFFB0B0B0),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
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

        if (index == 0) {
          Navigator.pop(context);
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Halaman ini belum dibuat'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: SizedBox(
        width: 64,
        height: 64,
        child: Center(
          child: Icon(
            icon,
            size: 36,
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