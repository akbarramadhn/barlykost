import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/booking.dart';

class BookingService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<String> getCurrentUserId() async {
    try {
      final authUser = supabase.auth.currentUser;

      if (authUser == null) {
        return '';
      }

      final email = authUser.email?.trim().toLowerCase() ?? '';

      if (email.isEmpty) {
        return '';
      }

      Map<String, dynamic>? response = await supabase
          .from('users')
          .select('id')
          .eq('id', authUser.id)
          .maybeSingle();

      response ??= await supabase
          .from('users')
          .select('id')
          .ilike('email', email)
          .maybeSingle();

      if (response == null) {
        return '';
      }

      return response['id']?.toString() ?? '';
    } catch (error) {
      debugPrint('Get current user id error: $error');
      return '';
    }
  }

  Future<List<BookingModel>> fetchUserBookings() async {
    try {
      final userId = await getCurrentUserId();

      if (userId.trim().isEmpty) {
        return [];
      }

      final response = await supabase
          .from('bookings')
          .select()
          .eq('user_id', userId)
          .order('booking_date', ascending: false);

      return List<Map<String, dynamic>>.from(
        response.map((item) => Map<String, dynamic>.from(item)),
      ).map((item) {
        return BookingModel.fromMap(item);
      }).toList();
    } catch (error) {
      debugPrint('Fetch user bookings error: $error');
      return [];
    }
  }

  Future<List<BookingHistoryModel>> fetchUserBookingHistory() async {
    try {
      final bookings = await fetchUserBookings();
      final List<BookingHistoryModel> result = [];

      for (final booking in bookings) {
        if (booking.kostId.trim().isEmpty) {
          continue;
        }

        final kostResponse = await supabase
            .from('kosts')
            .select('id, nama_kost, lokasi')
            .eq('id', booking.kostId)
            .maybeSingle();

        if (kostResponse == null) {
          continue;
        }

        String imageUrl = '';

        final imageResponse = await supabase
            .from('kost_images')
            .select('image_url')
            .eq('kost_id', booking.kostId)
            .limit(1);

        if (imageResponse.isNotEmpty) {
          imageUrl = imageResponse.first['image_url']?.toString() ?? '';
        }

        result.add(
          BookingHistoryModel(
            booking: booking,
            kostName: kostResponse['nama_kost']?.toString() ?? 'Nama kost',
            kostLocation: kostResponse['lokasi']?.toString() ?? '-',
            kostImageUrl: imageUrl,
          ),
        );
      }

      return result;
    } catch (error) {
      debugPrint('Fetch booking history error: $error');
      return [];
    }
  }

  Future<int> countUserBookings() async {
    try {
      final bookings = await fetchUserBookings();
      return bookings.length;
    } catch (error) {
      debugPrint('Count user bookings error: $error');
      return 0;
    }
  }

  Future<int> countActiveBookings() async {
    try {
      final bookings = await fetchUserBookings();

      return bookings.where((booking) {
        final status = booking.status.toLowerCase().trim();

        return status == 'pending' ||
            status == 'confirmed' ||
            status == 'approved' ||
            status == 'accepted' ||
            status == 'paid' ||
            status == 'lunas' ||
            status == 'aktif';
      }).length;
    } catch (error) {
      debugPrint('Count active bookings error: $error');
      return 0;
    }
  }

  Future<String> fetchActiveKostLocation() async {
    try {
      final bookings = await fetchUserBookings();

      final activeBookings = bookings.where((booking) {
        final status = booking.status.toLowerCase().trim();

        return status == 'pending' ||
            status == 'confirmed' ||
            status == 'approved' ||
            status == 'accepted' ||
            status == 'paid' ||
            status == 'lunas' ||
            status == 'aktif';
      }).toList();

      if (activeBookings.isEmpty) {
        return '-';
      }

      final booking = activeBookings.first;

      if (booking.kostId.trim().isEmpty) {
        return '-';
      }

      final kostResponse = await supabase
          .from('kosts')
          .select('lokasi')
          .eq('id', booking.kostId)
          .maybeSingle();

      if (kostResponse == null) {
        return '-';
      }

      return kostResponse['lokasi']?.toString() ?? '-';
    } catch (error) {
      debugPrint('Fetch active kost location error: $error');
      return '-';
    }
  }

  Future<bool> createBooking({
    required String kostId,
    required String startDate,
    required String endDate,
    required int totalPrice,
  }) async {
    try {
      final userId = await getCurrentUserId();

      if (userId.trim().isEmpty || kostId.trim().isEmpty) {
        return false;
      }

      await supabase.from('bookings').insert({
        'user_id': userId,
        'kost_id': kostId,
        'booking_date': DateTime.now().toIso8601String().split('T').first,
        'start_date': startDate,
        'end_date': endDate,
        'total_price': totalPrice,
        'status': 'pending',
      });

      return true;
    } catch (error) {
      debugPrint('Create booking error: $error');
      return false;
    }
  }
}