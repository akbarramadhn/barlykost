import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/facility.dart';
import '../../../models/kost.dart';
import '../../../services/kost_service.dart';
import 'daftarkost.dart';

class DetailKostScreen extends StatefulWidget {
  final String kostId;

  const DetailKostScreen({
    super.key,
    required this.kostId,
  });

  @override
  State<DetailKostScreen> createState() => _DetailKostScreenState();
}

class _DetailKostScreenState extends State<DetailKostScreen> {
  final KostService kostService = KostService();

  late Future<_KostDetailData> detailFuture;

  int currentImageIndex = 0;
  int selectedNavIndex = 0;

  static const Color darkTeal = ThemeApp.buttonColor;
  static const Color softBlue = Color(0xFFD8ECFF);
  static const Color locationBlue = Color(0xFF6AB8FF);
  static const Color starColor = Color(0xFFFFB000);
  static const Color greenStatus = Color(0xFF0A9B25);

  @override
  void initState() {
    super.initState();
    detailFuture = fetchDetailData();
  }

  Future<_KostDetailData> fetchDetailData() async {
    try {
      final kost = await kostService.fetchKostById(widget.kostId);
      final images = await kostService.fetchKostImages(widget.kostId);
      final facilities = await kostService.fetchFacilitiesByKostId(widget.kostId);

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

  Future<void> refreshData() async {
    setState(() {
      detailFuture = fetchDetailData();
    });

    await detailFuture;
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
          child: FutureBuilder<_KostDetailData>(
            future: detailFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: darkTeal,
                  ),
                );
              }

              final data = snapshot.data ?? _KostDetailData.empty();

              return RefreshIndicator(
                color: darkTeal,
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
        bottomNavigationBar: buildBottomNavigationBar(),
      ),
    );
  }

  Widget buildImageHeader(List<String> images) {
    return SizedBox(
      height: 365,
      child: Stack(
        children: [
          PageView.builder(
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
            },
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
          Positioned(
            top: 44,
            right: 24,
            child: buildCircleButton(
              icon: Icons.share_rounded,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur share belum dibuat'),
                    duration: Duration(seconds: 1),
                  ),
                );
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
      color: const Color(0xFFEAF6F4),
      child: const Center(
        child: Icon(
          Icons.home_work_outlined,
          color: darkTeal,
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
        width: 54,
        height: 54,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: darkTeal,
          size: 28,
        ),
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
            color: isActive ? darkTeal : Colors.white,
            shape: BoxShape.circle,
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
          colors: [
            ThemeApp.primaryDark,
            ThemeApp.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTitleAndPrice(kost),
          const SizedBox(height: 34),
          buildSectionHeader(
            title: 'Fasilitas',
            actionText: 'Lihat semua',
          ),
          const SizedBox(height: 16),
          buildFacilities(data.facilities),
          const SizedBox(height: 32),
          buildSectionHeader(
            title: 'Kebijakan Properti',
          ),
          const SizedBox(height: 14),
          buildPolicyText(),
          const SizedBox(height: 30),
          buildSectionHeader(
            title: 'Deskripsi Properti',
          ),
          const SizedBox(height: 14),
          buildDescriptionText(kost),
          const SizedBox(height: 30),
          buildDetailLocation(kost),
          const SizedBox(height: 30),
          buildSectionHeader(
            title: 'Informasi Jarak',
            actionText: 'Lihat semua',
          ),
          const SizedBox(height: 16),
          buildDistanceInformation(),
          const SizedBox(height: 36),
          buildBookingButton(kost),
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
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 18),
              buildInfoRow(
                icon: Icons.location_on_outlined,
                iconColor: locationBlue,
                text: kost.location,
                textColor: Colors.black,
              ),
              const SizedBox(height: 10),
              buildInfoRow(
                icon: Icons.star_rounded,
                iconColor: starColor,
                text: '${formatRating(kost.rating)} (100 reviewers)',
                textColor: Colors.white,
              ),
              const SizedBox(height: 10),
              buildInfoRow(
                icon: Icons.check_circle_rounded,
                iconColor: greenStatus,
                text: '${kost.available} Tersedia',
                textColor: Colors.black,
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 56),
            Text(
              formatRupiah(kost.price),
              style: const TextStyle(
                color: Color(0xFF263238),
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Text(
              '/Perbulan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            const Icon(
              Icons.favorite_border_rounded,
              color: Color(0xFF777777),
              size: 36,
            ),
          ],
        ),
      ],
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
        Icon(
          icon,
          color: iconColor,
          size: 23,
        ),
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

  Widget buildSectionHeader({
    required String title,
    String? actionText,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur lihat semua belum dibuat'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Text(
              actionText,
              style: const TextStyle(
                color: locationBlue,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget buildFacilities(List<FacilityModel> facilities) {
    final shownFacilities = facilities.take(4).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        const double gap = 12;
        final double itemWidth = (constraints.maxWidth - (gap * 3)) / 4;
        final double boxSize = itemWidth.clamp(66.0, 78.0).toDouble();

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
                      color: softBlue,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      facility.icon,
                      color: darkTeal,
                      size: boxSize * 0.43,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 34,
                    child: Center(
                      child: Text(
                        facility.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.05,
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
      '1. Seluruh fasilitas kost hanya diperuntukkan bagi penyewa kost/penyewa kamar, bukan untuk umum\n'
      '2. Penyewa kost dilarang menerima tamu dan/atau membawa teman ke kamar kost. Sebaiknya menerima tamu atau teman adalah di tempat terbuka atau tempat umum lainnya.\n'
      '3. Penyewa kost tidak diperkenankan merokok di dalam kamar maupun di lingkungan rumah kost.',
      textAlign: TextAlign.justify,
      style: TextStyle(
        color: Colors.black,
        fontSize: 15.5,
        fontWeight: FontWeight.w500,
        height: 1.28,
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
        color: Colors.black,
        fontSize: 15.5,
        fontWeight: FontWeight.w500,
        height: 1.28,
      ),
    );
  }

  Widget buildDetailLocation(KostModel kost) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detail Lokasi',
          style: TextStyle(
            color: Colors.black,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Area ${kost.location}, Jakarta Selatan',
          textAlign: TextAlign.justify,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15.5,
            fontWeight: FontWeight.w500,
            height: 1.28,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          height: 126,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: MapPlaceholderPainter(),
                ),
              ),
              const Center(
                child: Icon(
                  Icons.location_on_rounded,
                  color: darkTeal,
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
          subtitle: 'Bandara Halim Perdana Kusuma: 10,3km',
        ),
      ],
    );
  }

  Widget buildBookingButton(KostModel kost) {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Booking ${kost.name} belum dibuat'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: darkTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(34),
          ),
        ),
        child: const Text(
          'Pesan Kost',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
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

  static const Color darkTeal = ThemeApp.buttonColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.black,
          size: 28,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white,
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