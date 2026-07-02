import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/penyewa/booking.dart';
import '../../../models/penyewa/kost.dart';
import '../../../models/penyewa/payment.dart';
import '../../../services/penyewa/payment_service.dart';
import '../history/history_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Booking booking;
  final KostModel kost;
  final String? initialMethod;

  const PaymentScreen({
    super.key,
    required this.booking,
    required this.kost,
    this.initialMethod,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService paymentService = PaymentService();
  final ImagePicker imagePicker = ImagePicker();

  final List<String> paymentMethods = const ['Transfer Bank BCA', 'E-Wallet'];

  String selectedMethod = 'Transfer Bank BCA';
  File? selectedProofFile;
  bool isPickingProof = false;
  bool isSubmitting = false;
  bool isLoadingPayment = true;
  Payment? createdPayment;

  @override
  void initState() {
    super.initState();

    if (widget.initialMethod != null &&
        widget.initialMethod!.trim().isNotEmpty) {
      selectedMethod = widget.initialMethod!;
    }

    loadExistingPayment();
  }

  Future<void> loadExistingPayment() async {
    final bookingId = widget.booking.id;

    if (bookingId == null || bookingId.isEmpty) {
      setState(() {
        isLoadingPayment = false;
      });
      return;
    }

    try {
      final payment = await paymentService.getPaymentByBookingId(bookingId);

      if (!mounted) {
        return;
      }

      setState(() {
        createdPayment = payment;
        isLoadingPayment = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoadingPayment = false;
      });
    }
  }

  Future<void> pickPaymentProof() async {
    if (isPickingProof || isSubmitting) {
      return;
    }

    setState(() {
      isPickingProof = true;
    });

    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (!mounted) {
        return;
      }

      if (image != null) {
        setState(() {
          selectedProofFile = File(image.path);
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      showMessage(getErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() {
          isPickingProof = false;
        });
      }
    }
  }

  Future<void> submitPayment() async {
    if (isSubmitting) {
      return;
    }

    final bookingId = widget.booking.id;

    if (bookingId == null || bookingId.isEmpty) {
      showMessage('ID booking tidak valid');
      return;
    }

    if (selectedProofFile == null) {
      showMessage('Upload bukti pembayaran terlebih dahulu');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final proofUrl = await paymentService.uploadPaymentProof(
        bookingId: bookingId,
        file: selectedProofFile!,
      );

      final payment = await paymentService.createPayment(
        booking: widget.booking,
        method: selectedMethod,
        proofUrl: proofUrl,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        createdPayment = payment;
        isSubmitting = false;
      });
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
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: ThemeApp.backgroundGradient,
          child: SafeArea(
            child: isLoadingPayment
                ? const Center(
                    child: CircularProgressIndicator(
                      color: ThemeApp.buttonColor,
                      strokeWidth: 2,
                    ),
                  )
                : createdPayment == null
                ? buildPaymentForm()
                : buildPaymentDetail(createdPayment!),
          ),
        ),
      ),
    );
  }

  Widget buildPaymentForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeader(title: 'Metode Pembayaran'),
          const SizedBox(height: 12),
          buildAmountCard(),
          const SizedBox(height: 22),
          const Text(
            'Pilih Metode Pembayaran',
            style: TextStyle(
              color: ThemeApp.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          buildMethodOption(
            method: 'Transfer Bank BCA',
            icon: Icons.account_balance_rounded,
          ),
          const SizedBox(height: 14),
          buildMethodOption(
            method: 'E-Wallet',
            icon: Icons.account_balance_wallet_rounded,
          ),
          const SizedBox(height: 22),
          buildInstructionCard(),
          const SizedBox(height: 18),
          buildProofUploadCard(),
          const SizedBox(height: 24),
          buildSubmitButton(),
        ],
      ),
    );
  }

  Widget buildHeader({required String title}) {
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: ThemeApp.textDark,
              size: 22,
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ThemeApp.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 56),
        ],
      ),
    );
  }

  Widget buildAmountCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Total Pembayaran',
            style: TextStyle(
              color: ThemeApp.textGrey,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatRupiah(widget.booking.totalPrice),
            style: const TextStyle(
              color: ThemeApp.textDark,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          buildInfoRow(label: 'Kost', value: widget.kost.name),
          const SizedBox(height: 10),
          buildInfoRow(
            label: 'Periode',
            value:
                '${formatDate(widget.booking.startDate)} - ${formatDate(widget.booking.endDate)}',
          ),
        ],
      ),
    );
  }

  Widget buildMethodOption({required String method, required IconData icon}) {
    final isSelected = selectedMethod == method;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          selectedMethod = method;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: ThemeApp.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? ThemeApp.buttonColor : ThemeApp.lightGrey,
            width: isSelected ? 1.8 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? ThemeApp.buttonColor : ThemeApp.textGrey,
              size: 25,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                method,
                style: TextStyle(
                  color: isSelected ? ThemeApp.buttonColor : ThemeApp.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? ThemeApp.buttonColor : ThemeApp.textGrey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInstructionCard() {
    final isBca = selectedMethod == 'Transfer Bank BCA';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ThemeApp.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Pembayaran',
            style: TextStyle(
              color: ThemeApp.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          buildInfoRow(label: 'Metode', value: selectedMethod),
          const SizedBox(height: 10),
          buildInfoRow(
            label: isBca ? 'No. Rekening' : 'Nomor Tujuan',
            value: isBca ? '1234567890' : '0812-3456-7890',
          ),
          const SizedBox(height: 10),
          buildInfoRow(label: 'Atas Nama', value: 'Barly Kost Indonesia'),
          const SizedBox(height: 14),
          Text(
            isBca
                ? 'Transfer sesuai total pembayaran ke rekening BCA di atas, lalu unggah bukti pembayaran.'
                : 'Lakukan pembayaran melalui E-Wallet ke nomor tujuan di atas, lalu unggah bukti pembayaran.',
            style: const TextStyle(
              color: ThemeApp.textGrey,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProofUploadCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ThemeApp.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selectedProofFile == null
              ? ThemeApp.lightGrey
              : ThemeApp.buttonColor,
          width: 1.3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bukti Pembayaran',
            style: TextStyle(
              color: ThemeApp.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          if (selectedProofFile == null)
            buildEmptyProof()
          else
            buildProofPreview(),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: isPickingProof || isSubmitting
                  ? null
                  : pickPaymentProof,
              icon: isPickingProof
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ThemeApp.buttonColor,
                      ),
                    )
                  : const Icon(Icons.upload_file_rounded, size: 22),
              label: Text(
                selectedProofFile == null
                    ? 'Upload Bukti Pembayaran'
                    : 'Ganti Bukti Pembayaran',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: ThemeApp.buttonColor,
                side: const BorderSide(color: ThemeApp.buttonColor, width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                textStyle: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyProof() {
    return Container(
      width: double.infinity,
      height: 128,
      decoration: BoxDecoration(
        color: ThemeApp.softBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeApp.lightGrey, width: 1.1),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, color: ThemeApp.textGrey, size: 38),
          SizedBox(height: 8),
          Text(
            'Belum ada bukti pembayaran',
            style: TextStyle(
              color: ThemeApp.textGrey,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProofPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.file(
        selectedProofFile!,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : submitPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeApp.buttonColor,
          foregroundColor: ThemeApp.white,
          disabledBackgroundColor: ThemeApp.textGrey,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
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
                'Lanjutkan',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
      ),
    );
  }

  Widget buildPaymentDetail(Payment payment) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        children: [
          const SizedBox(height: 28),
          buildDoneIcon(),
          const SizedBox(height: 24),
          const Text(
            'Detail Pembayaran',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ThemeApp.textDark,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Pembayaran berhasil dibuat dan sedang menunggu verifikasi admin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ThemeApp.textLight,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
              children: [
                buildDetailRow(
                  label: 'No Referensi',
                  value: shortReference(payment.id),
                ),
                buildDivider(),
                buildDetailRow(
                  label: 'Tanggal Pembayaran',
                  value: formatDate(payment.paymentDate ?? DateTime.now()),
                ),
                buildDivider(),
                buildDetailRow(
                  label: 'Jam Pembayaran',
                  value: formatTime(payment.paymentDate ?? DateTime.now()),
                ),
                buildDivider(),
                buildDetailRow(label: 'Metode', value: payment.method),
                buildDivider(),
                buildDetailRow(
                  label: 'Total Pembayaran',
                  value: formatRupiah(payment.amount),
                  valueColor: ThemeApp.buttonColor,
                ),
                buildDivider(),
                buildDetailRow(
                  label: 'Status',
                  value: payment.statusLabel,
                  valueColor: ThemeApp.pendingOrange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          buildCloseButton(),
        ],
      ),
    );
  }

  Widget buildDoneIcon() {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        color: ThemeApp.successGreen.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.receipt_long_rounded,
        color: ThemeApp.successGreen,
        size: 72,
      ),
    );
  }

  Widget buildCloseButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
            (route) => route.isFirst,
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
          'Tutup',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  Widget buildInfoRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: const TextStyle(
              color: ThemeApp.textGrey,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: ThemeApp.textDark,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
        ),
      ],
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
          width: 130,
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
              fontSize: 14,
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
      return 'Terjadi kesalahan saat membuat pembayaran';
    }

    return message;
  }

  String shortReference(String? id) {
    if (id == null || id.isEmpty) {
      return '-';
    }

    final cleanId = id.replaceAll('-', '').toUpperCase();

    if (cleanId.length <= 10) {
      return cleanId;
    }

    return cleanId.substring(0, 10);
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

  String formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute WIB';
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
