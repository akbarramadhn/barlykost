class Review {
  final String? id;
  final String bookingId;
  final String userId;
  final String kostId;
  final int rating;
  final String? comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Review({
    this.id,
    required this.bookingId,
    required this.userId,
    required this.kostId,
    required this.rating,
    this.comment,
    this.createdAt,
    this.updatedAt,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id']?.toString(),
      bookingId: map['booking_id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      kostId: map['kost_id']?.toString() ?? '',
      rating: _parseInt(map['rating']),
      comment: map['comment']?.toString(),
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'booking_id': bookingId,
      'user_id': userId,
      'kost_id': kostId,
      'rating': rating,
      'comment': comment?.trim().isEmpty == true
          ? null
          : comment?.trim(),
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

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value.toString());
  }
}
