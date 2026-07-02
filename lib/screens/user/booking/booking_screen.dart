import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/penyewa/booking.dart';
import '../../../models/penyewa/kost.dart';
import '../../../models/user.dart';
import '../../../services/auth_service.dart';
import '../../../services/penyewa/booking_service.dart';
import '../../../widgets/bottomnav.dart';
import '../history/history_screen.dart';
import '../kost/daftarkost.dart';
import '../profile/profile_screen.dart';
import 'booking_success.dart';

class BookingScreen extends StatefulWidget {
  final KostModel kost;
  final List<String> images;

  const BookingScreen({super.key, required this.kost, this.images = const []});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final AuthService authService = AuthService();
  final BookingService bookingService = BookingService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  DateTime? selectedStartDate;
  String? selectedPaymentMethod;

  bool isLoadingProfile = true;
  bool isSubmitting = false;

  int currentImageIndex = 0;
  int selectedNavIndex = 0;

  final List<String> paymentMethods = ['Transfer Bank BCA', 'E-Wallet'];

  List<String> get displayImages {
    final validImages = widget.images
        .where((image) => image.trim().isNotEmpty)
        .toList();

    if (validImages.isNotEmpty) {
      return validImages;
    }

    if (widget.kost.imageUrl.trim().isNotEmpty) {
      return [widget.kost.imageUrl];
    }

    return [];
  }

  int get platformFee {
    return Booking.calculatePlatformFee(widget.kost.price);
  }

  int get totalPrice {
    return Booking.calculateTotalPrice(widget.kost.price);
  }

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> loadUserProfile() async {
    try {
      final UserModel user = await authService.fetchCurrentUser();

      if (!mounted) {
        return;
      }

      setState(() {
        nameController.text = user.displayName;
        phoneController.text = user.displayPhone;
        isLoadingProfile = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoadingProfile = false;
      });

      showMessage(getErrorMessage(error));
    }
  }

  Future<void> selectStartDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final result = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? today,
      firstDate: today,
      lastDate: DateTime(now.year + 2, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ThemeApp.buttonColor,
              onPrimary: ThemeApp.white,
              surface: ThemeApp.white,
              onSurface: ThemeApp.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result == null) {
      return;
    }

    setState(() {
      selectedStartDate = result;
    });
  }

  Future<void> submitBooking() async {
    if (isSubmitting) {
      return;
    }

    if (widget.kost.available <= 0) {
      showMessage('Kamar kost sudah tidak tersedia');
      return;
    }

    if (nameController.text.trim().isEmpty) {
      showMessage('Nama lengkap wajib diisi');
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      showMessage('Nomor telepon wajib diisi');
      return;
    }

    if (selectedStartDate == null) {
      showMessage('Pilih tanggal mulai kost terlebih dahulu');
      return;
    }

    if (selectedPaymentMethod == null) {
      showMessage('Pilih metode pembayaran terlebih dahulu');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final booking = await bookingService.createBooking(
        kostId: widget.kost.id,
        startDate: selectedStartDate!,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) {
            return BookingSuccessScreen(
              booking: booking,
              kost: widget.kost,
              selectedPaymentMethod: selectedPaymentMethod!,
            );
          },
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isSubmitting = false;
      });

      showMessage(getErrorMessage(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1)),
      child: Scaffold(
        backgroundColor: ThemeApp.white,
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(children: [buildImageHeader(), buildBookingContent()]),
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: selectedNavIndex,
          onTap: handleBottomNavTap,
        ),
      ),
    );
  }

  Widget buildImageHeader() {
    final images = displayImages;

    return SizedBox(
      width: double.infinity,
      height: 330,
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
                  height: 330,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) {
                      return child;
                    }

                    return Container(
                      width: double.infinity,
                      height: 330,
                      color: ThemeApp.softBackground,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: ThemeApp.buttonColor,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return buildImagePlaceholder();
                  },
                );
              },
            ),
          ),
          Positioned(
            top: 46,
            left: 24,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: ThemeApp.white.withValues(alpha: 0.95),
                  shape: BoxShape.circle,
                  boxShadow: [
                    ThemeApp.softShadow(
                      alpha: 0.10,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: ThemeApp.buttonColor,
                  size: 22,
                ),
              ),
            ),
          ),
          if (images.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: buildImageIndicator(images.length),
            ),
        ],
      ),
    );
  }

  Widget buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 330,
      color: ThemeApp.softBackground,
      child: const Center(
        child: Icon(
          Icons.home_work_outlined,
          color: ThemeApp.buttonColor,
          size: 76,
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
          width: isActive ? 13 : 11,
          height: isActive ? 13 : 11,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? ThemeApp.buttonColor : ThemeApp.white,
            shape: BoxShape.circle,
            border: Border.all(color: ThemeApp.white, width: 1),
          ),
        );
      }),
    );
  }

  Widget buildBookingContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [ThemeApp.primaryDark, ThemeApp.primaryLight],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildKostInformation(),
          const SizedBox(height: 34),
          const Text(
            'Informasi Kontak',
            style: TextStyle(
              color: ThemeApp.black,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          buildContactField(
            controller: nameController,
            hintText: 'Nama Lengkap',
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 14),
          buildContactField(
            controller: phoneController,
            hintText: 'Nomor Telepon',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 30),
          const Text(
            'Tanggal Mulai Kost',
            style: TextStyle(
              color: ThemeApp.black,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          buildDateField(),
          const SizedBox(height: 14),
          buildPeriodField(),
          const SizedBox(height: 26),
          buildPriceCard(),
          const SizedBox(height: 28),
          buildPaymentMethodField(),
          const SizedBox(height: 24),
          buildConfirmButton(),
        ],
      ),
    );
  }

  Widget buildKostInformation() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final priceWidth = (constraints.maxWidth * 0.37)
            .clamp(118.0, 145.0)
            .toDouble();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.kost.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ThemeApp.black,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildInformationRow(
                        icon: Icons.location_on_outlined,
                        iconColor: ThemeApp.locationBlue,
                        text: widget.kost.location,
                        textColor: ThemeApp.black,
                      ),
                      const SizedBox(height: 11),
                      buildInformationRow(
                        icon: Icons.star_rounded,
                        iconColor: ThemeApp.starColor,
                        text:
                            '${formatRating(widget.kost.rating)} (100 reviewers)',
                        textColor: ThemeApp.black,
                      ),
                      const SizedBox(height: 11),
                      buildInformationRow(
                        icon: Icons.check_circle_rounded,
                        iconColor: ThemeApp.successGreen,
                        text: '${widget.kost.available} Tersedia',
                        textColor: ThemeApp.black,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: priceWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          formatRupiah(widget.kost.price),
                          maxLines: 1,
                          style: const TextStyle(
                            color: ThemeApp.priceDark,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        '/Perbulan',
                        style: TextStyle(
                          color: ThemeApp.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget buildInformationRow({
    required IconData icon,
    required Color iconColor,
    required String text,
    required Color textColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 23),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
              height: 1.18,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildContactField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
  }) {
    return SizedBox(
      height: 58,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        cursorColor: ThemeApp.white,
        style: const TextStyle(
          color: ThemeApp.white,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: isLoadingProfile ? 'Memuat...' : hintText,
          hintStyle: const TextStyle(
            color: ThemeApp.white,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: ThemeApp.white, width: 1.6),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: ThemeApp.white, width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: ThemeApp.cancelledRed,
              width: 1.6,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: ThemeApp.cancelledRed,
              width: 1.8,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDateField() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: selectStartDate,
      child: Container(
        width: double.infinity,
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: ThemeApp.white, width: 1.6),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedStartDate == null
                    ? 'dd/mm/yyyy'
                    : formatNumericDate(selectedStartDate!),
                style: const TextStyle(
                  color: ThemeApp.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_month_rounded,
              color: ThemeApp.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPeriodField() {
    return Container(
      width: double.infinity,
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: ThemeApp.white, width: 1.6),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              '1 Bulan',
              style: TextStyle(
                color: ThemeApp.white,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.lock_outline_rounded, color: ThemeApp.white, size: 22),
        ],
      ),
    );
  }

  Widget buildPriceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        color: ThemeApp.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rincian Harga',
            style: TextStyle(
              color: ThemeApp.textDark,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          buildPriceRow(
            label: 'Kost 1 Bulan',
            value: formatRupiah(widget.kost.price),
          ),
          const SizedBox(height: 14),
          buildPriceRow(
            label: 'Platform Fee 2%',
            value: formatRupiah(platformFee),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: ThemeApp.lightGrey),
          ),
          buildPriceRow(
            label: 'Total Harga',
            value: formatRupiah(totalPrice),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget buildPriceRow({
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isTotal ? ThemeApp.textDark : ThemeApp.textGrey,
              fontSize: isTotal ? 17 : 15.5,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? ThemeApp.textDark : ThemeApp.textGrey,
            fontSize: isTotal ? 17 : 15.5,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget buildPaymentMethodField() {
    return Container(
      width: double.infinity,
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: ThemeApp.buttonColor, width: 1.7),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPaymentMethod,
          isExpanded: true,
          dropdownColor: ThemeApp.white,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: ThemeApp.buttonColor,
            size: 29,
          ),
          hint: const Text(
            'Pilih Metode Pembayaran',
            style: TextStyle(
              color: ThemeApp.buttonColor,
              fontSize: 16.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: const TextStyle(
            color: ThemeApp.buttonColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          items: paymentMethods.map((method) {
            return DropdownMenuItem<String>(
              value: method,
              child: Text(method, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedPaymentMethod = value;
            });
          },
        ),
      ),
    );
  }

  Widget buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: isSubmitting || isLoadingProfile ? null : submitBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeApp.buttonColor,
          foregroundColor: ThemeApp.white,
          disabledBackgroundColor: ThemeApp.textGrey,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(31),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 23,
                height: 23,
                child: CircularProgressIndicator(
                  color: ThemeApp.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Konfirmasi Pesanan',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
      ),
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
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  String getErrorMessage(Object? error) {
    final message = error?.toString() ?? '';

    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }

    if (message.trim().isEmpty) {
      return 'Terjadi kesalahan saat membuat pemesanan';
    }

    return message;
  }

  String formatNumericDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  String formatRupiah(int value) {
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

  String formatRating(double value) {
    return '${value.toStringAsFixed(1).replaceAll('.', ',')}/5';
  }
}
