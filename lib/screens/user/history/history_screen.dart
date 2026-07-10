import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/penyewa/kost.dart';
import '../../../models/penyewa/booking.dart';
import '../../../services/penyewa/booking_service.dart';
import '../../../services/penyewa/review_service.dart';
import '../../../widgets/bottomnav.dart';
import '../../../widgets/emptystate.dart';
import '../kost/daftarkost.dart';
import '../kost/kost_detail.dart';
import '../profile/profile_screen.dart';
import '../booking/booking_success.dart';
import '../payment/payment_screen.dart';
import '../review/tulis_ulasan.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final BookingService bookingService = BookingService();
  final ReviewService reviewService = ReviewService();

  late Future<List<Booking>> historyFuture;

  int selectedNavIndex = 2;

  Set<String> reviewedBookingIds = <String>{};

  @override
  void initState() {
    super.initState();
    historyFuture = fetchHistory();
  }

  Future<List<Booking>> fetchHistory() async {
    final List<Booking> bookings =
        await bookingService.getCurrentUserBookings();

    reviewedBookingIds =
        await reviewService.getReviewedBookingIds();

    return bookings;
  }

  Future<void> refreshData() async {
    final newFuture = fetchHistory();

    setState(() {
      historyFuture = newFuture;
    });

    await newFuture;
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1)),
      child: Scaffold(
        backgroundColor: ThemeApp.primaryDark,
        body: Column(
          children: [
            buildHeader(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: ThemeApp.backgroundGradient,
                child: FutureBuilder<List<Booking>>(
                  future: historyFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: ThemeApp.buttonColor,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return buildErrorHistory(getErrorMessage(snapshot.error));
                    }

                    final histories = snapshot.data ?? [];

                    if (histories.isEmpty) {
                      return buildEmptyHistory();
                    }

                    return RefreshIndicator(
                      color: ThemeApp.buttonColor,
                      onRefresh: refreshData,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(22, 22, 22, 118),
                        itemCount: histories.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 18);
                        },
                        itemBuilder: (context, index) {
                          return buildHistoryCard(histories[index]);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: selectedNavIndex,
          onTap: handleBottomNavTap,
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 48, 18, 16),
      decoration: BoxDecoration(
        color: ThemeApp.white,
        boxShadow: [
          ThemeApp.softShadow(
            alpha: 0.05,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.centerLeft,
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: ThemeApp.textDark,
                size: 26,
              ),
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Riwayat Pemesanan',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ThemeApp.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 42, height: 42),
        ],
      ),
    );
  }

  Widget buildEmptyHistory() {
    return RefreshIndicator(
      color: ThemeApp.buttonColor,
      onRefresh: refreshData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(22, 80, 22, 118),
        children: [
          Container(
            width: double.infinity,
            height: 330,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: ThemeApp.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                ThemeApp.softShadow(
                  alpha: 0.07,
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: const EmptyState(
              icon: Icons.history_rounded,
              title: 'Belum ada riwayat',
              message:
                  'Riwayat pemesanan kost kamu akan muncul setelah kamu melakukan booking.',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildErrorHistory(String message) {
    return RefreshIndicator(
      color: ThemeApp.buttonColor,
      onRefresh: refreshData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(22, 80, 22, 118),
        children: [
          Container(
            width: double.infinity,
            height: 330,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: ThemeApp.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                ThemeApp.softShadow(
                  alpha: 0.07,
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Gagal memuat riwayat',
              message: message,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHistoryCard(Booking item) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        openBookingSuccess(item);
      },
      onLongPress: () {
        openDetailKost(item.kostId);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: buildKostImage(
                imageUrl: item.kostImageUrl,
                width: 132,
                height: 132,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 132,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.kostName.isEmpty ? 'Kost' : item.kostName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ThemeApp.textDark,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const Spacer(),
                    buildInfoRow(
                      icon: Icons.calendar_month_rounded,
                      iconColor: ThemeApp.locationBlue,
                      text:
                          '${formatShortDate(item.startDate)} - ${formatShortDate(item.endDate)}',
                      textColor: ThemeApp.textDark,
                    ),
                    const SizedBox(height: 7),
                    buildInfoRow(
                      icon: Icons.location_on_outlined,
                      iconColor: ThemeApp.locationBlue,
                      text: item.kostLocation.isEmpty ? '-' : item.kostLocation,
                      textColor: ThemeApp.textDark,
                    ),
                    const SizedBox(height: 7),
                    buildInfoRow(
                      icon: getStatusIcon(item.normalizedStatus),
                      iconColor: getStatusColor(item.normalizedStatus),
                      text: item.statusLabel,
                      textColor: getStatusColor(item.normalizedStatus),
                    ),
                    if (item.canReview && item.id != null) ...[
                      const SizedBox(height: 7),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: reviewedBookingIds.contains(item.id)
                            ? null
                            : () {
                                openReviewScreen(item);
                              },
                        child: buildInfoRow(
                          icon: reviewedBookingIds.contains(item.id)
                              ? Icons.check_circle_outline_rounded
                              : Icons.chat_rounded,
                          iconColor: reviewedBookingIds.contains(item.id)
                              ? ThemeApp.successGreen
                              : ThemeApp.locationBlue,
                          text: reviewedBookingIds.contains(item.id)
                              ? 'Ulasan Terkirim'
                              : 'Tulis Ulasan',
                          textColor: reviewedBookingIds.contains(item.id)
                              ? ThemeApp.successGreen
                              : ThemeApp.locationBlue,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
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
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildKostImage({
    required String imageUrl,
    required double width,
    required double height,
  }) {
    if (imageUrl.trim().isEmpty) {
      return buildImagePlaceholder(width: width, height: height);
    }

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return buildImagePlaceholder(width: width, height: height);
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }

        return Container(
          width: width,
          height: height,
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
  }

  Widget buildImagePlaceholder({
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      color: ThemeApp.softBackground,
      child: const Center(
        child: Icon(
          Icons.home_work_outlined,
          color: ThemeApp.buttonColor,
          size: 40,
        ),
      ),
    );
  }

  String formatShortDate(DateTime date) {
    const months = [
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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case Booking.confirmed:
      case Booking.completed:
        return Icons.check_circle_rounded;

      case Booking.rejected:
      case Booking.cancelled:
        return Icons.cancel_rounded;

      case Booking.waitingVerification:
        return Icons.hourglass_top_rounded;

      default:
        return Icons.access_time_filled_rounded;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case Booking.confirmed:
      case Booking.completed:
        return ThemeApp.successGreen;

      case Booking.rejected:
      case Booking.cancelled:
        return ThemeApp.cancelledRed;

      default:
        return ThemeApp.pendingOrange;
    }
  }

  String getErrorMessage(Object? error) {
    final message = error?.toString() ?? '';

    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }

    if (message.trim().isEmpty) {
      return 'Terjadi kesalahan saat mengambil riwayat pemesanan.';
    }

    return message;
  }

  void openBookingSuccess(Booking booking) {
    final kost = KostModel(
      id: booking.kostId,
      name: booking.kostName,
      location: booking.kostLocation,
      price: booking.kostPrice,
      imageUrl: booking.kostImageUrl,
      rating: 0,
      available: 0,
      description: '',
    );

    if (booking.canPay) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) {
            return BookingSuccessScreen(
              booking: booking,
              kost: kost,
              selectedPaymentMethod: 'Transfer Bank BCA',
            );
          },
        ),
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return PaymentScreen(
            booking: booking,
            kost: kost,
            initialMethod: 'Transfer Bank BCA',
          );
        },
      ),
    );
  }

  void openDetailKost(String kostId) {
    if (kostId.trim().isEmpty) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return DetailKostScreen(kostId: kostId);
        },
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

    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    }
  }

  Future<void> openReviewScreen(Booking booking) async {
    final String? bookingId = booking.id;

    if (bookingId == null || bookingId.isEmpty) {
      _showReviewMessage('ID pemesanan tidak ditemukan');
      return;
    }

    final bool? created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return TulisUlasanScreen(
            bookingId: bookingId,
            kostId: booking.kostId,
            kostName: booking.kostName,
          );
        },
      ),
    );

    if (created == true && mounted) {
      await refreshData();
    }
  }

  void _showReviewMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }
}
