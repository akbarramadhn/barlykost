import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/penyewa/facility.dart';
import '../../models/penyewa/kost.dart';

class KostService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<KostModel>> fetchKostsWithImages() async {
    final kostResponse = await supabase
        .from('kosts')
        .select(
          'id, harga, lokasi, rating, owner_id, tersedia, deskripsi, nama_kost, created_at',
        )
        .order('rating', ascending: false);

    final imageResponse = await supabase
        .from('kost_images')
        .select('id, kost_id, image_url');

    final kostData = List<Map<String, dynamic>>.from(kostResponse);
    final imageData = List<Map<String, dynamic>>.from(imageResponse);

    final Map<String, String> imageMap = {};

    for (final image in imageData) {
      final kostId = image['kost_id']?.toString().trim() ?? '';
      final rawImageUrl = image['image_url']?.toString().trim() ?? '';
      final imageUrl = normalizeImageUrl(rawImageUrl);

      if (kostId.isNotEmpty && imageUrl.isNotEmpty) {
        imageMap.putIfAbsent(kostId, () => imageUrl);
      }
    }

    return kostData.map((kost) {
      final kostId = kost['id']?.toString().trim() ?? '';

      return KostModel.fromMap(
        kost,
        imageUrl: imageMap[kostId] ?? '',
      );
    }).toList();
  }

  Future<KostModel> fetchKostById(String kostId) async {
    final response = await supabase
        .from('kosts')
        .select(
          'id, harga, lokasi, rating, owner_id, tersedia, deskripsi, nama_kost, created_at',
        )
        .eq('id', kostId)
        .maybeSingle();

    if (response == null) {
      return KostModel.empty();
    }

    return KostModel.fromMap(
      Map<String, dynamic>.from(response),
    );
  }

  Future<List<String>> fetchKostImages(String kostId) async {
    final response = await supabase
        .from('kost_images')
        .select('id, kost_id, image_url')
        .eq('kost_id', kostId);

    final rows = List<Map<String, dynamic>>.from(response);

    return rows
        .map((row) {
          final rawImageUrl = row['image_url']?.toString() ?? '';
          return normalizeImageUrl(rawImageUrl);
        })
        .where((url) => url.trim().isNotEmpty)
        .toList();
  }

  Future<List<FacilityModel>> fetchFacilitiesByKostId(String kostId) async {
    try {
      final relationResponse = await supabase
          .from('kost_facilities')
          .select('facility_id')
          .eq('kost_id', kostId);

      final relationRows = List<Map<String, dynamic>>.from(relationResponse);

      final facilityIds = relationRows
          .map((row) => row['facility_id'])
          .where((id) => id != null)
          .toList();

      if (facilityIds.isEmpty) {
        return FacilityModel.defaultFacilities();
      }

      final facilityResponse = await supabase
          .from('facilities')
          .select('id, name')
          .inFilter('id', facilityIds);

      final facilityRows = List<Map<String, dynamic>>.from(facilityResponse);

      if (facilityRows.isEmpty) {
        return FacilityModel.defaultFacilities();
      }

      return facilityRows.map((row) {
        return FacilityModel.fromMap(row);
      }).toList();
    } catch (_) {
      return FacilityModel.defaultFacilities();
    }
  }

  String normalizeImageUrl(String value) {
    final cleanedValue = value.trim();

    if (cleanedValue.isEmpty) {
      return '';
    }

    if (cleanedValue.startsWith('http://') ||
        cleanedValue.startsWith('https://')) {
      return cleanedValue;
    }

    String storagePath = cleanedValue;

    if (storagePath.startsWith('/')) {
      storagePath = storagePath.substring(1);
    }

    if (storagePath.startsWith('kost-images/')) {
      storagePath = storagePath.replaceFirst('kost-images/', '');
    }

    return supabase.storage.from('kost-images').getPublicUrl(storagePath);
  }
}