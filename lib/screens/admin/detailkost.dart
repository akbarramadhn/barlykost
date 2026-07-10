import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/admin/kost.dart';
import '../../services/admin/kost_service.dart';
import '../../widgets/adminbottomnav.dart';
import 'dashboard_screen.dart';

class AdminKostDetailScreen extends StatefulWidget {
  final String kostId;

  const AdminKostDetailScreen({super.key, required this.kostId});

  @override
  State<AdminKostDetailScreen> createState() => _AdminKostDetailScreenState();
}

class _AdminKostDetailScreenState extends State<AdminKostDetailScreen> {
  final KostService _kostService = KostService();
  final PageController _pageController = PageController();

  late Future<Kost> _kostFuture;

  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _kostFuture = _kostService.getKostById(widget.kostId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    final Future<Kost> newFuture = _kostService.getKostById(widget.kostId);

    setState(() {
      _kostFuture = newFuture;
      _currentImageIndex = 0;
    });

    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }

    await newFuture;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleBottomNavigation(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
      return;
    }

    if (index == 1) {
      Navigator.pop(context);
      return;
    }

    if (index == 2) {
      _showMessage('Halaman pemesanan belum dibuat');
      return;
    }

    if (index == 3) {
      _showMessage('Halaman profil admin belum dibuat');
    }
  }

  String _formatRupiah(int value) {
    final String number = value.toString();
    final StringBuffer result = StringBuffer();

    for (int index = 0; index < number.length; index++) {
      if (index > 0 && (number.length - index) % 3 == 0) {
        result.write('.');
      }

      result.write(number[index]);
    }

    return result.toString();
  }

  String _formatRating(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1).replaceAll('.', ',');
  }

  String _getShortLocation(String location) {
    final List<String> parts = location
        .split(',')
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return location;
    }

    return parts.first;
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 86,
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            borderRadius: ThemeApp.radius(30),
            child: const SizedBox(
              width: 50,
              height: 50,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 27,
                color: ThemeApp.adminTitle,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Detail Kost',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ThemeApp.adminTitle,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 50, height: 50),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: ThemeApp.softBackground,
      alignment: Alignment.center,
      child: const Icon(
        Icons.home_work_outlined,
        size: 64,
        color: ThemeApp.buttonColor,
      ),
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    return Image.network(
      imageUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder:
          (
            BuildContext context,
            Widget child,
            ImageChunkEvent? loadingProgress,
          ) {
            if (loadingProgress == null) {
              return child;
            }

            return Container(
              color: ThemeApp.softBackground,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(
                color: ThemeApp.primaryDark,
              ),
            );
          },
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
            return Container(
              color: ThemeApp.softBackground,
              alignment: Alignment.center,
              child: const Icon(
                Icons.broken_image_outlined,
                size: 58,
                color: ThemeApp.buttonColor,
              ),
            );
          },
    );
  }

  Widget _buildImageGallery(Kost kost) {
    final List<String> images = kost.imageUrls;

    return ClipRRect(
      borderRadius: ThemeApp.radius(21),
      child: SizedBox(
        height: 268,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (images.isEmpty)
              _buildImagePlaceholder()
            else
              PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                onPageChanged: (int index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  return _buildNetworkImage(images[index]);
                },
              ),
            Positioned(
              right: 17,
              bottom: 17,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: ThemeApp.black.withValues(alpha: 0.68),
                  borderRadius: ThemeApp.radius(16),
                ),
                child: Text(
                  images.isEmpty
                      ? '0 / 0'
                      : '${_currentImageIndex + 1} / ${images.length}',
                  style: const TextStyle(
                    color: ThemeApp.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformationLine({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 25),
        const SizedBox(width: 13),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: ThemeApp.textDark,
              fontSize: 16,
              height: 1.3,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainInformation(Kost kost) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          kost.namaKost,
          style: const TextStyle(
            color: ThemeApp.textDark,
            fontSize: 27,
            height: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 25),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _buildInformationLine(
                    icon: Icons.location_on_outlined,
                    iconColor: ThemeApp.locationBlue,
                    text: _getShortLocation(kost.lokasi),
                  ),
                  const SizedBox(height: 10),
                  _buildInformationLine(
                    icon: Icons.star_rounded,
                    iconColor: ThemeApp.starColor,
                    text: '${_formatRating(kost.rating)}/5',
                  ),
                  const SizedBox(height: 10),
                  _buildInformationLine(
                    icon: Icons.check_circle_rounded,
                    iconColor: kost.isAvailable
                        ? ThemeApp.successGreen
                        : ThemeApp.cancelledRed,
                    text: kost.isAvailable
                        ? '${kost.tersedia} Tersedia'
                        : 'Penuh',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topRight,
                  child: Text(
                    'Rp ${_formatRupiah(kost.harga)}',
                    style: const TextStyle(
                      color: ThemeApp.priceDark,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: ThemeApp.textDark,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildPolicyItem({required int number, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 29,
            child: Text(
              '$number.',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: ThemeApp.textDark,
                fontSize: 15,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                color: ThemeApp.textDark,
                fontSize: 15,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Kebijakan Properti'),
        const SizedBox(height: 18),
        _buildPolicyItem(
          number: 1,
          text:
              'Seluruh fasilitas kost hanya diperuntukkan bagi penyewa kost atau penyewa kamar, bukan untuk umum.',
        ),
        _buildPolicyItem(
          number: 2,
          text:
              'Penyewa kost dilarang menerima tamu dan/atau membawa teman ke kamar kost. Sebaiknya menerima tamu atau teman di tempat terbuka atau tempat umum lainnya, seperti warung atau café/resto.',
        ),
        _buildPolicyItem(
          number: 3,
          text:
              'Penyewa kost tidak diperkenankan merokok di dalam kamar maupun di lingkungan rumah kost.',
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(Kost kost) {
    final String description = kost.deskripsi?.trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Deskripsi Properti'),
        const SizedBox(height: 18),
        Text(
          description.isEmpty
              ? 'Deskripsi kost belum ditambahkan.'
              : description,
          textAlign: TextAlign.justify,
          style: TextStyle(
            color: description.isEmpty ? ThemeApp.textGrey : ThemeApp.textDark,
            fontSize: 15,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFacility({required IconData icon, required String label}) {
    return Expanded(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: ThemeApp.softBlue,
                borderRadius: ThemeApp.radius(24),
              ),
              child: Icon(icon, size: 38, color: ThemeApp.buttonColor),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ThemeApp.textDark,
              fontSize: 14,
              height: 1.25,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Fasilitas'),
        const SizedBox(height: 21),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFacility(icon: Icons.tv_rounded, label: 'TV'),
            const SizedBox(width: 18),
            _buildFacility(icon: Icons.inventory_2_outlined, label: 'Lemari'),
            const SizedBox(width: 18),
            _buildFacility(icon: Icons.bed_rounded, label: 'Tempat\nTidur'),
            const SizedBox(width: 18),
            _buildFacility(icon: Icons.ac_unit_rounded, label: 'AC'),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationSection(Kost kost) {
    return Column(
      children: [
        const Divider(color: ThemeApp.borderGrey, height: 1),
        const SizedBox(height: 23),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.navigation_rounded,
              size: 29,
              color: ThemeApp.buttonColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                kost.lokasi,
                style: const TextStyle(
                  color: ThemeApp.textDark,
                  fontSize: 15,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 14),
            OutlinedButton.icon(
              onPressed: () {
                _showMessage('Koordinat lokasi belum tersedia');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: ThemeApp.adminPurple,
                backgroundColor: ThemeApp.adminSoftPurple,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: ThemeApp.radius(20),
                ),
              ),
              icon: const Icon(Icons.map_outlined, size: 22),
              label: const Text(
                'Lihat di Peta',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        height: 59,
        child: ElevatedButton.icon(
          onPressed: () {
            _showMessage('Halaman edit kost akan dibuat berikutnya');
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 59),
            backgroundColor: ThemeApp.adminBlue,
            foregroundColor: ThemeApp.white,
            padding: const EdgeInsets.symmetric(horizontal: 26),
            shape: RoundedRectangleBorder(borderRadius: ThemeApp.radius(20)),
          ),
          icon: const Icon(Icons.edit_square, size: 24),
          label: const Text(
            'Edit Detail Kost',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailContent(Kost kost) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: ThemeApp.primaryDark,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 42),
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          _buildImageGallery(kost),
          const SizedBox(height: 35),
          _buildMainInformation(kost),
          const SizedBox(height: 40),
          _buildPolicySection(),
          const SizedBox(height: 40),
          _buildDescriptionSection(kost),
          const SizedBox(height: 40),
          _buildFacilitiesSection(),
          const SizedBox(height: 31),
          _buildLocationSection(kost),
          const SizedBox(height: 31),
          _buildEditButton(),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: ThemeApp.primaryDark),
    );
  }

  Widget _buildError(Object? error) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: ThemeApp.primaryDark,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(32, 150, 32, 40),
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 60,
            color: ThemeApp.textGrey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Detail kost gagal dimuat',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ThemeApp.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ThemeApp.textGrey,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: OutlinedButton(
              onPressed: _refreshData,
              style: OutlinedButton.styleFrom(
                foregroundColor: ThemeApp.buttonColor,
                side: const BorderSide(color: ThemeApp.buttonColor),
                shape: RoundedRectangleBorder(
                  borderRadius: ThemeApp.radius(18),
                ),
              ),
              child: const Text('Coba lagi'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeApp.white,
      bottomNavigationBar: AdminBottomNav(
        currentIndex: 1,
        onTap: _handleBottomNavigation,
      ),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<Kost>(
          future: _kostFuture,
          builder: (BuildContext context, AsyncSnapshot<Kost> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoading();
            }

            if (snapshot.hasError) {
              return _buildError(snapshot.error);
            }

            return _buildDetailContent(snapshot.data!);
          },
        ),
      ),
    );
  }
}
