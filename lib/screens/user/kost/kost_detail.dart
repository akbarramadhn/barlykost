import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/facility.dart';
import '../../../models/kost.dart';
import '../../../services/kost_service.dart';
import '../../../services/wishlist_service.dart';
import '../../../widgets/bottomnav.dart';
import '../../../widgets/emptystate.dart';
import '../booking/booking_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';
import 'daftarkost.dart';

class DetailKostScreen extends StatefulWidget {
  final String kostId;

  const DetailKostScreen({super.key, required this.kostId});

  @override
  State<DetailKostScreen> createState() => _DetailKostScreenState();
}

class _DetailKostScreenState extends State<DetailKostScreen> {
  final KostService kostService = KostService();
  final WishlistService wishlistService = WishlistService();

  late Future<_KostDetailData> detailFuture;

  int currentImageIndex = 0;
  int selectedNavIndex = 0;

  bool isWishlisted = false;
  bool isWishlistLoading = false;

  @override
  void initState() {
    super.initState();
    detailFuture = fetchDetailData();
    loadWishlistStatus();
  }

  Future<_KostDetailData> fetchDetailData() async {
    try {
      final kost = await kostService.fetchKostById(widget.kostId);
      final images = await kostService.fetchKostImages(widget.kostId);
      final facilities = await kostService.fetchFacilitiesByKostId(
        widget.kostId,
      );

      return _KostDetailData(
        kost: kost,
        images: images,
        facilities: facilities,
      );
    } catch (error) {
      debugPrint('Fetch detail kost error: $error');
      return _KostDetailData.empty();
    }
  }

  Future<void> loadWishlistStatus() async {
    try {
      final result = await wishlistService.isWishlisted(widget.kostId);

      if (!mounted) {
        return;
      }

      setState(() {
        isWishlisted = result;
      });
    } catch (error) {
      debugPrint('Load wishlist status error: $error');
    }
  }

  Future<void> toggleWishlist() async {
    if (isWishlistLoading) {
      return;
    }

    setState(() {
      isWishlistLoading = true;
    });

    try {
      final success = await wishlistService.toggleWishlist(widget.kostId);

      if (!mounted) {
        return;
      }

      if (!success) {
        setState(() {
          isWishlistLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memperbarui wishlist'),
            duration: Duration(seconds: 1),
          ),
        );

        return;
      }

      final newStatus = await wishlistService.isWishlisted(widget.kostId);

      if (!mounted) {
        return;
      }

      setState(() {
        isWishlisted = newStatus;
        isWishlistLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus
                ? 'Kost berhasil ditambahkan ke wishlist'
                : 'Kost dihapus dari wishlist',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isWishlistLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui wishlist'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> refreshData() async {
    final newFuture = fetchDetailData();

    setState(() {
      currentImageIndex = 0;
      detailFuture = newFuture;
    });

    await Future.wait([newFuture, loadWishlistStatus()]);
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1)),
      child: Scaffold(
        backgroundColor: ThemeApp.primaryDark,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: ThemeApp.backgroundGradient,
          child: FutureBuilder<_KostDetailData>(
            future: detailFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: ThemeApp.buttonColor),
                );
              }

              final data = snapshot.data ?? _KostDetailData.empty();

              if (data.kost.id.trim().isEmpty) {
                return RefreshIndicator(
                  color: ThemeApp.buttonColor,
                  onRefresh: refreshData,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
                    children: const [
                      SizedBox(
                        height: 360,
                        child: EmptyState(
                          icon: Icons.home_work_outlined,
                          title: 'Detail kost tidak ditemukan',
                          message:
                              'Data kost belum tersedia atau gagal dimuat. Coba refresh halaman ini.',
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: ThemeApp.buttonColor,
                onRefresh: refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildImageHeader(data.images),
                      buildContent(data),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: selectedNavIndex,
          onTap: handleBottomNavTap,
        ),
      ),
    );
  }

  Widget buildImageHeader(List<String> images) {
    return SizedBox(
      height: 365,
      child: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              itemCount: images.isEmpty ? 1 : images.length,
              onPageChanged: (index) {
                setState(() {
                  currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                if (images.isEmpty) {
                  return buildImagePlaceholder();
                }

                return Image.network(
                  images[index],
                  width: double.infinity,
                  height: 365,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return buildImagePlaceholder();
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return Container(
                      width: double.infinity,
                      height: 365,
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
              },
            ),
          ),
          Positioned(
            top: 44,
            left: 24,
            child: buildCircleButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: 18,
              left: 0,
              right: 0,
              child: buildImageIndicator(images.length),
            ),
        ],
      ),
    );
  }

  Widget buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 365,
      color: ThemeApp.softBackground,
      child: const Center(
        child: Icon(
          Icons.home_work_outlined,
          color: ThemeApp.buttonColor,
          size: 80,
        ),
      ),
    );
  }

  Widget buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: ThemeApp.white.withValues(alpha: 0.94),
          shape: BoxShape.circle,
          boxShadow: [
            ThemeApp.softShadow(
              alpha: 0.10,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: ThemeApp.buttonColor, size: 22),
      ),
    );
  }

  Widget buildImageIndicator(int length) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isActive = currentImageIndex == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 14 : 12,
          height: isActive ? 14 : 12,
          decoration: BoxDecoration(
            color: isActive ? ThemeApp.buttonColor : ThemeApp.white,
            shape: BoxShape.circle,
            border: Border.all(color: ThemeApp.white, width: 1),
          ),
        );
      }),
    );
  }

  Widget buildContent(_KostDetailData data) {
    final kost = data.kost;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [ThemeApp.primaryDark, ThemeApp.primaryLight],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTitleAndPrice(kost),
          const SizedBox(height: 34),
          buildSectionHeader(title: 'Fasilitas'),
          const SizedBox(height: 16),
          buildFacilities(data.facilities),
          const SizedBox(height: 32),
          buildSectionHeader(title: 'Kebijakan Properti'),
          const SizedBox(height: 14),
          buildPolicyText(),
          const SizedBox(height: 30),
          buildSectionHeader(title: 'Deskripsi Properti'),
          const SizedBox(height: 14),
          buildDescriptionText(kost),
          const SizedBox(height: 30),
          buildDetailLocation(kost),
          const SizedBox(height: 30),
          buildSectionHeader(title: 'Informasi Jarak'),
          const SizedBox(height: 16),
          buildDistanceInformation(),
          const SizedBox(height: 36),
          buildBookingButton(kost, data.images),
        ],
      ),
    );
  }

  Widget buildTitleAndPrice(KostModel kost) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kost.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ThemeApp.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 18),
              buildInfoRow(
                icon: Icons.location_on_outlined,
                iconColor: ThemeApp.locationBlue,
                text: kost.location,
                textColor: ThemeApp.black,
              ),
              const SizedBox(height: 10),
              buildInfoRow(
                icon: Icons.star_rounded,
                iconColor: ThemeApp.starColor,
                text: '${formatRating(kost.rating)} (100 reviewers)',
                textColor: ThemeApp.white,
              ),
              const SizedBox(height: 10),
              buildInfoRow(
                icon: Icons.check_circle_rounded,
                iconColor: ThemeApp.successGreen,
                text: '${kost.available} Tersedia',
                textColor: ThemeApp.black,
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        SizedBox(
          width: 112,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 56),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  formatRupiah(kost.price),
                  maxLines: 1,
                  style: const TextStyle(
                    color: ThemeApp.priceDark,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Text(
                '/Perbulan',
                style: TextStyle(
                  color: ThemeApp.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              buildWishlistButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildWishlistButton() {
    return GestureDetector(
      onTap: toggleWishlist,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: isWishlistLoading
            ? const SizedBox(
                key: ValueKey('wishlist_loading'),
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: ThemeApp.buttonColor,
                  strokeWidth: 2,
                ),
              )
            : Icon(
                isWishlisted
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey(isWishlisted),
                color: isWishlisted ? Colors.redAccent : ThemeApp.textGrey,
                size: 38,
              ),
      ),
    );
  }

  Widget buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String text,
    required Color textColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 23),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSectionHeader({required String title}) {
    return Text(
      title,
      style: const TextStyle(
        color: ThemeApp.black,
        fontSize: 21,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget buildFacilities(List<FacilityModel> facilities) {
    final shownFacilities = facilities.take(4).toList();

    if (shownFacilities.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: ThemeApp.white.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text(
          'Fasilitas belum tersedia',
          style: TextStyle(
            color: ThemeApp.black,
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const double gap = 10;
        final double itemWidth = (constraints.maxWidth - (gap * 3)) / 4;
        final double boxSize = itemWidth.clamp(62.0, 76.0).toDouble();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: shownFacilities.map((facility) {
            return SizedBox(
              width: itemWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: boxSize,
                    height: boxSize,
                    decoration: BoxDecoration(
                      color: ThemeApp.softBlue,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      facility.icon,
                      color: ThemeApp.buttonColor,
                      size: boxSize * 0.42,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: Center(
                      child: Text(
                        facility.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: ThemeApp.black,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          height: 1.08,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget buildPolicyText() {
    return const Text(
      '1. Seluruh fasilitas kost hanya diperuntukkan bagi penyewa kost/penyewa kamar, bukan untuk umum.\n'
      '2. Penyewa kost dilarang menerima tamu atau membawa teman ke kamar kost. Tamu sebaiknya diterima di area terbuka atau tempat umum.\n'
      '3. Penyewa kost tidak diperkenankan merokok di dalam kamar maupun di lingkungan rumah kost.',
      textAlign: TextAlign.justify,
      style: TextStyle(
        color: ThemeApp.black,
        fontSize: 15.5,
        fontWeight: FontWeight.w500,
        height: 1.32,
      ),
    );
  }

  Widget buildDescriptionText(KostModel kost) {
    final description = kost.description.trim().isEmpty
        ? 'Kost nyaman dengan lingkungan aman, lokasi strategis, dan fasilitas yang mendukung kebutuhan penyewa.'
        : kost.description;

    return Text(
      description,
      textAlign: TextAlign.justify,
      style: const TextStyle(
        color: ThemeApp.black,
        fontSize: 15.5,
        fontWeight: FontWeight.w500,
        height: 1.32,
      ),
    );
  }

  Widget buildDetailLocation(KostModel kost) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSectionHeader(title: 'Detail Lokasi'),
        const SizedBox(height: 14),
        Text(
          'Area ${kost.location}, Jakarta Selatan',
          textAlign: TextAlign.justify,
          style: const TextStyle(
            color: ThemeApp.black,
            fontSize: 15.5,
            fontWeight: FontWeight.w500,
            height: 1.32,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          height: 126,
          decoration: BoxDecoration(
            color: ThemeApp.white.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: MapPlaceholderPainter()),
              ),
              const Center(
                child: Icon(
                  Icons.location_on_rounded,
                  color: ThemeApp.buttonColor,
                  size: 42,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildDistanceInformation() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DistanceInfoRow(
          icon: Icons.train_rounded,
          title: 'Stasiun Kereta',
          subtitle:
              'Stasiun Univ Pancasila : 2,3km\nStasiun Lenteng Agung : 4,2km',
        ),
        SizedBox(height: 16),
        DistanceInfoRow(
          icon: Icons.flight_rounded,
          title: 'Bandara',
          subtitle: 'Bandara Halim Perdana Kusuma : 10,3km',
        ),
      ],
    );
  }

  Widget buildBookingButton(KostModel kost, List<String> images) {
    final isAvailable = kost.available > 0;

    return SizedBox(
      width: double.infinity,
      height: 62,
      child: ElevatedButton(
        onPressed: isAvailable
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return BookingScreen(kost: kost, images: images);
                    },
                  ),
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeApp.buttonColor,
          foregroundColor: ThemeApp.white,
          disabledBackgroundColor: ThemeApp.textGrey,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(34),
          ),
        ),
        child: Text(
          isAvailable ? 'Pesan Kost' : 'Kamar Penuh',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  void handleBottomNavTap(int index) {
    if (index == selectedNavIndex) {
      Navigator.popUntil(context, (route) => route.isFirst);
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
    }
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

class _KostDetailData {
  final KostModel kost;
  final List<String> images;
  final List<FacilityModel> facilities;

  const _KostDetailData({
    required this.kost,
    required this.images,
    required this.facilities,
  });

  factory _KostDetailData.empty() {
    return _KostDetailData(
      kost: KostModel.empty(),
      images: const [],
      facilities: FacilityModel.defaultFacilities(),
    );
  }
}

class DistanceInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const DistanceInfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: ThemeApp.black, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: ThemeApp.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: ThemeApp.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MapPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFE1E5E8)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final smallRoadPaint = Paint()
      ..color = const Color(0xFFD4D9DD)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height * 0.25),
      Offset(size.width, size.height * 0.1),
      roadPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.1, size.height),
      Offset(size.width * 0.85, 0),
      roadPaint,
    );

    canvas.drawLine(
      Offset(0, size.height * 0.75),
      Offset(size.width, size.height * 0.65),
      smallRoadPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.25, 0),
      Offset(size.width * 0.55, size.height),
      smallRoadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
