import '../../models/penyewa/app_notification.dart';
import '../../models/penyewa/booking.dart';
import '../../services/penyewa/booking_service.dart';
import '../../services/penyewa/review_service.dart';

class NotificationService {
  final BookingService _bookingService;
  final ReviewService _reviewService;

  NotificationService({
    BookingService? bookingService,
    ReviewService? reviewService,
  })  : _bookingService = bookingService ?? BookingService(),
        _reviewService = reviewService ?? ReviewService();

  Future<List<AppNotification>>
      getCurrentUserNotifications() async {
    final List<Booking> bookings =
        await _bookingService.getCurrentUserBookings();

    final Set<String> reviewedBookingIds =
        await _reviewService.getReviewedBookingIds();

    final List<AppNotification> notifications = [];

    for (final booking in bookings) {
      final String bookingId = booking.id ?? '';

      if (bookingId.isEmpty) {
        continue;
      }

      notifications.add(
        _buildBookingNotification(booking),
      );

      final bool canCreateReview =
          booking.normalizedStatus == Booking.confirmed ||
          booking.normalizedStatus == Booking.completed;

      if (canCreateReview &&
          !reviewedBookingIds.contains(bookingId)) {
        notifications.add(
          AppNotification(
            id: 'review-$bookingId',
            bookingId: bookingId,
            kostId: booking.kostId,
            kostName: _kostName(booking),
            title: 'Bagikan Pengalamanmu',
            message:
                'Pemesanan ${_kostName(booking)} sudah dikonfirmasi. Berikan rating dan ulasan untuk kost ini.',
            createdAt:
                booking.bookingDate ?? booking.startDate,
            type: AppNotificationType.review,
            requiresAction: true,
          ),
        );
      }
    }

    notifications.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return notifications;
  }

  AppNotification _buildBookingNotification(
    Booking booking,
  ) {
    final String bookingId = booking.id!;
    final String kostName = _kostName(booking);
    final DateTime createdAt =
        booking.bookingDate ?? booking.startDate;

    switch (booking.normalizedStatus) {
      case Booking.pendingPayment:
        return AppNotification(
          id: 'booking-$bookingId-pending',
          bookingId: bookingId,
          kostId: booking.kostId,
          kostName: kostName,
          title: 'Selesaikan Pembayaran',
          message:
              'Pemesanan $kostName berhasil dibuat. Silakan lanjutkan pembayaran agar pesanan dapat diproses.',
          createdAt: createdAt,
          type: AppNotificationType.pendingPayment,
          requiresAction: true,
        );

      case Booking.waitingVerification:
        return AppNotification(
          id: 'booking-$bookingId-verification',
          bookingId: bookingId,
          kostId: booking.kostId,
          kostName: kostName,
          title: 'Pembayaran Sedang Diverifikasi',
          message:
              'Bukti pembayaran $kostName sudah diterima dan sedang diperiksa oleh admin.',
          createdAt: createdAt,
          type: AppNotificationType.waitingVerification,
          requiresAction: false,
        );

      case Booking.confirmed:
        return AppNotification(
          id: 'booking-$bookingId-confirmed',
          bookingId: bookingId,
          kostId: booking.kostId,
          kostName: kostName,
          title: 'Pemesanan Dikonfirmasi',
          message:
              'Pembayaran $kostName sudah dikonfirmasi. Pemesanan kamu telah aktif.',
          createdAt: createdAt,
          type: AppNotificationType.confirmed,
          requiresAction: false,
        );

      case Booking.rejected:
        return AppNotification(
          id: 'booking-$bookingId-rejected',
          bookingId: bookingId,
          kostId: booking.kostId,
          kostName: kostName,
          title: 'Pembayaran Ditolak',
          message:
              'Pembayaran $kostName belum dapat diterima. Periksa kembali informasi pemesanan kamu.',
          createdAt: createdAt,
          type: AppNotificationType.rejected,
          requiresAction: true,
        );

      case Booking.cancelled:
        return AppNotification(
          id: 'booking-$bookingId-cancelled',
          bookingId: bookingId,
          kostId: booking.kostId,
          kostName: kostName,
          title: 'Pemesanan Dibatalkan',
          message:
              'Pemesanan $kostName telah dibatalkan.',
          createdAt: createdAt,
          type: AppNotificationType.cancelled,
          requiresAction: false,
        );

      case Booking.completed:
        return AppNotification(
          id: 'booking-$bookingId-completed',
          bookingId: bookingId,
          kostId: booking.kostId,
          kostName: kostName,
          title: 'Pemesanan Selesai',
          message:
              'Masa pemesanan $kostName telah selesai. Terima kasih sudah menggunakan Barly Kost.',
          createdAt: booking.endDate,
          type: AppNotificationType.completed,
          requiresAction: false,
        );

      default:
        return AppNotification(
          id: 'booking-$bookingId-status',
          bookingId: bookingId,
          kostId: booking.kostId,
          kostName: kostName,
          title: 'Pembaruan Pemesanan',
          message:
              'Status pemesanan $kostName telah diperbarui menjadi ${booking.statusLabel}.',
          createdAt: createdAt,
          type: AppNotificationType.waitingVerification,
          requiresAction: false,
        );
    }
  }

  String _kostName(Booking booking) {
    final value = booking.kostName.trim();

    if (value.isEmpty) {
      return 'kost';
    }

    return value;
  }
}
