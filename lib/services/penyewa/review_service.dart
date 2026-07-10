import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/penyewa/booking.dart';
import '../../models/penyewa/review.dart';

class ReviewService {
  final SupabaseClient _supabase;

  ReviewService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  String get currentUserId {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const ReviewServiceException('Pengguna belum login.');
    }

    return user.id;
  }

  Future<Set<String>> getReviewedBookingIds() async {
    try {
      final data = await _supabase
          .from('reviews')
          .select('booking_id')
          .eq('user_id', currentUserId);

      final Set<String> bookingIds = <String>{};

      for (final item in data) {
        final String bookingId = item['booking_id']?.toString() ?? '';

        if (bookingId.isNotEmpty) {
          bookingIds.add(bookingId);
        }
      }

      return bookingIds;
    } on PostgrestException catch (error) {
      throw ReviewServiceException(
        'Gagal mengambil data ulasan: ${error.message}',
      );
    } catch (error) {
      if (error is ReviewServiceException) {
        rethrow;
      }

      throw ReviewServiceException(
        'Terjadi kesalahan saat mengambil ulasan: $error',
      );
    }
  }

  Future<bool> hasReviewed(String bookingId) async {
    try {
      final data = await _supabase
          .from('reviews')
          .select('id')
          .eq('booking_id', bookingId)
          .eq('user_id', currentUserId)
          .maybeSingle();

      return data != null;
    } on PostgrestException catch (error) {
      throw ReviewServiceException('Gagal memeriksa ulasan: ${error.message}');
    } catch (error) {
      if (error is ReviewServiceException) {
        rethrow;
      }

      throw ReviewServiceException(
        'Terjadi kesalahan saat memeriksa ulasan: $error',
      );
    }
  }

  Future<Review> createReview({
    required String bookingId,
    required String kostId,
    required int rating,
    required String comment,
  }) async {
    if (rating < 1 || rating > 5) {
      throw const ReviewServiceException(
        'Rating harus berada antara 1 sampai 5.',
      );
    }

    try {
      final bookingData = await _supabase
          .from('bookings')
          .select('id, user_id, kost_id, status')
          .eq('id', bookingId)
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (bookingData == null) {
        throw const ReviewServiceException('Data pemesanan tidak ditemukan.');
      }

      final String bookingStatus =
          bookingData['status']?.toString().toLowerCase() ?? '';

      final bool canReview =
          bookingStatus == Booking.confirmed ||
          bookingStatus == Booking.completed;

      if (!canReview) {
        throw const ReviewServiceException(
          'Ulasan hanya dapat dibuat setelah pemesanan dikonfirmasi.',
        );
      }

      if (bookingData['kost_id']?.toString() != kostId) {
        throw const ReviewServiceException(
          'Data kost tidak sesuai dengan pemesanan.',
        );
      }

      if (await hasReviewed(bookingId)) {
        throw const ReviewServiceException(
          'Pemesanan ini sudah pernah diberi ulasan.',
        );
      }

      final review = Review(
        bookingId: bookingId,
        userId: currentUserId,
        kostId: kostId,
        rating: rating,
        comment: comment,
      );

      final data = await _supabase
          .from('reviews')
          .insert(review.toInsertMap())
          .select()
          .single();

      return Review.fromMap(Map<String, dynamic>.from(data));
    } on ReviewServiceException {
      rethrow;
    } on PostgrestException catch (error) {
      if (error.code == '23505') {
        throw const ReviewServiceException(
          'Pemesanan ini sudah pernah diberi ulasan.',
        );
      }

      throw ReviewServiceException('Gagal menyimpan ulasan: ${error.message}');
    } catch (error) {
      throw ReviewServiceException(
        'Terjadi kesalahan saat menyimpan ulasan: $error',
      );
    }
  }

  Future<List<Review>> getReviewsByKost(String kostId) async {
    try {
      final data = await _supabase
          .from('reviews')
          .select()
          .eq('kost_id', kostId)
          .order('created_at', ascending: false);

      return data.map<Review>((item) {
        return Review.fromMap(Map<String, dynamic>.from(item));
      }).toList();
    } on PostgrestException catch (error) {
      throw ReviewServiceException(
        'Gagal mengambil ulasan kost: ${error.message}',
      );
    } catch (error) {
      throw ReviewServiceException(
        'Terjadi kesalahan saat mengambil ulasan kost: $error',
      );
    }
  }
}

class ReviewServiceException implements Exception {
  final String message;

  const ReviewServiceException(this.message);

  @override
  String toString() => message;
}
