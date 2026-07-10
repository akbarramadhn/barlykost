import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/admin/kost.dart';

class KostService {
  final SupabaseClient _supabase;

  KostService({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  Future<List<Kost>> getAllKosts() async {
    try {
      final data = await _supabase
          .from('kosts')
          .select('''
            id,
            owner_id,
            nama_kost,
            lokasi,
            harga,
            deskripsi,
            rating,
            tersedia,
            created_at,
            kost_images (
              image_url
            )
          ''')
          .order('created_at', ascending: false);

      return data.map<Kost>((item) {
        return Kost.fromMap(Map<String, dynamic>.from(item));
      }).toList();
    } on PostgrestException catch (error) {
      throw KostServiceException(
        'Gagal mengambil data kost: ${error.message}',
      );
    } catch (error) {
      throw KostServiceException(
        'Terjadi kesalahan saat mengambil data kost: $error',
      );
    }
  }

  Future<Kost> getKostById(String kostId) async {
    try {
      final data = await _supabase
          .from('kosts')
          .select('''
            id,
            owner_id,
            nama_kost,
            lokasi,
            harga,
            deskripsi,
            rating,
            tersedia,
            created_at,
            kost_images (
              image_url
            )
          ''')
          .eq('id', kostId)
          .single();

      return Kost.fromMap(Map<String, dynamic>.from(data));
    } on PostgrestException catch (error) {
      throw KostServiceException(
        'Gagal mengambil detail kost: ${error.message}',
      );
    } catch (error) {
      throw KostServiceException(
        'Terjadi kesalahan saat mengambil detail kost: $error',
      );
    }
  }
}

class KostServiceException implements Exception {
  final String message;

  const KostServiceException(this.message);

  @override
  String toString() => message;
}