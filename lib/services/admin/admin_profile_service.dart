import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/admin/admin_profile.dart';

class AdminProfileService {
  final SupabaseClient _supabase;

  AdminProfileService({
    SupabaseClient? supabaseClient,
  }) : _supabase = supabaseClient ?? Supabase.instance.client;

  Future<AdminProfile> getCurrentAdminProfile() async {
    final User? authUser = _supabase.auth.currentUser;

    if (authUser == null) {
      throw const AdminProfileServiceException(
        'Sesi admin tidak ditemukan. Silakan masuk kembali.',
      );
    }

    try {
      final Map<String, dynamic> data = await _supabase
          .from('users')
          .select('full_name, email, phone, profile_image_url')
          .eq('id', authUser.id)
          .single();

      return AdminProfile.fromMap(
        data,
        userId: authUser.id,
        fallbackEmail: authUser.email,
        fallbackJoinedAt: DateTime.tryParse(authUser.createdAt),
      );
    } on PostgrestException catch (error) {
      throw AdminProfileServiceException(
        'Gagal mengambil profil admin: ${error.message}',
      );
    } catch (error) {
      throw AdminProfileServiceException(
        'Terjadi kesalahan saat mengambil profil admin: $error',
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (error) {
      throw AdminProfileServiceException(
        'Gagal keluar dari akun: $error',
      );
    }
  }
}

class AdminProfileServiceException implements Exception {
  final String message;

  const AdminProfileServiceException(this.message);

  @override
  String toString() => message;
}
