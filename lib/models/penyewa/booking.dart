class Booking {
  final String? id;
  final String userId;
  final String kostId;
  final DateTime? bookingDate;
  final DateTime startDate;
  final DateTime endDate;
  final int kostPrice;
  final int totalPrice;
  final String status;
  final String kostName;
  final String kostLocation;
  final String kostImageUrl;

  static const int platformFeePercentage = 2;

  static const String pendingPayment = 'pending_payment';
  static const String waitingVerification = 'waiting_verification';
  static const String confirmed = 'confirmed';
  static const String rejected = 'rejected';
  static const String cancelled = 'cancelled';
  static const String completed = 'completed';

  const Booking({
    this.id,
    required this.userId,
    required this.kostId,
    this.bookingDate,
    required this.startDate,
    required this.endDate,
    required this.kostPrice,
    required this.totalPrice,
    this.status = pendingPayment,
    this.kostName = '',
    this.kostLocation = '',
    this.kostImageUrl = '',
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    final kostData = _parseMap(map['kost'] ?? map['kosts']);
    final imageData = _parseList(
      kostData['images'] ?? kostData['kost_images'],
    );

    String imageUrl = '';

    if (imageData.isNotEmpty) {
      final firstImage = _parseMap(imageData.first);
      imageUrl = firstImage['image_url']?.toString() ?? '';
    }

    final parsedKostPrice = _parseInt(
      kostData['harga'] ?? map['kost_price'],
    );

    final parsedTotalPrice = _parseInt(map['total_price']);

    return Booking(
      id: map['id']?.toString(),
      userId: map['user_id']?.toString() ?? '',
      kostId: map['kost_id']?.toString() ?? '',
      bookingDate: _parseDate(map['booking_date']),
      startDate: _parseDate(map['start_date']) ?? DateTime.now(),
      endDate: _parseDate(map['end_date']) ?? DateTime.now(),
      kostPrice: parsedKostPrice,
      totalPrice: parsedTotalPrice,
      status: map['status']?.toString() ?? pendingPayment,
      kostName:
          kostData['nama_kost']?.toString() ??
          map['kost_name']?.toString() ??
          '',
      kostLocation:
          kostData['lokasi']?.toString() ??
          map['kost_location']?.toString() ??
          '',
      kostImageUrl:
          imageUrl.isNotEmpty
              ? imageUrl
              : map['kost_image_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'user_id': userId,
      'kost_id': kostId,
      'start_date': _formatDate(startDate),
      'end_date': _formatDate(endDate),
      'total_price': totalPrice,
      'status': status,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'kost_id': kostId,
      'booking_date':
          bookingDate == null
              ? null
              : bookingDate!.toIso8601String(),
      'start_date': _formatDate(startDate),
      'end_date': _formatDate(endDate),
      'kost_price': kostPrice,
      'total_price': totalPrice,
      'status': status,
      'kost_name': kostName,
      'kost_location': kostLocation,
      'kost_image_url': kostImageUrl,
    };
  }

  Booking copyWith({
    String? id,
    String? userId,
    String? kostId,
    DateTime? bookingDate,
    DateTime? startDate,
    DateTime? endDate,
    int? kostPrice,
    int? totalPrice,
    String? status,
    String? kostName,
    String? kostLocation,
    String? kostImageUrl,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      kostId: kostId ?? this.kostId,
      bookingDate: bookingDate ?? this.bookingDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      kostPrice: kostPrice ?? this.kostPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      kostName: kostName ?? this.kostName,
      kostLocation: kostLocation ?? this.kostLocation,
      kostImageUrl: kostImageUrl ?? this.kostImageUrl,
    );
  }

  int get platformFee {
    return calculatePlatformFee(kostPrice);
  }

  static int calculatePlatformFee(int price) {
    return (price * platformFeePercentage / 100).round();
  }

  static int calculateTotalPrice(int price) {
    return price + calculatePlatformFee(price);
  }

  static DateTime calculateEndDate(DateTime startDate) {
    final nextMonth = DateTime(
      startDate.year,
      startDate.month + 1,
      1,
    );

    final lastDayOfNextMonth = DateTime(
      nextMonth.year,
      nextMonth.month + 1,
      0,
    ).day;

    final safeDay =
        startDate.day > lastDayOfNextMonth
            ? lastDayOfNextMonth
            : startDate.day;

    return DateTime(
      nextMonth.year,
      nextMonth.month,
      safeDay,
    );
  }

  String get normalizedStatus {
    final value = status.toLowerCase().trim();

    switch (value) {
      case 'pending':
      case 'menunggu':
      case 'pending_payment':
        return pendingPayment;

      case 'waiting_verification':
      case 'menunggu_verifikasi':
        return waitingVerification;

      case 'approved':
      case 'accepted':
      case 'confirmed':
      case 'paid':
      case 'lunas':
        return confirmed;

      case 'success':
      case 'selesai':
      case 'completed':
        return completed;

      case 'rejected':
      case 'ditolak':
        return rejected;

      case 'cancelled':
      case 'canceled':
      case 'batal':
      case 'dibatalkan':
        return cancelled;

      default:
        return value;
    }
  }

  String get statusLabel {
    switch (normalizedStatus) {
      case pendingPayment:
        return 'Menunggu Pembayaran';

      case waitingVerification:
        return 'Menunggu Verifikasi';

      case confirmed:
        return 'Dikonfirmasi';

      case completed:
        return 'Selesai';

      case rejected:
        return 'Ditolak';

      case cancelled:
        return 'Dibatalkan';

      default:
        return 'Tidak Diketahui';
    }
  }

  bool get canPay {
    return normalizedStatus == pendingPayment;
  }

  bool get canReview {
    return normalizedStatus == completed;
  }

  bool get isWaitingVerification {
    return normalizedStatus == waitingVerification;
  }

  bool get isConfirmed {
    return normalizedStatus == confirmed;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value.toString());
  }

  static int _parseInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  static Map<String, dynamic> _parseMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  static List<dynamic> _parseList(dynamic value) {
    if (value is List) {
      return value;
    }

    return [];
  }

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}