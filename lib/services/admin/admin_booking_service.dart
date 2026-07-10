import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/admin/adminbooking.dart';

class AdminBookingService {
  final SupabaseClient _supabase;

  AdminBookingService({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  static const String _bookingSelect = '''
    id,
    user_id,
    kost_id,
    booking_date,
    start_date,
    end_date,
    total_price,
    status,
    users (
      full_name,
      email,
      phone,
      profile_image_url
    ),
    kosts (
      nama_kost
    ),
    payments (
      id,
      method,
      amount,
      proof_url,
      payment_date,
      status
    )
  ''';

  Future<List<AdminBooking>> getAllBookings() async {
    try {
      final List<dynamic> response = await _supabase
          .from('bookings')
          .select(_bookingSelect)
          .order('booking_date', ascending: false);

      return _mapBookings(response);
    } on PostgrestException catch (error) {
      throw AdminBookingServiceException(
        'Gagal mengambil data pemesanan: ${error.message}',
      );
    } catch (error) {
      throw AdminBookingServiceException(
        'Terjadi kesalahan saat mengambil data pemesanan: $error',
      );
    }
  }

  Future<List<AdminBooking>> getLatestBookings({int limit = 2}) async {
    try {
      final List<dynamic> response = await _supabase
          .from('bookings')
          .select(_bookingSelect)
          .order('booking_date', ascending: false)
          .limit(limit);

      return _mapBookings(response);
    } on PostgrestException catch (error) {
      throw AdminBookingServiceException(
        'Gagal mengambil pemesanan terbaru: ${error.message}',
      );
    } catch (error) {
      throw AdminBookingServiceException(
        'Terjadi kesalahan saat mengambil pemesanan terbaru: $error',
      );
    }
  }

  Future<AdminBooking> getBookingById(String bookingId) async {
    if (bookingId.trim().isEmpty) {
      throw const AdminBookingServiceException('ID pemesanan tidak valid.');
    }

    try {
      final Map<String, dynamic> response = await _supabase
          .from('bookings')
          .select(_bookingSelect)
          .eq('id', bookingId)
          .single();

      return AdminBooking.fromMap(response);
    } on PostgrestException catch (error) {
      throw AdminBookingServiceException(
        'Gagal mengambil detail pemesanan: ${error.message}',
      );
    } catch (error) {
      throw AdminBookingServiceException(
        'Terjadi kesalahan saat mengambil detail pemesanan: $error',
      );
    }
  }

  Future<void> verifyPayment(AdminBooking booking) async {
    final String bookingId = booking.id.trim();
    final String paymentId = booking.paymentId?.trim() ?? '';

    if (bookingId.isEmpty) {
      throw const AdminBookingServiceException('ID pemesanan tidak ditemukan.');
    }

    if (paymentId.isEmpty) {
      throw const AdminBookingServiceException(
        'Data pembayaran tidak ditemukan.',
      );
    }

    try {
      await _supabase.rpc(
        'verify_booking_payment',
        params: {'p_booking_id': bookingId, 'p_payment_id': paymentId},
      );
    } on PostgrestException catch (error) {
      throw AdminBookingServiceException(error.message);
    } catch (error) {
      throw AdminBookingServiceException(
        'Terjadi kesalahan saat memverifikasi pembayaran: $error',
      );
    }
  }

  Future<void> rejectPayment(AdminBooking booking) async {
    final String bookingId = booking.id.trim();
    final String paymentId = booking.paymentId?.trim() ?? '';

    if (bookingId.isEmpty) {
      throw const AdminBookingServiceException('ID pemesanan tidak ditemukan.');
    }

    if (paymentId.isEmpty) {
      throw const AdminBookingServiceException(
        'Data pembayaran tidak ditemukan.',
      );
    }

    try {
      await _supabase
          .from('payments')
          .update({'status': 'rejected'})
          .eq('id', paymentId);

      await _supabase
          .from('bookings')
          .update({'status': 'rejected'})
          .eq('id', bookingId);
    } on PostgrestException catch (error) {
      throw AdminBookingServiceException(
        'Gagal menolak pembayaran: ${error.message}',
      );
    } catch (error) {
      throw AdminBookingServiceException(
        'Terjadi kesalahan saat menolak pembayaran: $error',
      );
    }
  }

  List<AdminBooking> _mapBookings(List<dynamic> response) {
    return response.map<AdminBooking>((dynamic item) {
      if (item is! Map) {
        throw const AdminBookingServiceException(
          'Format data pemesanan tidak valid.',
        );
      }

      return AdminBooking.fromMap(Map<String, dynamic>.from(item));
    }).toList();
  }
}

class AdminBookingServiceException implements Exception {
  final String message;

  const AdminBookingServiceException(this.message);

  @override
  String toString() {
    return message;
  }
}
