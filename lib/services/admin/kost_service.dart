import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/admin/dashboard.dart';

class AdminKostService {
  final SupabaseClient supabase;

  AdminKostService({SupabaseClient? supabaseClient})
      : supabase = supabaseClient ?? Supabase.instance.client;

  Future<List<AdminKostSummary>> getKostList() async {
    final response = await supabase.from('kosts').select();

    return response.map<AdminKostSummary>((item) {
      return AdminKostSummary.fromMap(Map<String, dynamic>.from(item));
    }).toList();
  }

  Future<void> addKost({
    required String name,
    required String location,
    required int price,
    required int available,
    required String description,
    double rating = 0,
  }) async {
    await supabase.from('kosts').insert({
      'nama_kost': name,
      'lokasi': location,
      'harga': price,
      'tersedia': available,
      'deskripsi': description,
      'rating': rating,
    });
  }

  Future<void> updateKost({
    required String id,
    required String name,
    required String location,
    required int price,
    required int available,
    required String description,
    required double rating,
  }) async {
    await supabase.from('kosts').update({
      'nama_kost': name,
      'lokasi': location,
      'harga': price,
      'tersedia': available,
      'deskripsi': description,
      'rating': rating,
    }).eq('id', id);
  }

  Future<void> deleteKost(String id) async {
    await supabase.from('kosts').delete().eq('id', id);
  }
}