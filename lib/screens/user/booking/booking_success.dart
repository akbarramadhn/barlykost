import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/booking.dart';
import '../../../models/kost.dart';
import '../history/history_screen.dart';
import '../payment/payment_screen.dart';

class BookingSuccessScreen extends StatelessWidget {
  final Booking booking;
  final KostModel kost;
  final String selectedPaymentMethod;

  const BookingSuccessScreen({
    super.key,
    required this.booking,
    required this.kost,
    required this.selectedPaymentMethod,
  });

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
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  buildSuccessIcon(),
                  const SizedBox(height: 26),
                  const Text(
                    'Pemesanan Berhasil',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ThemeApp.textDark,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Pemesanan kost berhasil dibuat. Silakan lanjutkan proses pembayaran.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ThemeApp.textLight,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),
                  buildBookingCard(),
                  const SizedBox(height: 28),
                  buildPaymentButton(context),
                  const SizedBox(height: 13),
                  buildHistoryButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSuccessIcon() {
    return Container(
      width: 116,
      height: 116,
      decoration: BoxDecoration(
        color: ThemeApp.successGreen.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_circle_rounded,
        color: ThemeApp.successGreen,
        size: 88,
      ),
    );
  }

  Widget buildBookingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeApp.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          ThemeApp.softShadow(
            alpha: 0.08,
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          buildDetailRow(label: 'Kost', value: kost.name),
          buildDivider(),
          buildDetailRow(
            label: 'Tanggal Mulai',
            value: formatDate(booking.startDate),
          ),
          buildDivider(),
          buildDetailRow(
            label: 'Tanggal Selesai',
            value: formatDate(booking.endDate),
          ),
          buildDivider(),
          buildDetailRow(label: 'Periode', value: '1 Bulan'),
          buildDivider(),
          buildDetailRow(
            label: 'Metode Pembayaran',
            value: selectedPaymentMethod,
            valueColor: ThemeApp.buttonColor,
          ),
          buildDivider(),
          buildDetailRow(
            label: 'Total Harga',
            value: formatRupiah(booking.totalPrice),
            valueColor: ThemeApp.buttonColor,
          ),
          buildDivider(),
          buildDetailRow(
            label: 'Status',
            value: booking.statusLabel,
            valueColor: ThemeApp.pendingOrange,
          ),
        ],
      ),
    );
  }

  Widget buildDetailRow({
    required String label,
    required String value,
    Color valueColor = ThemeApp.textDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 115,
          child: Text(
            label,
            style: const TextStyle(
              color: ThemeApp.textGrey,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor,
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Divider(color: ThemeApp.lightGrey, height: 1),
    );
  }

  Widget buildPaymentButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentScreen(
                booking: booking,
                kost: kost,
                initialMethod: selectedPaymentMethod,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeApp.buttonColor,
          foregroundColor: ThemeApp.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Lanjut ke Pembayaran',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget buildHistoryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
            (route) => route.isFirst,
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: ThemeApp.buttonColor,
          side: const BorderSide(color: ThemeApp.buttonColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Lihat Riwayat Pemesanan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
}
