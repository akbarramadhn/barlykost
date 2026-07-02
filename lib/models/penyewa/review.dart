class ReviewModel {
  final String id;
  final String userId;
  final String kostId;
  final double rating;
  final String comment;
  final String createdAt;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.kostId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ??
          map['penyewa_id']?.toString() ??
          '',
      kostId: map['kost_id']?.toString() ?? '',
      rating: _parseDouble(map['rating']),
      comment: map['comment']?.toString() ??
          map['komentar']?.toString() ??
          map['review']?.toString() ??
          '',
      createdAt: map['created_at']?.toString() ?? '',
    );
  }

  factory ReviewModel.empty() {
    return const ReviewModel(
      id: '',
      userId: '',
      kostId: '',
      rating: 0,
      comment: '',
      createdAt: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'kost_id': kostId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}