enum AppNotificationType {
  pendingPayment,
  waitingVerification,
  confirmed,
  rejected,
  cancelled,
  completed,
  review,
}

class AppNotification {
  final String id;
  final String bookingId;
  final String kostId;
  final String kostName;
  final String title;
  final String message;
  final DateTime createdAt;
  final AppNotificationType type;
  final bool requiresAction;

  const AppNotification({
    required this.id,
    required this.bookingId,
    required this.kostId,
    required this.kostName,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.type,
    required this.requiresAction,
  });
}
