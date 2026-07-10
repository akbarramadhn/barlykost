import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/admin/adminbooking.dart';
import '../../services/admin/admin_booking_service.dart';

class AdminBookingDetailScreen
    extends StatefulWidget {
  final String bookingId;

  const AdminBookingDetailScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<AdminBookingDetailScreen>
      createState() =>
          _AdminBookingDetailScreenState();
}

class _AdminBookingDetailScreenState
    extends State<AdminBookingDetailScreen> {
  final AdminBookingService _service =
      AdminBookingService();

  late Future<AdminBooking> _bookingFuture;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    _bookingFuture = _service.getBookingById(
      widget.bookingId,
    );
  }

  Future<void> _refresh() async {
    final Future<AdminBooking> newFuture =
        _service.getBookingById(
      widget.bookingId,
    );

    setState(() {
      _bookingFuture = newFuture;
    });

    await newFuture;
  }

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: error
              ? ThemeApp.cancelledRed
              : ThemeApp.buttonColor,
          content: Text(message),
        ),
      );
  }

  String _capitalizeWords(String value) {
    final String normalized = value
        .trim()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');

    return normalized
        .split(RegExp(r'\s+'))
        .where(
          (String word) => word.isNotEmpty,
        )
        .map(
          (String word) =>
              '${word[0].toUpperCase()}'
              '${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _formatRupiah(int value) {
    final String number = value.toString();
    final StringBuffer result =
        StringBuffer();

    for (
      int index = 0;
      index < number.length;
      index++
    ) {
      if (index > 0 &&
          (number.length - index) % 3 == 0) {
        result.write('.');
      }

      result.write(number[index]);
    }

    return 'Rp $result';
  }

  String _formatDate(
    DateTime? date, {
    bool withTime = false,
  }) {
    if (date == null) {
      return '-';
    }

    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final String base =
        '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';

    if (!withTime) {
      return base;
    }

    final String hour =
        date.hour.toString().padLeft(2, '0');

    final String minute =
        date.minute.toString().padLeft(2, '0');

    return '$base, $hour:$minute';
  }

  Color _statusBackground(
    AdminBooking booking,
  ) {
    if (booking.isCompleted) {
      return ThemeApp.adminSoftBlue;
    }

    if (booking.isConfirmed) {
      return ThemeApp.adminSoftGreen;
    }

    if (booking.isRejected ||
        booking.isCancelled) {
      return ThemeApp.adminSoftRed;
    }

    return ThemeApp.adminSoftOrange;
  }

  Color _statusForeground(
    AdminBooking booking,
  ) {
    if (booking.isCompleted) {
      return ThemeApp.adminBlue;
    }

    if (booking.isConfirmed) {
      return ThemeApp.adminGreen;
    }

    if (booking.isRejected ||
        booking.isCancelled) {
      return ThemeApp.adminRed;
    }

    return ThemeApp.pendingOrange;
  }

  IconData _statusIcon(
    AdminBooking booking,
  ) {
    if (booking.isConfirmed) {
      return Icons.check_circle_outline_rounded;
    }

    if (booking.isRejected ||
        booking.isCancelled) {
      return Icons.cancel_outlined;
    }

    if (booking.isCompleted) {
      return Icons.task_alt_rounded;
    }

    return Icons.schedule_rounded;
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
              'Detail Pemesanan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ThemeApp.adminTitle,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(
            width: 38,
            height: 38,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(
    AdminBooking booking,
  ) {
    final Color foreground =
        _statusForeground(booking);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: _statusBackground(booking),
        borderRadius: ThemeApp.radius(18),
        border: Border.all(
          color: foreground.withValues(
            alpha: 0.35,
          ),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _statusIcon(booking),
            color: foreground,
            size: 25,
          ),
          const SizedBox(width: 10),
          Text(
            'Status',
            style: TextStyle(
              color: foreground,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: 24,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  booking.statusLabel,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeApp.white,
        borderRadius: ThemeApp.radius(20),
        border: Border.all(
          color: ThemeApp.adminCardBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: ThemeApp.adminPurple,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 22),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInformationRow({
    required String label,
    required String value,
    bool bold = false,
    Color? valueColor,
    bool allowTwoLines = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 18,
      ),
      child: Row(
        crossAxisAlignment: allowTwoLines
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              maxLines: 1,
              style: const TextStyle(
                color: ThemeApp.textDark,
                fontSize: 14,
                height: 1.25,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: allowTwoLines
                ? Text(
                    value,
                    maxLines: 2,
                    softWrap: true,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: valueColor ??
                          ThemeApp.textDark,
                      fontSize: 13.5,
                      height: 1.35,
                      fontWeight: bold
                          ? FontWeight.w800
                          : FontWeight.w500,
                    ),
                  )
                : SizedBox(
                    height: 23,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment:
                          Alignment.centerRight,
                      child: Text(
                        value,
                        maxLines: 1,
                        softWrap: false,
                        textAlign:
                            TextAlign.right,
                        style: TextStyle(
                          color: valueColor ??
                              ThemeApp.textDark,
                          fontSize: 14,
                          height: 1.2,
                          fontWeight: bold
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(
        bottom: 18,
      ),
      child: Divider(
        height: 1,
        color: ThemeApp.adminCardBorder,
      ),
    );
  }

  Widget _buildBookingCard(
    AdminBooking booking,
  ) {
    final String phone =
        booking.tenantPhone.trim().isEmpty
            ? '-'
            : booking.tenantPhone.trim();

    final String period =
        '${_formatDate(booking.startDate)} - '
        '${_formatDate(booking.endDate)}';

    return _buildCard(
      title: 'Informasi Pemesanan',
      children: [
        _buildInformationRow(
          label: 'ID Pemesanan',
          value: booking.id,
          bold: true,
          allowTwoLines: true,
        ),
        _buildInformationRow(
          label: 'Tanggal Pemesanan',
          value: _formatDate(
            booking.bookingDate,
            withTime: true,
          ),
        ),
        _buildInformationRow(
          label: 'Penyewa',
          value: booking.tenantName,
          bold: true,
        ),
        _buildInformationRow(
          label: 'No. Telepon',
          value: phone,
        ),
        _buildDivider(),
        _buildInformationRow(
          label: 'Kost',
          value: booking.kostName,
          bold: true,
        ),
        _buildInformationRow(
          label: 'Periode',
          value: period,
        ),
        _buildInformationRow(
          label: 'Total Pembayaran',
          value: _formatRupiah(
            booking.paymentAmount ??
                booking.totalPrice,
          ),
          bold: true,
          valueColor:
              ThemeApp.adminPurple,
        ),
      ],
    );
  }

  Widget _buildPaymentCard(
    AdminBooking booking,
  ) {
    final String paymentMethod =
        booking.paymentMethod
                    ?.trim()
                    .isNotEmpty ==
                true
            ? booking.paymentMethod!.trim()
            : '-';

    final String rawStatus =
        booking.paymentStatus
                    ?.trim()
                    .isNotEmpty ==
                true
            ? booking.paymentStatus!.trim()
            : 'Belum dibayar';

    final String paymentStatus =
        _capitalizeWords(rawStatus);

    return _buildCard(
      title: 'Informasi Pembayaran',
      children: [
        _buildInformationRow(
          label: 'Metode',
          value: paymentMethod,
        ),
        _buildInformationRow(
          label: 'Nominal',
          value: _formatRupiah(
            booking.paymentAmount ??
                booking.totalPrice,
          ),
          bold: true,
        ),
        _buildInformationRow(
          label: 'Tanggal',
          value: _formatDate(
            booking.paymentDate,
            withTime: true,
          ),
        ),
        _buildInformationRow(
          label: 'Status Pembayaran',
          value: paymentStatus,
          bold: true,
          valueColor:
              _statusForeground(booking),
        ),
      ],
    );
  }

  Widget _buildProofPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: ThemeApp.adminSoftRed
            .withValues(alpha: 0.45),
        borderRadius: ThemeApp.radius(14),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: ThemeApp.adminRed,
            size: 24,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Belum ada bukti pembayaran',
              style: TextStyle(
                color: ThemeApp.adminRed,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProofCard(
    AdminBooking booking,
  ) {
    final String imageUrl =
        booking.paymentProofUrl?.trim() ?? '';

    return _buildCard(
      title: 'Bukti Pembayaran',
      children: [
        if (imageUrl.isEmpty)
          _buildProofPlaceholder()
        else
          InkWell(
            onTap: () {
              _showProofDialog(imageUrl);
            },
            borderRadius: ThemeApp.radius(16),
            child: ClipRRect(
              borderRadius:
                  ThemeApp.radius(16),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (
                    BuildContext context,
                    Widget child,
                    ImageChunkEvent? progress,
                  ) {
                    if (progress == null) {
                      return child;
                    }

                    return Container(
                      color:
                          ThemeApp.softBackground,
                      alignment: Alignment.center,
                      child:
                          const CircularProgressIndicator(
                        color:
                            ThemeApp.primaryDark,
                        strokeWidth: 2.5,
                      ),
                    );
                  },
                  errorBuilder: (
                    BuildContext context,
                    Object error,
                    StackTrace? stackTrace,
                  ) {
                    return _buildProofPlaceholder();
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showProofDialog(
    String imageUrl,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (
        BuildContext dialogContext,
      ) {
        return Dialog(
          insetPadding:
              const EdgeInsets.all(18),
          backgroundColor: ThemeApp.black,
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  style: IconButton.styleFrom(
                    backgroundColor:
                        ThemeApp.white,
                  ),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: ThemeApp.black,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String action,
    required Color color,
  }) async {
    final bool? result =
        await showDialog<bool>(
      context: context,
      builder: (
        BuildContext dialogContext,
      ) {
        return AlertDialog(
          backgroundColor: ThemeApp.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                ThemeApp.radius(20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: ThemeApp.adminTitle,
              fontWeight: FontWeight.w800,
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
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor:
                    ThemeApp.white,
                minimumSize:
                    const Size(0, 44),
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
              ),
              child: Text(action),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _verify(
    AdminBooking booking,
  ) async {
    final bool confirmed =
        await _confirm(
      title: 'Verifikasi Pembayaran',
      message: booking.hasPaymentProof
          ? 'Pastikan nominal dan bukti pembayaran sudah sesuai sebelum melakukan verifikasi.'
          : 'Bukti pembayaran belum tersedia. Lanjutkan verifikasi berdasarkan data pembayaran yang ada?',
      action: 'Verifikasi',
      color: ThemeApp.successGreen,
    );

    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _service.verifyPayment(
        booking,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Pembayaran berhasil diverifikasi.',
      );

      await _refresh();
    } catch (error) {
      if (mounted) {
        _showMessage(
          error.toString(),
          error: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _reject(
    AdminBooking booking,
  ) async {
    final bool confirmed =
        await _confirm(
      title: 'Tolak Pembayaran',
      message:
          'Pembayaran akan ditolak dan status pembayaran diperbarui menjadi ditolak.',
      action: 'Tolak',
      color: ThemeApp.cancelledRed,
    );

    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _service.rejectPayment(
        booking,
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        'Pembayaran berhasil ditolak.',
      );

      await _refresh();
    } catch (error) {
      if (mounted) {
        _showMessage(
          error.toString(),
          error: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Widget _buildActions(
    AdminBooking booking,
  ) {
    final bool canVerify =
        booking.canVerifyPayment &&
        !_isProcessing;

    final bool canReject =
        booking.canRejectPayment &&
        !_isProcessing;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          24,
          13,
          24,
          15,
        ),
        decoration: BoxDecoration(
          color: ThemeApp.white,
          border: const Border(
            top: BorderSide(
              color:
                  ThemeApp.adminCardBorder,
              width: 1,
            ),
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
                height: 54,
                child: OutlinedButton(
                  onPressed: canReject
                      ? () {
                          _reject(booking);
                        }
                      : null,
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor:
                        ThemeApp.cancelledRed,
                    disabledForegroundColor:
                        ThemeApp.textGrey,
                    side: BorderSide(
                      color: canReject
                          ? ThemeApp.cancelledRed
                          : ThemeApp.borderGrey,
                      width: 1.3,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          ThemeApp.radius(16),
                    ),
                  ),
                  child: const Text(
                    'Tolak',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: canVerify
                      ? () {
                          _verify(booking);
                        }
                      : null,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        ThemeApp.successGreen,
                    foregroundColor:
                        ThemeApp.white,
                    disabledBackgroundColor:
                        ThemeApp.lightGrey,
                    disabledForegroundColor:
                        ThemeApp.textGrey,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          ThemeApp.radius(16),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            color:
                                ThemeApp.white,
                            strokeWidth: 2.3,
                          ),
                        )
                      : const Text(
                          'Verifikasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w800,
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

  Widget _buildContent(
    AdminBooking booking,
  ) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: ThemeApp.primaryDark,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          24,
          0,
          24,
          30,
        ),
        children: [
          _buildHeader(),
          const SizedBox(height: 10),
          _buildStatusBanner(booking),
          const SizedBox(height: 22),
          _buildBookingCard(booking),
          const SizedBox(height: 18),
          _buildPaymentCard(booking),
          const SizedBox(height: 18),
          _buildProofCard(booking),
        ],
      ),
    );
  }

  Widget _buildError(
    Object? error,
  ) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: ThemeApp.primaryDark,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          24,
          140,
          24,
          40,
        ),
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 60,
            color: ThemeApp.textGrey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Detail pemesanan gagal dimuat',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ThemeApp.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
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
              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    ThemeApp.buttonColor,
                side: const BorderSide(
                  color:
                      ThemeApp.buttonColor,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      ThemeApp.radius(18),
                ),
              ),
              child:
                  const Text('Coba lagi'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return FutureBuilder<AdminBooking>(
      future: _bookingFuture,
      builder: (
        BuildContext context,
        AsyncSnapshot<AdminBooking> snapshot,
      ) {
        return Scaffold(
          backgroundColor: ThemeApp.white,
          bottomNavigationBar:
              snapshot.hasData
                  ? _buildActions(
                      snapshot.data!,
                    )
                  : null,
          body: SafeArea(
            bottom: false,
            child:
                snapshot.connectionState ==
                        ConnectionState.waiting
                    ? const Center(
                        child:
                            CircularProgressIndicator(
                          color:
                              ThemeApp.primaryDark,
                        ),
                      )
                    : snapshot.hasError
                        ? _buildError(
                            snapshot.error,
                          )
                        : _buildContent(
                            snapshot.data!,
                          ),
          ),
        );
      },
    );
  }
}