import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/admin/adminbooking.dart';
import '../../services/admin/admin_booking_service.dart';

class AdminPaymentVerificationScreen extends StatefulWidget {
  final String bookingId;

  const AdminPaymentVerificationScreen({super.key, required this.bookingId});

  @override
  State<AdminPaymentVerificationScreen> createState() =>
      _AdminPaymentVerificationScreenState();
}

class _AdminPaymentVerificationScreenState
    extends State<AdminPaymentVerificationScreen> {
  final AdminBookingService _service = AdminBookingService();

  late Future<AdminBooking> _bookingFuture;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _bookingFuture = _service.getBookingById(widget.bookingId);
  }

  Future<void> _refresh() async {
    final Future<AdminBooking> newFuture = _service.getBookingById(
      widget.bookingId,
    );

    setState(() {
      _bookingFuture = newFuture;
    });

    await newFuture;
  }

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: error ? ThemeApp.cancelledRed : ThemeApp.buttonColor,
          content: Text(message),
        ),
      );
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

    return 'Rp $result';
  }

  String _capitalizeWords(String value) {
    final String normalized = value
        .trim()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');

    return normalized
        .split(RegExp(r'\s+'))
        .where((String word) => word.isNotEmpty)
        .map(
          (String word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _formatPaymentMethod(String? value) {
    final String rawValue = value?.trim() ?? '';
    final String normalized = rawValue.toLowerCase();

    if (normalized.contains('bca')) {
      return 'Transfer Bank BCA';
    }

    if (normalized.contains('e-wallet') ||
        normalized.contains('ewallet') ||
        normalized.contains('wallet')) {
      return 'E-Wallet';
    }

    if (rawValue.isEmpty) {
      return '-';
    }

    return _capitalizeWords(rawValue);
  }

  String _shortStatus(AdminBooking booking) {
    if (booking.isCompleted) return 'Selesai';
    if (booking.isConfirmed) return 'Dikonfirmasi';
    if (booking.isRejected) return 'Ditolak';
    if (booking.isCancelled) return 'Dibatalkan';
    return 'Menunggu';
  }

  Color _statusBackground(AdminBooking booking) {
    if (booking.isCompleted) return ThemeApp.adminSoftBlue;
    if (booking.isConfirmed) return ThemeApp.adminSoftGreen;
    if (booking.isRejected || booking.isCancelled) {
      return ThemeApp.adminSoftRed;
    }
    return ThemeApp.adminSoftOrange;
  }

  Color _statusForeground(AdminBooking booking) {
    if (booking.isCompleted) return ThemeApp.adminBlue;
    if (booking.isConfirmed) return ThemeApp.adminGreen;
    if (booking.isRejected || booking.isCancelled) {
      return ThemeApp.adminRed;
    }
    return ThemeApp.pendingOrange;
  }

  String _accountNumber(AdminBooking booking) {
    final String method = booking.paymentMethod?.trim().toLowerCase() ?? '';

    if (method.contains('e-wallet') ||
        method.contains('ewallet') ||
        method.contains('wallet')) {
      return '0812-3456-7890';
    }

    return '1234567890 (BCA)';
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 76,
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context, true);
            },
            borderRadius: ThemeApp.radius(20),
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: ThemeApp.textDark,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Verifikasi Pembayaran',
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ThemeApp.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 50),
        ],
      ),
    );
  }

  Widget _buildTenantAvatar(AdminBooking booking) {
    final String imageUrl = booking.tenantProfileImageUrl?.trim() ?? '';

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFD9D2FF),
        shape: BoxShape.circle,
      ),
      child: imageUrl.isEmpty
          ? const Icon(
              Icons.person_outline_rounded,
              color: ThemeApp.adminPurple,
              size: 34,
            )
          : ClipOval(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      return const Icon(
                        Icons.person_outline_rounded,
                        color: ThemeApp.adminPurple,
                        size: 34,
                      );
                    },
              ),
            ),
    );
  }

  Widget _buildSummaryCard(AdminBooking booking) {
    final int total = booking.paymentAmount ?? booking.totalPrice;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 19),
      decoration: BoxDecoration(
        color: ThemeApp.white,
        borderRadius: ThemeApp.radius(20),
        border: Border.all(color: ThemeApp.adminCardBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 52, height: 52, child: _buildTenantAvatar(booking)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 27,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      booking.tenantName,
                      maxLines: 1,
                      softWrap: false,
                      style: const TextStyle(
                        color: ThemeApp.textDark,
                        fontSize: 17.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    const Icon(
                      Icons.bed_rounded,
                      color: ThemeApp.textGrey,
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: SizedBox(
                        height: 28,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            booking.kostName,
                            maxLines: 1,
                            softWrap: false,
                            style: const TextStyle(
                              color: ThemeApp.textGrey,
                              fontSize: 18.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          SizedBox(
            width: 96,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _statusBackground(booking),
                    borderRadius: ThemeApp.radius(10),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _shortStatus(booking),
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        color: _statusForeground(booking),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 24,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      _formatRupiah(total),
                      maxLines: 1,
                      softWrap: false,
                      style: const TextStyle(
                        color: ThemeApp.textDark,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: ThemeApp.adminPurple,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildProofPlaceholder() {
    return Container(
      width: double.infinity,
      height: 360,
      decoration: BoxDecoration(
        color: ThemeApp.adminSoftRed.withValues(alpha: 0.45),
        borderRadius: ThemeApp.radius(14),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: ThemeApp.adminRed,
            size: 52,
          ),
          SizedBox(height: 12),
          Text(
            'Belum ada bukti pembayaran',
            style: TextStyle(
              color: ThemeApp.adminRed,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProofImage(AdminBooking booking) {
    final String imageUrl = booking.paymentProofUrl?.trim() ?? '';

    if (imageUrl.isEmpty) {
      return _buildProofPlaceholder();
    }

    return ClipRRect(
      borderRadius: ThemeApp.radius(14),
      child: GestureDetector(
        onTap: () {
          _showProofDialog(imageUrl);
        },
        child: Image.network(
          imageUrl,
          width: double.infinity,
          fit: BoxFit.fitWidth,
          loadingBuilder:
              (BuildContext context, Widget child, ImageChunkEvent? progress) {
                if (progress == null) return child;

                return Container(
                  width: double.infinity,
                  height: 420,
                  color: ThemeApp.softBackground,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    color: ThemeApp.primaryDark,
                    strokeWidth: 2.5,
                  ),
                );
              },
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
                return _buildProofPlaceholder();
              },
        ),
      ),
    );
  }

  Future<void> _showProofDialog(String imageUrl) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(18),
          backgroundColor: ThemeApp.black,
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  style: IconButton.styleFrom(backgroundColor: ThemeApp.white),
                  icon: const Icon(Icons.close_rounded, color: ThemeApp.black),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentDetailRow({
    required String label,
    required String value,
    bool boldValue = false,
    bool forceOneLine = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              style: const TextStyle(
                color: ThemeApp.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 6,
            child: forceOneLine
                ? SizedBox(
                    height: 23,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        value,
                        maxLines: 1,
                        softWrap: false,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: ThemeApp.textDark,
                          fontSize: 15,
                          fontWeight: boldValue
                              ? FontWeight.w900
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                : Text(
                    value,
                    maxLines: 2,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: ThemeApp.textDark,
                      fontSize: 16,
                      height: 1.25,
                      fontWeight: boldValue ? FontWeight.w900 : FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails(AdminBooking booking) {
    final String method = _formatPaymentMethod(booking.paymentMethod);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Detail Pembayaran'),
        const SizedBox(height: 16),
        _buildPaymentDetailRow(
          label: 'Total Pembayaran',
          value: _formatRupiah(booking.paymentAmount ?? booking.totalPrice),
          boldValue: true,
        ),
        const Divider(height: 1, color: ThemeApp.adminCardBorder),
        _buildPaymentDetailRow(label: 'Metode Pembayaran', value: method),
        const Divider(height: 1, color: ThemeApp.adminCardBorder),
        _buildPaymentDetailRow(
          label: 'No. Rekening Tujuan',
          value: _accountNumber(booking),
        ),
        const Divider(height: 1, color: ThemeApp.adminCardBorder),
        _buildPaymentDetailRow(
          label: 'Atas Nama',
          value: 'Barly Kost Indonesia',
          boldValue: true,
          forceOneLine: true,
        ),
      ],
    );
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String action,
    required Color color,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: ThemeApp.white,
          shape: RoundedRectangleBorder(borderRadius: ThemeApp.radius(20)),
          title: Text(
            title,
            style: const TextStyle(
              color: ThemeApp.adminTitle,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: ThemeApp.textGrey,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: ThemeApp.white,
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: Text(action),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _verify(AdminBooking booking) async {
    final bool confirmed = await _confirm(
      title: 'Verifikasi Pembayaran',
      message: booking.hasPaymentProof
          ? 'Pastikan nominal dan bukti pembayaran sudah sesuai sebelum melakukan verifikasi.'
          : 'Bukti pembayaran belum tersedia. Lanjutkan verifikasi berdasarkan data pembayaran yang ada?',
      action: 'Verifikasi',
      color: ThemeApp.successGreen,
    );

    if (!confirmed || !mounted) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await _service.verifyPayment(booking);

      if (!mounted) return;

      _showMessage('Pembayaran berhasil diverifikasi.');
      await _refresh();
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString(), error: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _reject(AdminBooking booking) async {
    final bool confirmed = await _confirm(
      title: 'Tolak Pembayaran',
      message:
          'Pembayaran akan ditolak dan status pemesanan akan diperbarui menjadi ditolak.',
      action: 'Tolak',
      color: ThemeApp.cancelledRed,
    );

    if (!confirmed || !mounted) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await _service.rejectPayment(booking);

      if (!mounted) return;

      _showMessage('Pembayaran berhasil ditolak.');
      await _refresh();
    } catch (error) {
      if (mounted) {
        _showMessage(error.toString(), error: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Widget _buildBottomActions(AdminBooking booking) {
    final bool hasPayment = booking.paymentId?.trim().isNotEmpty == true;

    final bool canReject =
        hasPayment &&
        !booking.isConfirmed &&
        !booking.isCompleted &&
        !booking.isCancelled &&
        !booking.isRejected &&
        !_isProcessing;

    final bool canVerify = booking.canVerifyPayment && !_isProcessing;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
        decoration: BoxDecoration(
          color: ThemeApp.white,
          border: const Border(
            top: BorderSide(color: ThemeApp.adminCardBorder, width: 1),
          ),
          boxShadow: [
            ThemeApp.softShadow(
              alpha: 0.05,
              blurRadius: 14,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: canReject
                      ? () {
                          _reject(booking);
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ThemeApp.cancelledRed,
                    disabledForegroundColor: ThemeApp.textGrey,
                    side: BorderSide(
                      color: canReject
                          ? ThemeApp.cancelledRed
                          : ThemeApp.borderGrey,
                      width: 1.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: ThemeApp.radius(16),
                    ),
                  ),
                  child: const Text(
                    'Tolak',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: canVerify
                      ? () {
                          _verify(booking);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeApp.successGreen,
                    foregroundColor: ThemeApp.white,
                    disabledBackgroundColor: ThemeApp.lightGrey,
                    disabledForegroundColor: ThemeApp.textGrey,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: ThemeApp.radius(16),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: ThemeApp.white,
                            strokeWidth: 2.3,
                          ),
                        )
                      : const Text(
                          'Verifikasi',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AdminBooking booking) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: ThemeApp.primaryDark,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildSummaryCard(booking),
          const SizedBox(height: 28),
          _buildSectionTitle('Bukti Pembayaran'),
          const SizedBox(height: 16),
          _buildProofImage(booking),
          const SizedBox(height: 30),
          _buildPaymentDetails(booking),
        ],
      ),
    );
  }

  Widget _buildError(Object? error) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: ThemeApp.primaryDark,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 140, 24, 40),
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 60,
            color: ThemeApp.textGrey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Data pembayaran gagal dimuat',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ThemeApp.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
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
              onPressed: _refresh,
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
    return FutureBuilder<AdminBooking>(
      future: _bookingFuture,
      builder: (BuildContext context, AsyncSnapshot<AdminBooking> snapshot) {
        return Scaffold(
          backgroundColor: ThemeApp.white,
          bottomNavigationBar: snapshot.hasData
              ? _buildBottomActions(snapshot.data!)
              : null,
          body: SafeArea(
            bottom: false,
            child: snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(
                      color: ThemeApp.primaryDark,
                    ),
                  )
                : snapshot.hasError
                ? _buildError(snapshot.error)
                : _buildContent(snapshot.data!),
          ),
        );
      },
    );
  }
}
