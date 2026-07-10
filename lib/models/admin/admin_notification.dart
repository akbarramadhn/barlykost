enum AdminNotificationType {
  paymentVerification,
  newBooking,
  confirmed,
  rejected,
  cancelled,
  completed,
}

class AdminNotification {
  final String id;
  final String bookingId;
  final String tenantName;
  final String kostName;
  final String title;
  final String message;
  final DateTime createdAt;
  final AdminNotificationType type;
  final bool requiresAction;

  const AdminNotification({
    required this.id,
    required this.bookingId,
    required this.tenantName,
    required this.kostName,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.type,
    required this.requiresAction,
  });
}
