import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();

      final response = await _supabase.auth.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );

      final authUser = response.user;

      if (authUser == null) {
        throw Exception('Login gagal. Silakan cek email dan password.');
      }

      final userData = await fetchCurrentUserMap();

      if (userData == null) {
        throw Exception(
          'Data user tidak ditemukan di tabel users. Pastikan email di Authentication dan tabel users sudah sama.',
        );
      }

      final role = userData['role']?.toString().trim().toLowerCase() ?? '';

      if (role != 'admin' && role != 'penyewa') {
        throw Exception('Role user tidak valid. Role harus admin atau penyewa.');
      }

      return role;
    } on AuthException catch (error) {
      throw Exception(error.message);
    } catch (error) {
      throw Exception(
        error.toString().replaceAll('Exception: ', ''),
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
      final normalizedEmail = email.trim().toLowerCase();
      final formattedPhone = formatPhoneNumber(phone);

      final response = await _supabase.auth.signUp(
        email: normalizedEmail,
        password: password,
        data: {
          'full_name': name.trim(),
          'phone': formattedPhone,
          'role': 'penyewa',
        },
      );

      final authUser = response.user;

      if (authUser == null) {
        throw Exception('Registrasi gagal. Silakan coba lagi.');
      }

      final existingUser = await _supabase
          .from('users')
          .select('id')
          .ilike('email', normalizedEmail)
          .maybeSingle();

      if (existingUser == null) {
        await _supabase.from('users').insert({
          'id': authUser.id,
          'full_name': name.trim(),
          'email': normalizedEmail,
          'phone': formattedPhone,
          'role': 'penyewa',
          'created_at': DateTime.now().toIso8601String(),
          'profile_image_url': '',
        });
      }
    } on AuthException catch (error) {
      throw Exception(error.message);
    } catch (error) {
      throw Exception(
        error.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (_) {
      throw Exception('Gagal logout.');
    }
  }

  Future<Map<String, dynamic>?> fetchCurrentUserMap() async {
    final authUser = _supabase.auth.currentUser;

    if (authUser == null) {
      return null;
    }

    final email = authUser.email?.trim().toLowerCase() ?? '';

    Map<String, dynamic>? userData = await _supabase
        .from('users')
        .select(
          'id, full_name, email, phone, role, created_at, profile_image_url',
        )
        .eq('id', authUser.id)
        .maybeSingle();

    if (userData != null) {
      return Map<String, dynamic>.from(userData);
    }

    if (email.isEmpty) {
      return null;
    }

    userData = await _supabase
        .from('users')
        .select(
          'id, full_name, email, phone, role, created_at, profile_image_url',
        )
        .ilike('email', email)
        .maybeSingle();

    if (userData == null) {
      return null;
    }

    return Map<String, dynamic>.from(userData);
  }

  Future<UserModel> fetchCurrentUser() async {
    try {
      final userData = await fetchCurrentUserMap();

      if (userData == null) {
        return UserModel.empty();
      }

      return UserModel.fromMap(userData);
    } catch (_) {
      return UserModel.empty();
    }
  }

  Future<String> getCurrentUserId() async {
    try {
      final userData = await fetchCurrentUserMap();

      if (userData == null) {
        return '';
      }

      return userData['id']?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<UserModel> updateProfile({
    required String fullName,
    required String phone,
    File? profileImageFile,
  }) async {
    try {
      final authUser = _supabase.auth.currentUser;

      if (authUser == null) {
        throw Exception('User belum login.');
      }

      final currentUserData = await fetchCurrentUserMap();

      if (currentUserData == null) {
        throw Exception('Data user tidak ditemukan.');
      }

      final userId = currentUserData['id']?.toString() ?? '';

      if (userId.trim().isEmpty) {
        throw Exception('User id tidak ditemukan.');
      }

      final formattedPhone = formatPhoneNumber(phone);
      String profileImageUrl =
          currentUserData['profile_image_url']?.toString() ?? '';

      if (profileImageFile != null) {
        profileImageUrl = await uploadProfileImage(
          authUserId: authUser.id,
          imageFile: profileImageFile,
        );
      }

      final updatedResponse = await _supabase
          .from('users')
          .update({
            'full_name': fullName.trim(),
            'phone': formattedPhone,
            'profile_image_url': profileImageUrl,
          })
          .eq('id', userId)
          .select(
            'id, full_name, email, phone, role, created_at, profile_image_url',
          )
          .maybeSingle();

      if (updatedResponse == null) {
        throw Exception('Gagal memperbarui profil.');
      }

      return UserModel.fromMap(
        Map<String, dynamic>.from(updatedResponse),
      );
    } on AuthException catch (error) {
      throw Exception(error.message);
    } on StorageException catch (error) {
      throw Exception(error.message);
    } catch (error) {
      throw Exception(
        error.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<String> uploadProfileImage({
    required String authUserId,
    required File imageFile,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '$authUserId/profile.jpg';

      await _supabase.storage.from('profile-images').upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      final publicUrl =
          _supabase.storage.from('profile-images').getPublicUrl(filePath);

      return '$publicUrl?v=$timestamp';
    } on StorageException catch (error) {
      throw Exception(error.message);
    } catch (error) {
      throw Exception(
        error.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  String formatPhoneNumber(String phone) {
    final cleanedPhone = phone.trim().replaceAll(' ', '');

    if (cleanedPhone.isEmpty) {
      return '';
    }

    if (cleanedPhone.startsWith('+62')) {
      return cleanedPhone;
    }

    if (cleanedPhone.startsWith('0')) {
      return '+62${cleanedPhone.substring(1)}';
    }

    return '+62$cleanedPhone';
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