import '../../models/admin/adminbooking.dart';
import '../../models/admin/admin_notification.dart';
import 'admin_booking_service.dart';

class AdminNotificationService {
  final AdminBookingService _bookingService;

  AdminNotificationService({
    AdminBookingService? bookingService,
  }) : _bookingService =
            bookingService ?? AdminBookingService();

  Future<List<AdminNotification>>
      getAdminNotifications() async {
    final List<AdminBooking> bookings =
        await _bookingService.getAllBookings();

    final List<AdminNotification> notifications =
        bookings
            .where(
              (AdminBooking booking) =>
                  booking.id.trim().isNotEmpty,
            )
            .map(_fromBooking)
            .toList();

    notifications.sort(
      (AdminNotification first,
              AdminNotification second) =>
          second.createdAt.compareTo(first.createdAt),
    );

    return notifications;
  }

  AdminNotification _fromBooking(
    AdminBooking booking,
  ) {
    final String tenantName =
        booking.tenantName.trim().isEmpty
            ? 'Penyewa'
            : booking.tenantName.trim();

    final String kostName =
        booking.kostName.trim().isEmpty
            ? 'Kost'
            : booking.kostName.trim();

    if (booking.canVerifyPayment) {
      return AdminNotification(
        id: 'verification-${booking.id}',
        bookingId: booking.id,
        tenantName: tenantName,
        kostName: kostName,
        title: 'Pembayaran Perlu Diverifikasi',
        message:
            '$tenantName telah mengirim bukti pembayaran untuk $kostName. Periksa bukti dan nominal pembayarannya.',
        createdAt: booking.paymentDate ??
            booking.bookingDate ??
            booking.startDate ??
            DateTime.now(),
        type:
            AdminNotificationType.paymentVerification,
        requiresAction: true,
      );
    }

    if (booking.isCompleted) {
      return AdminNotification(
        id: 'completed-${booking.id}',
        bookingId: booking.id,
        tenantName: tenantName,
        kostName: kostName,
        title: 'Pemesanan Selesai',
        message:
            'Masa pemesanan $tenantName di $kostName telah selesai.',
        createdAt: booking.endDate ??
            booking.bookingDate ??
            DateTime.now(),
        type: AdminNotificationType.completed,
        requiresAction: false,
      );
    }

    if (booking.isCancelled) {
      return AdminNotification(
        id: 'cancelled-${booking.id}',
        bookingId: booking.id,
        tenantName: tenantName,
        kostName: kostName,
        title: 'Pemesanan Dibatalkan',
        message:
            'Pemesanan $tenantName untuk $kostName telah dibatalkan.',
        createdAt: booking.bookingDate ??
            booking.startDate ??
            DateTime.now(),
        type: AdminNotificationType.cancelled,
        requiresAction: false,
      );
    }

    if (booking.isRejected) {
      return AdminNotification(
        id: 'rejected-${booking.id}',
        bookingId: booking.id,
        tenantName: tenantName,
        kostName: kostName,
        title: 'Pembayaran Ditolak',
        message:
            'Pembayaran $tenantName untuk $kostName telah ditolak.',
        createdAt: booking.paymentDate ??
            booking.bookingDate ??
            DateTime.now(),
        type: AdminNotificationType.rejected,
        requiresAction: false,
      );
    }

    if (booking.isConfirmed) {
      return AdminNotification(
        id: 'confirmed-${booking.id}',
        bookingId: booking.id,
        tenantName: tenantName,
        kostName: kostName,
        title: 'Pemesanan Dikonfirmasi',
        message:
            'Pembayaran $tenantName untuk $kostName telah berhasil dikonfirmasi.',
        createdAt: booking.paymentDate ??
            booking.bookingDate ??
            DateTime.now(),
        type: AdminNotificationType.confirmed,
        requiresAction: false,
      );
    }

    return AdminNotification(
      id: 'new-${booking.id}',
      bookingId: booking.id,
      tenantName: tenantName,
      kostName: kostName,
      title: 'Pemesanan Baru',
      message:
          '$tenantName membuat pemesanan untuk $kostName dan belum mengirim pembayaran.',
      createdAt: booking.bookingDate ??
          booking.startDate ??
          DateTime.now(),
      type: AdminNotificationType.newBooking,
      requiresAction: false,
    );
  }
}
