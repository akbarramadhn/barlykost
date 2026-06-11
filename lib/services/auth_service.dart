import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final String normalizedEmail = email.trim().toLowerCase();

      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );

      final User? authUser = response.user;

      if (authUser == null) {
        throw Exception('Login gagal. Silakan cek email dan password.');
      }

      Map<String, dynamic>? userData = await _supabase
          .from('users')
          .select('id, full_name, email, phone, role')
          .eq('id', authUser.id)
          .maybeSingle();

      userData ??= await _supabase
          .from('users')
          .select('id, full_name, email, phone, role')
          .ilike('email', normalizedEmail)
          .maybeSingle();

      if (userData == null) {
        throw Exception(
          'Data user tidak ditemukan di tabel users. Cek RLS policy atau pastikan email sama dengan Authentication Users.',
        );
      }

      final String role = userData['role'].toString();

      if (role != 'admin' && role != 'penyewa') {
        throw Exception('Role user tidak valid. Role harus admin atau penyewa.');
      }

      return role;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      final String normalizedEmail = email.trim().toLowerCase();

      final String formattedPhone = phone.startsWith('0')
          ? '+62${phone.substring(1)}'
          : phone.startsWith('+62')
              ? phone
              : '+62$phone';

      final AuthResponse response = await _supabase.auth.signUp(
        email: normalizedEmail,
        password: password,
        data: {
          'full_name': name.trim(),
          'phone': formattedPhone,
          'role': 'penyewa',
        },
      );

      if (response.user == null) {
        throw Exception('Registrasi gagal. Silakan coba lagi.');
      }
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan saat registrasi.');
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Gagal logout.');
    }
  }

  User? get currentUser {
    return _supabase.auth.currentUser;
  }

  Session? get currentSession {
    return _supabase.auth.currentSession;
  }

  bool get isLoggedIn {
    return _supabase.auth.currentSession != null;
  }
}