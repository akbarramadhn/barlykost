import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user.dart';

class AuthService {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final String normalizedEmail =
          email.trim().toLowerCase();

      final AuthResponse response =
          await _supabase.auth.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );

      final User? authUser = response.user;

      if (authUser == null) {
        throw Exception(
          'Login gagal. Silakan cek email dan password.',
        );
      }

      final Map<String, dynamic>? userData =
          await fetchCurrentUserMap();

      if (userData == null) {
        throw Exception(
          'Data user tidak ditemukan di tabel users. Pastikan email di Authentication dan tabel users sudah sama.',
        );
      }

      final String role = userData['role']
              ?.toString()
              .trim()
              .toLowerCase() ??
          '';

      if (role != 'admin' && role != 'penyewa') {
        throw Exception(
          'Role user tidak valid. Role harus admin atau penyewa.',
        );
      }

      return role;
    } on AuthException catch (error) {
      throw Exception(error.message);
    } catch (error) {
      throw Exception(
        error.toString().replaceAll(
              'Exception: ',
              '',
            ),
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
      final String normalizedEmail =
          email.trim().toLowerCase();

      final String formattedPhone =
          formatPhoneNumber(phone);

      final AuthResponse response =
          await _supabase.auth.signUp(
        email: normalizedEmail,
        password: password,
        data: {
          'full_name': name.trim(),
          'phone': formattedPhone,
          'role': 'penyewa',
        },
      );

      final User? authUser = response.user;

      if (authUser == null) {
        throw Exception(
          'Registrasi gagal. Silakan coba lagi.',
        );
      }

      final Map<String, dynamic>? existingUser =
          await _supabase
              .from('users')
              .select('id')
              .ilike(
                'email',
                normalizedEmail,
              )
              .maybeSingle();

      if (existingUser == null) {
        await _supabase.from('users').insert({
          'id': authUser.id,
          'full_name': name.trim(),
          'email': normalizedEmail,
          'phone': formattedPhone,
          'role': 'penyewa',
          'created_at':
              DateTime.now().toIso8601String(),
          'profile_image_url': '',
        });
      }
    } on AuthException catch (error) {
      throw Exception(error.message);
    } catch (error) {
      throw Exception(
        error.toString().replaceAll(
              'Exception: ',
              '',
            ),
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

  Future<Map<String, dynamic>?>
      fetchCurrentUserMap() async {
    final User? authUser =
        _supabase.auth.currentUser;

    if (authUser == null) {
      return null;
    }

    final String email =
        authUser.email?.trim().toLowerCase() ?? '';

    Map<String, dynamic>? userData =
        await _supabase
            .from('users')
            .select(
              'id, full_name, email, phone, role, created_at, profile_image_url',
            )
            .eq(
              'id',
              authUser.id,
            )
            .maybeSingle();

    if (userData != null) {
      return Map<String, dynamic>.from(
        userData,
      );
    }

    if (email.isEmpty) {
      return null;
    }

    userData = await _supabase
        .from('users')
        .select(
          'id, full_name, email, phone, role, created_at, profile_image_url',
        )
        .ilike(
          'email',
          email,
        )
        .maybeSingle();

    if (userData == null) {
      return null;
    }

    return Map<String, dynamic>.from(
      userData,
    );
  }

  Future<UserModel> fetchCurrentUser() async {
    try {
      final Map<String, dynamic>? userData =
          await fetchCurrentUserMap();

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
      final Map<String, dynamic>? userData =
          await fetchCurrentUserMap();

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
      final User? authUser =
          _supabase.auth.currentUser;

      if (authUser == null) {
        throw Exception('User belum login.');
      }

      final Map<String, dynamic>?
          currentUserData =
          await fetchCurrentUserMap();

      if (currentUserData == null) {
        throw Exception(
          'Data user tidak ditemukan.',
        );
      }

      final String userId =
          currentUserData['id']?.toString() ?? '';

      if (userId.trim().isEmpty) {
        throw Exception(
          'User id tidak ditemukan.',
        );
      }

      final String formattedPhone =
          formatPhoneNumber(phone);

      String profileImageUrl =
          currentUserData['profile_image_url']
                  ?.toString() ??
              '';

      if (profileImageFile != null) {
        profileImageUrl =
            await uploadProfileImage(
          authUserId: authUser.id,
          imageFile: profileImageFile,
        );
      }

      final Map<String, dynamic>?
          updatedResponse =
          await _supabase
              .from('users')
              .update({
                'full_name': fullName.trim(),
                'phone': formattedPhone,
                'profile_image_url':
                    profileImageUrl,
              })
              .eq(
                'id',
                userId,
              )
              .select(
                'id, full_name, email, phone, role, created_at, profile_image_url',
              )
              .maybeSingle();

      if (updatedResponse == null) {
        throw Exception(
          'Gagal memperbarui profil.',
        );
      }

      return UserModel.fromMap(
        Map<String, dynamic>.from(
          updatedResponse,
        ),
      );
    } on AuthException catch (error) {
      throw Exception(error.message);
    } on StorageException catch (error) {
      throw Exception(error.message);
    } catch (error) {
      throw Exception(
        error.toString().replaceAll(
              'Exception: ',
              '',
            ),
      );
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final User? authUser =
          _supabase.auth.currentUser;

      if (authUser == null) {
        throw Exception(
          'Sesi pengguna tidak ditemukan. Silakan login kembali.',
        );
      }

      final String email =
          authUser.email?.trim().toLowerCase() ??
              '';

      if (email.isEmpty) {
        throw Exception(
          'Email akun tidak ditemukan.',
        );
      }

      if (currentPassword.isEmpty) {
        throw Exception(
          'Password saat ini wajib diisi.',
        );
      }

      if (newPassword.isEmpty) {
        throw Exception(
          'Password baru wajib diisi.',
        );
      }

      if (newPassword.length < 8) {
        throw Exception(
          'Password baru minimal 8 karakter.',
        );
      }

      if (currentPassword == newPassword) {
        throw Exception(
          'Password baru harus berbeda dari password saat ini.',
        );
      }

      final AuthResponse reAuthResponse =
          await _supabase.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );

      if (reAuthResponse.user == null) {
        throw Exception(
          'Password saat ini tidak sesuai.',
        );
      }

      final UserResponse updateResponse =
          await _supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );

      if (updateResponse.user == null) {
        throw Exception(
          'Password gagal diperbarui.',
        );
      }
    } on AuthException catch (error) {
      final String message =
          error.message.toLowerCase();

      if (message.contains(
            'invalid login credentials',
          ) ||
          message.contains(
            'invalid credentials',
          ) ||
          message.contains(
            'wrong password',
          )) {
        throw Exception(
          'Password saat ini tidak sesuai.',
        );
      }

      if (message.contains(
        'same password',
      )) {
        throw Exception(
          'Password baru harus berbeda dari password sebelumnya.',
        );
      }

      if (message.contains(
            'password should be',
          ) ||
          message.contains(
            'password must be',
          ) ||
          message.contains(
            'weak password',
          )) {
        throw Exception(
          'Password baru belum memenuhi ketentuan keamanan.',
        );
      }

      throw Exception(error.message);
    } catch (error) {
      throw Exception(
        error.toString().replaceAll(
              'Exception: ',
              '',
            ),
      );
    }
  }

  Future<String> uploadProfileImage({
    required String authUserId,
    required File imageFile,
  }) async {
    try {
      final int timestamp =
          DateTime.now()
              .millisecondsSinceEpoch;

      final String filePath =
          '$authUserId/profile.jpg';

      await _supabase.storage
          .from('profile-images')
          .upload(
            filePath,
            imageFile,
            fileOptions:
                const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      final String publicUrl =
          _supabase.storage
              .from('profile-images')
              .getPublicUrl(filePath);

      return '$publicUrl?v=$timestamp';
    } on StorageException catch (error) {
      throw Exception(error.message);
    } catch (error) {
      throw Exception(
        error.toString().replaceAll(
              'Exception: ',
              '',
            ),
      );
    }
  }

  String formatPhoneNumber(
    String phone,
  ) {
    final String cleanedPhone = phone
        .trim()
        .replaceAll(' ', '')
        .replaceAll('-', '');

    if (cleanedPhone.isEmpty) {
      return '';
    }

    if (cleanedPhone.startsWith('+62')) {
      return cleanedPhone;
    }

    if (cleanedPhone.startsWith('62')) {
      return '+$cleanedPhone';
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
    return _supabase.auth.currentSession !=
        null;
  }
}