import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/booking.dart';

class BookingService {
  final SupabaseClient _supabase;

  static const String _bookingWithKostSelect = '''
    id,
    user_id,
    kost_id,
    booking_date,
    start_date,
    end_date,
    total_price,
    status,
    kost:kosts (
      nama_kost,
      lokasi,
      harga,
      images:kost_images (
        image_url
      )
    )
  ''';

  BookingService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  String get currentUserId {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login');
    }

    return user.id;
  }

  Future<Booking> createBooking({
    required String kostId,
    required DateTime startDate,
  }) async {
    final userId = currentUserId;

    final kostData =
        await _supabase
            .from('kosts')
            .select('id, harga, tersedia')
            .eq('id', kostId)
            .maybeSingle();

    if (kostData == null) {
      throw Exception('Data kost tidak ditemukan');
    }

    final tersedia = _parseInt(kostData['tersedia']);
    final harga = _parseInt(kostData['harga']);

    if (tersedia <= 0) {
      throw Exception('Kamar kost sudah tidak tersedia');
    }

    if (harga <= 0) {
      throw Exception('Harga kost tidak valid');
    }

    final existingBookings = await _supabase
        .from('bookings')
        .select('id')
        .eq('user_id', userId)
        .eq('kost_id', kostId)
        .inFilter('status', [
          Booking.pendingPayment,
          Booking.waitingVerification,
          Booking.confirmed,
        ])
        .limit(1);

    if (existingBookings.isNotEmpty) {
      throw Exception(
        'Kamu masih memiliki pemesanan aktif pada kost ini',
      );
    }

    final platformFee = Booking.calculatePlatformFee(harga);
    final totalPrice = harga + platformFee;

    final booking = Booking(
      userId: userId,
      kostId: kostId,
      startDate: startDate,
      endDate: Booking.calculateEndDate(startDate),
      kostPrice: harga,
      totalPrice: totalPrice,
      status: Booking.pendingPayment,
    );

    final data =
        await _supabase
            .from('bookings')
            .insert(booking.toInsertMap())
            .select(_bookingWithKostSelect)
            .single();

    return Booking.fromMap(
      Map<String, dynamic>.from(data),
    );
  }

  Future<List<Booking>> getCurrentUserBookings() async {
    final data = await _supabase
        .from('bookings')
        .select(_bookingWithKostSelect)
        .eq('user_id', currentUserId)
        .order('booking_date', ascending: false);

    return data.map((item) {
      return Booking.fromMap(
        Map<String, dynamic>.from(item),
      );
    }).toList();
  }

  Future<Booking?> getBookingById(String bookingId) async {
    final data =
        await _supabase
            .from('bookings')
            .select(_bookingWithKostSelect)
            .eq('id', bookingId)
            .eq('user_id', currentUserId)
            .maybeSingle();

    if (data == null) {
      return null;
    }

    return Booking.fromMap(
      Map<String, dynamic>.from(data),
    );
  }

  Future<bool> hasActiveBooking(String kostId) async {
    final data = await _supabase
        .from('bookings')
        .select('id')
        .eq('user_id', currentUserId)
        .eq('kost_id', kostId)
        .inFilter('status', [
          Booking.pendingPayment,
          Booking.waitingVerification,
          Booking.confirmed,
        ])
        .limit(1);

    return data.isNotEmpty;
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    const allowedStatuses = [
      Booking.pendingPayment,
      Booking.waitingVerification,
      Booking.confirmed,
      Booking.rejected,
      Booking.cancelled,
      Booking.completed,
    ];

    if (!allowedStatuses.contains(status)) {
      throw Exception('Status booking tidak valid');
    }

    await _supabase
        .from('bookings')
        .update({
          'status': status,
        })
        .eq('id', bookingId);
  }

  Future<void> cancelBooking(String bookingId) async {
    await _supabase
        .from('bookings')
        .update({
          'status': Booking.cancelled,
        })
        .eq('id', bookingId)
        .eq('user_id', currentUserId)
        .eq('status', Booking.pendingPayment);
  }

  Future<int> getAvailableRooms(String kostId) async {
    final data =
        await _supabase
            .from('kosts')
            .select('tersedia')
            .eq('id', kostId)
            .maybeSingle();

    if (data == null) {
      throw Exception('Data kost tidak ditemukan');
    }

    return _parseInt(data['tersedia']);
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