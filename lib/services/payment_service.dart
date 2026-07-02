import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/booking.dart';
import '../models/payment.dart';

class PaymentService {
  final SupabaseClient _supabase;

  static const String proofBucket = 'payment-proofs';

  PaymentService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  String get currentUserId {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login');
    }

    return user.id;
  }

  Future<String> uploadPaymentProof({
    required String bookingId,
    required File file,
  }) async {
    if (bookingId.trim().isEmpty) {
      throw Exception('ID booking tidak valid');
    }

    final extension = file.path.split('.').last.toLowerCase();
    final fileName =
        '$currentUserId/$bookingId-${DateTime.now().millisecondsSinceEpoch}.$extension';

    await _supabase.storage.from(proofBucket).upload(
          fileName,
          file,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true,
          ),
        );

    return _supabase.storage.from(proofBucket).getPublicUrl(fileName);
  }

  Future<Payment> createPayment({
    required Booking booking,
    required String method,
    required String proofUrl,
  }) async {
    final bookingId = booking.id;

    if (bookingId == null || bookingId.isEmpty) {
      throw Exception('ID booking tidak valid');
    }

    if (method.trim().isEmpty) {
      throw Exception('Metode pembayaran wajib dipilih');
    }

    if (proofUrl.trim().isEmpty) {
      throw Exception('Bukti pembayaran wajib diunggah');
    }

    if (booking.totalPrice <= 0) {
      throw Exception('Total pembayaran tidak valid');
    }

    final existingPayments = await _supabase
        .from('payments')
        .select('id, status')
        .eq('booking_id', bookingId)
        .neq('status', Payment.rejected)
        .limit(1);

    if (existingPayments.isNotEmpty) {
      throw Exception('Pembayaran untuk pemesanan ini sudah dibuat');
    }

    final payment = Payment(
      bookingId: bookingId,
      method: method.trim(),
      amount: booking.totalPrice,
      proofUrl: proofUrl,
      paymentDate: DateTime.now(),
      status: Payment.pending,
    );

    final data = await _supabase
        .from('payments')
        .insert(payment.toInsertMap())
        .select()
        .single();

    await _supabase
        .from('bookings')
        .update({
          'status': Booking.waitingVerification,
        })
        .eq('id', bookingId)
        .eq('user_id', currentUserId);

    return Payment.fromMap(
      Map<String, dynamic>.from(data),
    );
  }

  Future<Payment?> getPaymentByBookingId(String bookingId) async {
    if (bookingId.trim().isEmpty) {
      throw Exception('ID booking tidak valid');
    }

    final data = await _supabase
        .from('payments')
        .select()
        .eq('booking_id', bookingId)
        .order('payment_date', ascending: false)
        .limit(1)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return Payment.fromMap(
      Map<String, dynamic>.from(data),
    );
  }

  Future<void> verifyPayment({
    required String paymentId,
    required String bookingId,
  }) async {
    if (paymentId.trim().isEmpty) {
      throw Exception('ID pembayaran tidak valid');
    }

    if (bookingId.trim().isEmpty) {
      throw Exception('ID booking tidak valid');
    }

    await _supabase
        .from('payments')
        .update({
          'status': Payment.verified,
        })
        .eq('id', paymentId);

    await _supabase
        .from('bookings')
        .update({
          'status': Booking.confirmed,
        })
        .eq('id', bookingId);
  }

  Future<void> rejectPayment({
    required String paymentId,
    required String bookingId,
  }) async {
    if (paymentId.trim().isEmpty) {
      throw Exception('ID pembayaran tidak valid');
    }

    if (bookingId.trim().isEmpty) {
      throw Exception('ID booking tidak valid');
    }

    await _supabase
        .from('payments')
        .update({
          'status': Payment.rejected,
        })
        .eq('id', paymentId);

    await _supabase
        .from('bookings')
        .update({
          'status': Booking.rejected,
        })
        .eq('id', bookingId);
  }
}