import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../services/admin/kost_service.dart';
import '../../widgets/adminbottomnav.dart';
import 'dashboardadmin.dart';

class TambahKostScreen extends StatefulWidget {
  const TambahKostScreen({super.key});

  @override
  State<TambahKostScreen> createState() => _TambahKostScreenState();
}

class _TambahKostScreenState extends State<TambahKostScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final KostService _kostService = KostService();
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _tersediaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  late Future<Map<int, String>> _facilitiesFuture;

  final Set<int> _selectedFacilityIds = <int>{};
  final List<XFile> _selectedImages = <XFile>[];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _facilitiesFuture = _loadFacilities();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _lokasiController.dispose();
    _hargaController.dispose();
    _tersediaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
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
      _showMessage('Halaman pemesanan akan dibuat berikutnya');
      return;
    }

    if (index == 3) {
      _showMessage('Halaman profil admin akan dibuat berikutnya');
    }
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      _showMessage('Maksimal 5 foto');
      return;
    }

    final List<XFile> images = await _imagePicker.pickMultiImage(
      imageQuality: 85,
    );

    if (images.isEmpty || !mounted) {
      return;
    }

    final int remainingSlots = 5 - _selectedImages.length;
    final List<XFile> acceptedImages = images.take(remainingSlots).toList();

    setState(() {
      _selectedImages.addAll(acceptedImages);
    });

    if (images.length > remainingSlots) {
      _showMessage('Hanya $remainingSlots foto yang ditambahkan');
    }
  }

  Future<Map<int, String>> _loadFacilities() async {
    final Map<int, String> facilities = await _kostService.getFacilities();

    _selectedFacilityIds
      ..clear()
      ..addAll(facilities.keys);

    return facilities;
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }

    return null;
  }

  String? _priceValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Harga wajib diisi';
    }

    final int? price = int.tryParse(value);

    if (price == null || price <= 0) {
      return 'Harga harus lebih dari 0';
    }

    return null;
  }

  String? _availableRoomValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Jumlah kamar wajib diisi';
    }

    final int? availableRooms = int.tryParse(value);

    if (availableRooms == null || availableRooms < 0) {
      return 'Jumlah kamar tidak valid';
    }

    return null;
  }

  Future<void> _saveKost() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedImages.isEmpty) {
      _showMessage('Tambahkan minimal 1 foto kost');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _kostService.createKost(
        namaKost: _namaController.text.trim(),
        lokasi: _lokasiController.text.trim(),
        harga: int.parse(_hargaController.text),
        tersedia: int.parse(_tersediaController.text),
        deskripsi: _deskripsiController.text.trim(),
        facilityIds: _selectedFacilityIds.toList(),
        images: List<XFile>.from(_selectedImages),
      );

      if (!mounted) {
        return;
      }

      _showMessage('Kost berhasil ditambahkan');

      await Future<void>.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        Navigator.pop(context, true);
      }
    } on KostServiceException catch (error) {
      if (mounted) {
        _showMessage(error.message);
      }
    } catch (error) {
      if (mounted) {
        _showMessage('Gagal menambahkan kost: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildHeader() {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: ThemeApp.white,
        border: Border(
          bottom: BorderSide(color: ThemeApp.borderGrey, width: 1),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            borderRadius: ThemeApp.radius(22),
            child: const SizedBox(
              width: 38,
              height: 38,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 21,
                color: ThemeApp.adminTitle,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Tambah Kost',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ThemeApp.adminTitle,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 38, height: 38),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: ThemeApp.buttonColor,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        label,
        style: const TextStyle(
          color: ThemeApp.textDark,
          fontSize: 15.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText, Widget? prefix}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: ThemeApp.textGrey,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: prefix,
      filled: true,
      fillColor: ThemeApp.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      enabledBorder: OutlineInputBorder(
        borderRadius: ThemeApp.radius(12),
        borderSide: const BorderSide(color: ThemeApp.borderGrey, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: ThemeApp.radius(12),
        borderSide: const BorderSide(color: ThemeApp.adminBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: ThemeApp.radius(12),
        borderSide: const BorderSide(color: ThemeApp.dangerRed, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: ThemeApp.radius(12),
        borderSide: const BorderSide(color: ThemeApp.dangerRed, width: 1.5),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    Widget? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          style: const TextStyle(
            color: ThemeApp.textDark,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: _inputDecoration(hintText: hint, prefix: prefix),
        ),
      ],
    );
  }

  Widget _buildPricePrefix() {
    return Container(
      width: 64,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: ThemeApp.borderGrey, width: 1.2),
        ),
      ),
      child: const Text(
        'Rp',
        style: TextStyle(
          color: ThemeApp.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _isSaving ? null : _pickImages,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: ThemeApp.adminPurple,
          radius: 12,
          strokeWidth: 1.6,
          dashWidth: 7,
          dashGap: 5,
        ),
        child: Container(
          width: double.infinity,
          height: 190,
          decoration: BoxDecoration(
            color: ThemeApp.adminSoftPurple.withValues(alpha: 0.18),
            borderRadius: ThemeApp.radius(12),
          ),
          alignment: Alignment.center,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.upload_rounded, color: ThemeApp.adminPurple, size: 42),
              SizedBox(height: 8),
              Text(
                'Tambah Foto',
                style: TextStyle(
                  color: ThemeApp.adminPurple,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Maks. 5 foto',
                style: TextStyle(
                  color: ThemeApp.textGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(XFile image, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: ThemeApp.radius(13),
          child: SizedBox.expand(
            child: FutureBuilder<Uint8List>(
              future: image.readAsBytes(),
              builder:
                  (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        color: ThemeApp.softBackground,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                          color: ThemeApp.primaryDark,
                          strokeWidth: 2,
                        ),
                      );
                    }

                    return Image.memory(snapshot.data!, fit: BoxFit.cover);
                  },
            ),
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: InkWell(
            onTap: _isSaving
                ? null
                : () {
                    _removeImage(index);
                  },
            borderRadius: ThemeApp.radius(20),
            child: Container(
              width: 29,
              height: 29,
              decoration: BoxDecoration(
                color: ThemeApp.black.withValues(alpha: 0.65),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: ThemeApp.white,
                size: 19,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Foto Kost'),
        const SizedBox(height: 15),
        _buildUploadArea(),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedImages.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemBuilder: (BuildContext context, int index) {
              return _buildImagePreview(_selectedImages[index], index);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildFacilityItem({required int id, required String name}) {
    final bool isSelected = _selectedFacilityIds.contains(id);

    return InkWell(
      onTap: _isSaving
          ? null
          : () {
              setState(() {
                if (isSelected) {
                  _selectedFacilityIds.remove(id);
                } else {
                  _selectedFacilityIds.add(id);
                }
              });
            },
      borderRadius: ThemeApp.radius(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: _isSaving
                  ? null
                  : (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedFacilityIds.add(id);
                        } else {
                          _selectedFacilityIds.remove(id);
                        }
                      });
                    },
              activeColor: ThemeApp.adminBlue,
              checkColor: ThemeApp.white,
              side: const BorderSide(color: ThemeApp.borderGrey, width: 1.3),
              shape: RoundedRectangleBorder(borderRadius: ThemeApp.radius(5)),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: ThemeApp.textDark,
                  fontSize: 15,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Fasilitas'),
        const SizedBox(height: 10),
        FutureBuilder<Map<int, String>>(
          future: _facilitiesFuture,
          builder:
              (BuildContext context, AsyncSnapshot<Map<int, String>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: ThemeApp.primaryDark,
                        strokeWidth: 2.5,
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ThemeApp.adminSoftRed,
                      borderRadius: ThemeApp.radius(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: ThemeApp.cancelledRed,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _facilitiesFuture = _loadFacilities();
                            });
                          },
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final List<MapEntry<int, String>> facilities =
                    snapshot.data?.entries.toList() ??
                    <MapEntry<int, String>>[];

                if (facilities.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Text(
                      'Belum ada fasilitas pada database.',
                      style: TextStyle(color: ThemeApp.textGrey, fontSize: 14),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: facilities.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 58,
                    crossAxisSpacing: 18,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final MapEntry<int, String> facility = facilities[index];

                    return _buildFacilityItem(
                      id: facility.key,
                      name: facility.value,
                    );
                  },
                );
              },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveKost,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeApp.adminBlue,
          foregroundColor: ThemeApp.white,
          disabledBackgroundColor: ThemeApp.lightGrey,
          disabledForegroundColor: ThemeApp.white,
          shape: RoundedRectangleBorder(borderRadius: ThemeApp.radius(13)),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 23,
                height: 23,
                child: CircularProgressIndicator(
                  color: ThemeApp.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Simpan',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 42),
        children: [
          _buildSectionTitle('Informasi Kost'),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Nama Kost',
            hint: 'Masukkan nama kost',
            controller: _namaController,
            validator: (String? value) {
              return _requiredValidator(value, 'Nama kost');
            },
          ),
          const SizedBox(height: 22),
          _buildTextField(
            label: 'Lokasi',
            hint: 'Masukkan lokasi lengkap',
            controller: _lokasiController,
            validator: (String? value) {
              return _requiredValidator(value, 'Lokasi');
            },
          ),
          const SizedBox(height: 22),
          _buildTextField(
            label: 'Harga per bulan',
            hint: 'Masukkan harga',
            controller: _hargaController,
            validator: _priceValidator,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            prefix: _buildPricePrefix(),
          ),
          const SizedBox(height: 22),
          _buildTextField(
            label: 'Jumlah kamar tersedia',
            hint: 'Masukkan jumlah kamar',
            controller: _tersediaController,
            validator: _availableRoomValidator,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const SizedBox(height: 22),
          _buildTextField(
            label: 'Deskripsi',
            hint: 'Masukkan deskripsi kost',
            controller: _deskripsiController,
            validator: (String? value) {
              return _requiredValidator(value, 'Deskripsi');
            },
            maxLines: 6,
          ),
          const SizedBox(height: 32),
          _buildImagesSection(),
          const SizedBox(height: 30),
          _buildFacilitiesSection(),
          const SizedBox(height: 28),
          _buildSaveButton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSaving,
      child: Scaffold(
        backgroundColor: ThemeApp.white,
        bottomNavigationBar: AdminBottomNav(
          currentIndex: 1,
          onTap: _isSaving ? (_) {} : _handleBottomNavigation,
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildForm()),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        final double end = distance + dashWidth;

        canvas.drawPath(
          metric.extractPath(
            distance,
            end > metric.length ? metric.length : end,
          ),
          paint,
        );

        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap;
  }
}
