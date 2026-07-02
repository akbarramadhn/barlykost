class Payment {
  final String? id;
  final String bookingId;
  final String method;
  final int amount;
  final String? proofUrl;
  final DateTime? paymentDate;
  final String status;

  static const String pending = 'pending';
  static const String verified = 'verified';
  static const String rejected = 'rejected';

  const Payment({
    this.id,
    required this.bookingId,
    required this.method,
    required this.amount,
    this.proofUrl,
    this.paymentDate,
    this.status = pending,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id']?.toString(),
      bookingId: map['booking_id']?.toString() ?? '',
      method: map['method']?.toString() ?? '',
      amount: _parseInt(map['amount']),
      proofUrl: map['proof_url']?.toString(),
      paymentDate: _parseDate(map['payment_date']),
      status: map['status']?.toString() ?? pending,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'booking_id': bookingId,
      'method': method,
      'amount': amount,
      'proof_url': proofUrl,
      'payment_date':
          paymentDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'status': status,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'method': method,
      'amount': amount,
      'proof_url': proofUrl,
      'payment_date': paymentDate?.toIso8601String(),
      'status': status,
    };
  }

  Payment copyWith({
    String? id,
    String? bookingId,
    String? method,
    int? amount,
    String? proofUrl,
    DateTime? paymentDate,
    String? status,
  }) {
    return Payment(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      method: method ?? this.method,
      amount: amount ?? this.amount,
      proofUrl: proofUrl ?? this.proofUrl,
      paymentDate: paymentDate ?? this.paymentDate,
      status: status ?? this.status,
    );
  }

  String get normalizedStatus {
    final value = status.toLowerCase().trim();

    switch (value) {
      case 'pending':
      case 'menunggu':
      case 'menunggu_verifikasi':
      case 'waiting_verification':
        return pending;

      case 'verified':
      case 'approved':
      case 'accepted':
      case 'success':
      case 'paid':
      case 'lunas':
      case 'terverifikasi':
        return verified;

      case 'rejected':
      case 'declined':
      case 'failed':
      case 'ditolak':
        return rejected;

      default:
        return value;
    }
  }

  String get statusLabel {
    switch (normalizedStatus) {
      case pending:
        return 'Menunggu Verifikasi';

      case verified:
        return 'Terverifikasi';

      case rejected:
        return 'Ditolak';

      default:
        return 'Tidak Diketahui';
    }
  }

  bool get isPending {
    return normalizedStatus == pending;
  }

  bool get isVerified {
    return normalizedStatus == verified;
  }

  bool get isRejected {
    return normalizedStatus == rejected;
  }

  bool get canVerify {
    return normalizedStatus == pending;
  }

  bool get canReject {
    return normalizedStatus == pending;
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
}