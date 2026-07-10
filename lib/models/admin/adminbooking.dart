class AdminBooking {
  final String id;
  final String userId;
  final String kostId;
  final DateTime? bookingDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final int totalPrice;
  final String bookingStatus;
  final String tenantName;
  final String tenantEmail;
  final String tenantPhone;
  final String? tenantProfileImageUrl;
  final String kostName;
  final String? paymentId;
  final String? paymentMethod;
  final int? paymentAmount;
  final String? paymentProofUrl;
  final DateTime? paymentDate;
  final String? paymentStatus;

  const AdminBooking({
    required this.id,
    required this.userId,
    required this.kostId,
    this.bookingDate,
    this.startDate,
    this.endDate,
    required this.totalPrice,
    required this.bookingStatus,
    required this.tenantName,
    required this.tenantEmail,
    required this.tenantPhone,
    this.tenantProfileImageUrl,
    required this.kostName,
    this.paymentId,
    this.paymentMethod,
    this.paymentAmount,
    this.paymentProofUrl,
    this.paymentDate,
    this.paymentStatus,
  });

  bool get hasPaymentRecord {
    return paymentId?.trim().isNotEmpty == true;
  }

  bool get hasPaymentProof {
    return paymentProofUrl?.trim().isNotEmpty == true;
  }

  bool get isConfirmed {
    final String booking = _normalizeStatus(
      bookingStatus,
    );

    final String payment = _normalizeStatus(
      paymentStatus,
    );

    return booking.contains('confirmed') ||
        booking.contains('dikonfirmasi') ||
        payment.contains('verified') ||
        payment.contains('success') ||
        payment.contains('paid') ||
        payment.contains('dikonfirmasi');
  }

  bool get isCompleted {
    final String booking = _normalizeStatus(
      bookingStatus,
    );

    return booking.contains('completed') ||
        booking.contains('selesai');
  }

  bool get isRejected {
    final String booking = _normalizeStatus(
      bookingStatus,
    );

    final String payment = _normalizeStatus(
      paymentStatus,
    );

    return booking.contains('rejected') ||
        booking.contains('ditolak') ||
        payment.contains('rejected') ||
        payment.contains('failed') ||
        payment.contains('ditolak');
  }

  bool get isCancelled {
    final String booking = _normalizeStatus(
      bookingStatus,
    );

    return booking.contains('cancelled') ||
        booking.contains('canceled') ||
        booking.contains('dibatalkan');
  }

  bool get isWaitingPayment {
    if (isConfirmed ||
        isCompleted ||
        isRejected ||
        isCancelled) {
      return false;
    }

    final String booking = _normalizeStatus(
      bookingStatus,
    );

    final String payment = _normalizeStatus(
      paymentStatus,
    );

    return booking.isEmpty ||
        booking.contains('pending') ||
        booking.contains('menunggu') ||
        booking.contains('waiting') ||
        payment.isEmpty ||
        payment.contains('pending') ||
        payment.contains('menunggu') ||
        payment.contains('waiting');
  }

  bool get canVerifyPayment {
    return hasPaymentRecord &&
        !isConfirmed &&
        !isCompleted &&
        !isRejected &&
        !isCancelled;
  }

  bool get canRejectPayment {
    return hasPaymentRecord &&
        !isConfirmed &&
        !isCompleted &&
        !isRejected &&
        !isCancelled;
  }

  String get statusLabel {
    if (isCompleted) {
      return 'Selesai';
    }

    if (isCancelled) {
      return 'Dibatalkan';
    }

    if (isRejected) {
      return 'Ditolak';
    }

    if (isConfirmed) {
      return 'Dikonfirmasi';
    }

    return 'Menunggu Pembayaran';
  }

  factory AdminBooking.fromMap(
    Map<String, dynamic> map,
  ) {
    final Map<String, dynamic>? user =
        _relationAsMap(
      map['users'] ?? map['user'],
    );

    final Map<String, dynamic>? kost =
        _relationAsMap(
      map['kosts'] ?? map['kost'],
    );

    final Map<String, dynamic>? payment =
        _relationAsMap(
      map['payments'] ?? map['payment'],
      takeLast: true,
    );

    return AdminBooking(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      kostId: map['kost_id']?.toString() ?? '',
      bookingDate: _parseDateTime(
        map['booking_date'],
      ),
      startDate: _parseDateTime(
        map['start_date'],
      ),
      endDate: _parseDateTime(
        map['end_date'],
      ),
      totalPrice: _parseInt(
        map['total_price'],
      ),
      bookingStatus:
          map['status']?.toString() ?? '',
      tenantName:
          user?['full_name']?.toString() ??
              'Penyewa',
      tenantEmail:
          user?['email']?.toString() ?? '',
      tenantPhone:
          user?['phone']?.toString() ?? '',
      tenantProfileImageUrl:
          user?['profile_image_url']?.toString(),
      kostName:
          kost?['nama_kost']?.toString() ??
              'Kost',
      paymentId:
          payment?['id']?.toString(),
      paymentMethod:
          payment?['method']?.toString(),
      paymentAmount: payment == null
          ? null
          : _parseInt(payment['amount']),
      paymentProofUrl:
          payment?['proof_url']?.toString(),
      paymentDate: _parseDateTime(
        payment?['payment_date'],
      ),
      paymentStatus:
          payment?['status']?.toString(),
    );
  }

  AdminBooking copyWith({
    String? id,
    String? userId,
    String? kostId,
    DateTime? bookingDate,
    DateTime? startDate,
    DateTime? endDate,
    int? totalPrice,
    String? bookingStatus,
    String? tenantName,
    String? tenantEmail,
    String? tenantPhone,
    String? tenantProfileImageUrl,
    String? kostName,
    String? paymentId,
    String? paymentMethod,
    int? paymentAmount,
    String? paymentProofUrl,
    DateTime? paymentDate,
    String? paymentStatus,
  }) {
    return AdminBooking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      kostId: kostId ?? this.kostId,
      bookingDate:
          bookingDate ?? this.bookingDate,
      startDate:
          startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalPrice:
          totalPrice ?? this.totalPrice,
      bookingStatus:
          bookingStatus ?? this.bookingStatus,
      tenantName:
          tenantName ?? this.tenantName,
      tenantEmail:
          tenantEmail ?? this.tenantEmail,
      tenantPhone:
          tenantPhone ?? this.tenantPhone,
      tenantProfileImageUrl:
          tenantProfileImageUrl ??
              this.tenantProfileImageUrl,
      kostName: kostName ?? this.kostName,
      paymentId:
          paymentId ?? this.paymentId,
      paymentMethod:
          paymentMethod ?? this.paymentMethod,
      paymentAmount:
          paymentAmount ?? this.paymentAmount,
      paymentProofUrl:
          paymentProofUrl ??
              this.paymentProofUrl,
      paymentDate:
          paymentDate ?? this.paymentDate,
      paymentStatus:
          paymentStatus ?? this.paymentStatus,
    );
  }

  static Map<String, dynamic>? _relationAsMap(
    dynamic value, {
    bool takeLast = false,
  }) {
    if (value is Map) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    if (value is List && value.isNotEmpty) {
      final dynamic selectedItem =
          takeLast ? value.last : value.first;

      if (selectedItem is Map) {
        return Map<String, dynamic>.from(
          selectedItem,
        );
      }
    }

    return null;
  }

  static DateTime? _parseDateTime(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  static int _parseInt(
    dynamic value,
  ) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static String _normalizeStatus(
    String? value,
  ) {
    return (value ?? '')
        .trim()
        .toLowerCase()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');
  }
}