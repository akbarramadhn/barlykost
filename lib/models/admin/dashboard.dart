import 'package:flutter/material.dart';

class AdminDashboardData {
  final String adminName;
  final String adminEmail;
  final int totalKost;
  final int totalPesanan;
  final int totalUser;
  final int totalPendapatanBulanIni;
  final List<AdminBookingSummary> latestBookings;

  const AdminDashboardData({
    required this.adminName,
    required this.adminEmail,
    required this.totalKost,
    required this.totalPesanan,
    required this.totalUser,
    required this.totalPendapatanBulanIni,
    required this.latestBookings,
  });

  factory AdminDashboardData.empty() {
    return const AdminDashboardData(
      adminName: 'Admin',
      adminEmail: '',
      totalKost: 0,
      totalPesanan: 0,
      totalUser: 0,
      totalPendapatanBulanIni: 0,
      latestBookings: [],
    );
  }
}

class AdminStatisticSummary {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;

  const AdminStatisticSummary({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
  });
}

class AdminProfileSummary {
  final String name;
  final String email;

  const AdminProfileSummary({
    required this.name,
    required this.email,
  });

  factory AdminProfileSummary.empty() {
    return const AdminProfileSummary(
      name: 'Admin',
      email: '',
    );
  }
}

class AdminUserSummary {
  final String id;
  final String role;
  final String email;
  final String phone;
  final String fullName;

  const AdminUserSummary({
    required this.id,
    required this.role,
    required this.email,
    required this.phone,
    required this.fullName,
  });

  factory AdminUserSummary.fromMap(Map<String, dynamic> map) {
    return AdminUserSummary(
      id: map['id']?.toString() ?? '',
      role: map['role']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      fullName: map['full_name']?.toString() ?? '',
    );
  }
}

class AdminKostSummary {
  final String id;
  final String name;
  final String location;
  final int price;
  final double rating;
  final int available;
  final String description;

  const AdminKostSummary({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.available,
    required this.description,
  });

  factory AdminKostSummary.fromMap(Map<String, dynamic> map) {
    return AdminKostSummary(
      id: map['id']?.toString() ?? '',
      name: map['nama_kost']?.toString() ?? 'Nama kost belum tersedia',
      location: map['lokasi']?.toString() ?? 'Lokasi belum tersedia',
      price: _parseInt(map['harga']),
      rating: _parseDouble(map['rating']),
      available: _parseInt(map['tersedia']),
      description: map['deskripsi']?.toString() ?? '',
    );
  }
}

class AdminBookingSummary {
  final String id;
  final String userId;
  final String kostId;
  final String userName;
  final String kostName;
  final String status;
  final DateTime bookingDate;
  final String bookingDateText;
  final int totalPrice;

  const AdminBookingSummary({
    required this.id,
    required this.userId,
    required this.kostId,
    required this.userName,
    required this.kostName,
    required this.status,
    required this.bookingDate,
    required this.bookingDateText,
    required this.totalPrice,
  });

  factory AdminBookingSummary.fromMap(
    Map<String, dynamic> map, {
    AdminUserSummary? user,
    AdminKostSummary? kost,
  }) {
    final bookingDate = _parseDate(map['booking_date']);

    return AdminBookingSummary(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      kostId: map['kost_id']?.toString() ?? '',
      userName:
          user?.fullName.trim().isNotEmpty == true ? user!.fullName : 'Penyewa',
      kostName: kost?.name.trim().isNotEmpty == true ? kost!.name : 'Kost',
      status: map['status']?.toString() ?? '',
      bookingDate: bookingDate,
      bookingDateText: formatDate(bookingDate),
      totalPrice: _parseInt(map['total_price']),
    );
  }

  String get normalizedStatus {
    final value = status.toLowerCase().trim();

    switch (value) {
      case 'pending_payment':
      case 'pending':
      case 'menunggu':
        return 'pending_payment';
      case 'waiting_verification':
      case 'menunggu_verifikasi':
        return 'waiting_verification';
      case 'confirmed':
      case 'approved':
      case 'paid':
      case 'lunas':
        return 'confirmed';
      case 'completed':
      case 'success':
      case 'selesai':
        return 'completed';
      case 'rejected':
      case 'ditolak':
        return 'rejected';
      case 'cancelled':
      case 'canceled':
      case 'batal':
      case 'dibatalkan':
        return 'cancelled';
      default:
        return value;
    }
  }

  String get statusLabel {
    switch (normalizedStatus) {
      case 'pending_payment':
        return 'Menunggu Pembayaran';
      case 'waiting_verification':
        return 'Menunggu Verifikasi';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'completed':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Baru';
    }
  }

  AdminBookingStatusStyle get statusStyle {
    switch (normalizedStatus) {
      case 'pending_payment':
      case 'waiting_verification':
        return const AdminBookingStatusStyle(
          badgeColor: Color(0xFFFFE0B2),
          softColor: Color(0xFFFFE3C8),
          textColor: Color(0xFFB35A00),
        );
      case 'confirmed':
        return const AdminBookingStatusStyle(
          badgeColor: Color(0xFFD7F0D8),
          softColor: Color(0xFFD7F0D8),
          textColor: Color(0xFF2BA84A),
        );
      case 'completed':
        return const AdminBookingStatusStyle(
          badgeColor: Color(0xFFD5DFFF),
          softColor: Color(0xFFD5DFFF),
          textColor: Color(0xFF315BFF),
        );
      case 'rejected':
      case 'cancelled':
        return const AdminBookingStatusStyle(
          badgeColor: Color(0xFFFFD6D6),
          softColor: Color(0xFFFFD6D6),
          textColor: Color(0xFFE53935),
        );
      default:
        return const AdminBookingStatusStyle(
          badgeColor: Color(0xFFEAEAEA),
          softColor: Color(0xFFEAEAEA),
          textColor: Color(0xFF777777),
        );
    }
  }
}

class AdminPaymentSummary {
  final String id;
  final int amount;
  final String status;
  final DateTime paymentDate;

  const AdminPaymentSummary({
    required this.id,
    required this.amount,
    required this.status,
    required this.paymentDate,
  });

  factory AdminPaymentSummary.fromMap(Map<String, dynamic> map) {
    return AdminPaymentSummary(
      id: map['id']?.toString() ?? '',
      amount: _parseInt(
        map['amount'] ??
            map['total'] ??
            map['nominal'] ??
            map['jumlah'] ??
            map['harga'],
      ),
      status: map['status']?.toString() ?? '',
      paymentDate: _parseDate(map['payment_date']),
    );
  }

  bool get isVerified {
    final value = status.toLowerCase().trim();

    return value == 'verified' ||
        value == 'approved' ||
        value == 'paid' ||
        value == 'lunas';
  }
}

class AdminBookingStatusStyle {
  final Color badgeColor;
  final Color softColor;
  final Color textColor;

  const AdminBookingStatusStyle({
    required this.badgeColor,
    required this.softColor,
    required this.textColor,
  });
}

String formatDate(DateTime date) {
  if (date.millisecondsSinceEpoch == 0) {
    return '-';
  }

  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();

  return int.tryParse(value.toString()) ?? 0;
}

double _parseDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is num) return value.toDouble();

  return double.tryParse(value.toString()) ?? 0;
}

DateTime _parseDate(dynamic value) {
  if (value == null) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  if (value is DateTime) {
    return value;
  }

  return DateTime.tryParse(value.toString()) ??
      DateTime.fromMillisecondsSinceEpoch(0);
}