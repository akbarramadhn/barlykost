class PaymentModel {
  final String id;
  final String bookingId;
  final int amount;
  final String method;
  final String status;
  final String proofUrl;
  final String createdAt;

  const PaymentModel({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.method,
    required this.status,
    required this.proofUrl,
    required this.createdAt,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id']?.toString() ?? '',
      bookingId: map['booking_id']?.toString() ?? '',
      amount: _parseInt(
        map['amount'] ??
            map['total'] ??
            map['nominal'] ??
            map['jumlah_bayar'],
      ),
      method: map['method']?.toString() ??
          map['payment_method']?.toString() ??
          map['metode_pembayaran']?.toString() ??
          '',
      status: map['status']?.toString() ?? 'pending',
      proofUrl: map['proof_url']?.toString() ??
          map['bukti_pembayaran']?.toString() ??
          map['payment_proof']?.toString() ??
          '',
      createdAt: map['created_at']?.toString() ?? '',
    );
  }

  factory PaymentModel.empty() {
    return const PaymentModel(
      id: '',
      bookingId: '',
      amount: 0,
      method: '',
      status: 'pending',
      proofUrl: '',
      createdAt: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'booking_id': bookingId,
      'amount': amount,
      'method': method,
      'status': status,
      'proof_url': proofUrl,
      'created_at': createdAt,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}