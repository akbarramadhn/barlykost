class BookingModel {
  final String id;
  final String userId;
  final String kostId;
  final String bookingDate;
  final String startDate;
  final String endDate;
  final int totalPrice;
  final String status;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.kostId,
    required this.bookingDate,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      kostId: map['kost_id']?.toString() ?? '',
      bookingDate: map['booking_date']?.toString() ?? '',
      startDate: map['start_date']?.toString() ?? '',
      endDate: map['end_date']?.toString() ?? '',
      totalPrice: _parseInt(map['total_price']),
      status: map['status']?.toString() ?? 'pending',
    );
  }

  factory BookingModel.empty() {
    return const BookingModel(
      id: '',
      userId: '',
      kostId: '',
      bookingDate: '',
      startDate: '',
      endDate: '',
      totalPrice: 0,
      status: 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'kost_id': kostId,
      'booking_date': bookingDate,
      'start_date': startDate,
      'end_date': endDate,
      'total_price': totalPrice,
      'status': status,
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

class BookingHistoryModel {
  final BookingModel booking;
  final String kostName;
  final String kostLocation;
  final String kostImageUrl;

  const BookingHistoryModel({
    required this.booking,
    required this.kostName,
    required this.kostLocation,
    required this.kostImageUrl,
  });

  factory BookingHistoryModel.empty() {
    return BookingHistoryModel(
      booking: BookingModel.empty(),
      kostName: '',
      kostLocation: '',
      kostImageUrl: '',
    );
  }

  String get id => booking.id;

  String get kostId => booking.kostId;

  String get status => booking.status;

  String get startDate => booking.startDate;

  String get endDate => booking.endDate;

  int get totalPrice => booking.totalPrice;
}