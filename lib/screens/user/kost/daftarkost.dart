import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/penyewa/kost.dart';
import '../../../services/penyewa/kost_service.dart';
import '../../../widgets/bottomnav.dart';
import '../../../widgets/emptystate.dart';
import '../../../widgets/kostcard.dart';
import '../../../widgets/searchbar.dart';
import '../../user/history/history_screen.dart';
import '../../user/profile/profile_screen.dart';
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

  final List<String> filters = const ['Rekomendasi', 'Termurah', 'Termahal'];

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
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1.0)),
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
                    child: CircularProgressIndicator(color: darkTeal),
                  );
                }

                final allKosts = snapshot.data ?? [];
                final filteredKosts = getFilteredKosts(allKosts);

                return RefreshIndicator(
                  color: darkTeal,
                  onRefresh: refreshData,
                  child: Column(
                    children: [
                      buildTopBar(),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildSearchBar(),
                              const SizedBox(height: 22),
                              buildFilterButtons(),
                              const SizedBox(height: 20),
                              buildKostList(filteredKosts),
                              const SizedBox(height: 90),
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
    return SearchBarWidget(
      controller: searchController,
      hintText: 'Cari kost anda',
      showFilter: false,
      showClear: searchController.text.trim().isNotEmpty,
      onClearTap: () {
        searchController.clear();
        FocusScope.of(context).unfocus();
      },
      margin: EdgeInsets.zero,
    );
  }

  Widget buildFilterButtons() {
    return SizedBox(
      height: 54,
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
                color: isSelected ? darkTeal : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isSelected ? darkTeal : const Color(0xFFDADADA),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  filters[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : softGrey,
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

  Widget buildKostList(List<KostModel> kosts) {
    if (kosts.isEmpty) {
      return Container(
        width: double.infinity,
        height: 240,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: EmptyState(
          icon: Icons.search_off_rounded,
          title: searchController.text.trim().isEmpty
              ? 'Data kost belum tersedia'
              : 'Kost tidak ditemukan',
          message: searchController.text.trim().isEmpty
              ? 'Nanti daftar kost akan muncul di halaman ini.'
              : 'Coba gunakan kata kunci lain atau hapus pencarian.',
        ),
      );
    }

    return Column(
      children: kosts.map((kost) {
        return KostCard(
          namaKost: kost.name,
          lokasi: kost.location,
          harga: kost.price,
          rating: kost.rating,
          imageUrl: kost.imageUrl,
          tersedia: kost.available > 0,
          availableText: '${kost.available} kamar tersedia',
          isHorizontal: true,
          showStatusBadge: false,
          margin: const EdgeInsets.only(bottom: 16),
          onTap: () {
            openDetailKost(kost.id);
          },
        );
      }).toList(),
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

  void handleBottomNavTap(int index) {
    if (index == selectedNavIndex) {
      return;
    }

    if (index == 0) {
      Navigator.pop(context);
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
