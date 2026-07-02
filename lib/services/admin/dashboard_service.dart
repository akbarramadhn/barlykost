import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/admin/dashboard.dart';

class AdminDashboardService {
  final SupabaseClient _supabase;

  AdminDashboardService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<AdminDashboardData> getDashboardData() async {
    final adminProfile = await fetchAdminProfile();
    final users = await fetchUsers();
    final kosts = await fetchKosts();
    final payments = await fetchPayments();

    final usersById = {
      for (final user in users) user.id: user,
    };

    final kostsById = {
      for (final kost in kosts) kost.id: kost,
    };

    final bookings = await fetchBookings(
      usersById: usersById,
      kostsById: kostsById,
    );

    final now = DateTime.now();

    final totalUser = users.where((user) {
      return user.role.toLowerCase().trim() == 'penyewa';
    }).length;

    final totalKost = kosts.length;

    final totalPesananBulanIni = bookings.where((booking) {
      return _isSameMonth(booking.bookingDate, now);
    }).length;

    final totalPendapatanBulanIni = payments.where((payment) {
      return payment.isVerified && _isSameMonth(payment.paymentDate, now);
    }).fold<int>(0, (previous, payment) {
      return previous + payment.amount;
    });

    return AdminDashboardData(
      adminName: adminProfile.name,
      adminEmail: adminProfile.email,
      totalKost: totalKost,
      totalPesanan: totalPesananBulanIni,
      totalUser: totalUser,
      totalPendapatanBulanIni: totalPendapatanBulanIni,
      latestBookings: bookings.take(3).toList(),
    );
  }

  Future<AdminProfileSummary> fetchAdminProfile() async {
    final authUser = _supabase.auth.currentUser;

    if (authUser == null) {
      return AdminProfileSummary.empty();
    }

    final email = authUser.email ?? '';

    try {
      final response = await _supabase
          .from('users')
          .select('id, full_name, email, role')
          .eq('id', authUser.id)
          .maybeSingle();

      if (response == null) {
        return AdminProfileSummary(
          name: _getNameFromAuth(authUser),
          email: email,
        );
      }

      return AdminProfileSummary(
        name: response['full_name']?.toString() ?? _getNameFromAuth(authUser),
        email: response['email']?.toString() ?? email,
      );
    } catch (_) {
      return AdminProfileSummary(
        name: _getNameFromAuth(authUser),
        email: email,
      );
    }
  }

  Future<List<AdminUserSummary>> fetchUsers() async {
    final response = await _supabase
        .from('users')
        .select('id, role, email, phone, full_name, created_at')
        .order('created_at', ascending: false);

    final data = response as List<dynamic>;

    return data.map((item) {
      final row = Map<String, dynamic>.from(item as Map);
      return AdminUserSummary.fromMap(row);
    }).toList();
  }

  Future<List<AdminKostSummary>> fetchKosts() async {
    final response = await _supabase
        .from('kosts')
        .select(
          'id, harga, lokasi, rating, owner_id, tersedia, deskripsi, nama_kost, created_at',
        )
        .order('created_at', ascending: false);

    final data = response as List<dynamic>;

    return data.map((item) {
      final row = Map<String, dynamic>.from(item as Map);
      return AdminKostSummary.fromMap(row);
    }).toList();
  }

  Future<List<AdminBookingSummary>> fetchBookings({
    required Map<String, AdminUserSummary> usersById,
    required Map<String, AdminKostSummary> kostsById,
  }) async {
    final response = await _supabase
        .from('bookings')
        .select(
          'id, user_id, kost_id, booking_date, start_date, end_date, total_price, status',
        )
        .order('booking_date', ascending: false);

    final data = response as List<dynamic>;

    final bookings = data.map((item) {
      final row = Map<String, dynamic>.from(item as Map);

      return AdminBookingSummary.fromMap(
        row,
        user: usersById[row['user_id']?.toString() ?? ''],
        kost: kostsById[row['kost_id']?.toString() ?? ''],
      );
    }).toList();

    bookings.sort((a, b) {
      return b.bookingDate.compareTo(a.bookingDate);
    });

    return bookings;
  }

  Future<List<AdminPaymentSummary>> fetchPayments() async {
    final response = await _supabase
        .from('payments')
        .select('id, amount, payment_date, status')
        .order('payment_date', ascending: false);

    final data = response as List<dynamic>;

    return data.map((item) {
      final row = Map<String, dynamic>.from(item as Map);
      return AdminPaymentSummary.fromMap(row);
    }).toList();
  }

  bool _isSameMonth(DateTime date, DateTime now) {
    if (date.millisecondsSinceEpoch == 0) {
      return false;
    }

    return date.year == now.year && date.month == now.month;
  }

  String _getNameFromAuth(User user) {
    final metadata = user.userMetadata;

    final nameFromMetadata = metadata?['full_name'] ??
        metadata?['name'] ??
        metadata?['nama'] ??
        metadata?['username'];

    if (nameFromMetadata != null &&
        nameFromMetadata.toString().trim().isNotEmpty) {
      return nameFromMetadata.toString().trim();
    }

    final email = user.email ?? '';

    if (email.contains('@')) {
      final nameFromEmail = email.split('@').first.replaceAll('.', ' ');
      return _capitalizeName(nameFromEmail);
    }

    return 'Admin';
  }

  String _capitalizeName(String value) {
    return value
        .split(' ')
        .where((word) => word.trim().isNotEmpty)
        .map((word) {
      final cleanWord = word.trim();

      if (cleanWord.length == 1) {
        return cleanWord.toUpperCase();
      }

      return cleanWord[0].toUpperCase() + cleanWord.substring(1).toLowerCase();
    }).join(' ');
  }
}