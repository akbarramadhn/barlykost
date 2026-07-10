import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/admin/kost.dart';

class KostService {
  static const String _kostImageBucket = 'kost-images';

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
        _buildPostgrestMessage(
          title: 'Gagal mengambil data kost',
          error: error,
        ),
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
        _buildPostgrestMessage(
          title: 'Gagal mengambil detail kost',
          error: error,
        ),
      );
    } catch (error) {
      throw KostServiceException(
        'Terjadi kesalahan saat mengambil detail kost: $error',
      );
    }
  }

  Future<Map<int, String>> getFacilities() async {
    try {
      final data = await _supabase
          .from('facilities')
          .select('id, name')
          .order('name', ascending: true);

      final Map<int, String> facilities = <int, String>{};

      for (final item in data) {
        final Map<String, dynamic> facility = Map<String, dynamic>.from(item);

        final int? id = _parseInt(facility['id']);
        final String name = facility['name']?.toString().trim() ?? '';

        if (id != null && name.isNotEmpty) {
          facilities[id] = name;
        }
      }

      return facilities;
    } on PostgrestException catch (error) {
      throw KostServiceException(
        _buildPostgrestMessage(
          title: 'Gagal mengambil fasilitas',
          error: error,
        ),
      );
    } catch (error) {
      throw KostServiceException(
        'Terjadi kesalahan saat mengambil fasilitas: $error',
      );
    }
  }

  Future<List<int>> getKostFacilityIds(String kostId) async {
    try {
      final data = await _supabase
          .from('kost_facilities')
          .select('facility_id')
          .eq('kost_id', kostId);

      final List<int> facilityIds = <int>[];

      for (final item in data) {
        final Map<String, dynamic> relation = Map<String, dynamic>.from(item);

        final int? facilityId = _parseInt(relation['facility_id']);

        if (facilityId != null) {
          facilityIds.add(facilityId);
        }
      }

      return facilityIds;
    } on PostgrestException catch (error) {
      throw KostServiceException(
        _buildPostgrestMessage(
          title: 'Gagal mengambil fasilitas kost',
          error: error,
        ),
      );
    } catch (error) {
      throw KostServiceException(
        'Terjadi kesalahan saat mengambil fasilitas kost: $error',
      );
    }
  }

  Future<Kost> createKost({
    required String namaKost,
    required String lokasi,
    required int harga,
    required int tersedia,
    required String deskripsi,
    required List<int> facilityIds,
    required List<XFile> images,
  }) async {
    final String ownerId = _requireCurrentUserId();

    String? createdKostId;
    final List<String> uploadedPaths = <String>[];

    try {
      final insertedKost = await _supabase
          .from('kosts')
          .insert({
            'owner_id': ownerId,
            'nama_kost': namaKost,
            'lokasi': lokasi,
            'harga': harga,
            'deskripsi': deskripsi,
            'tersedia': tersedia,
          })
          .select('id')
          .single();

      final String kostId = insertedKost['id'].toString();

      createdKostId = kostId;

      final List<Map<String, dynamic>> imageRows = await _uploadImages(
        ownerId: ownerId,
        kostId: kostId,
        images: images,
        uploadedPaths: uploadedPaths,
      );

      if (imageRows.isNotEmpty) {
        await _supabase.from('kost_images').insert(imageRows);
      }

      if (facilityIds.isNotEmpty) {
        await _supabase
            .from('kost_facilities')
            .insert(
              _buildFacilityRows(kostId: kostId, facilityIds: facilityIds),
            );
      }

      return await getKostById(kostId);
    } catch (error) {
      if (createdKostId != null) {
        await _rollbackCreatedKost(
          kostId: createdKostId,
          uploadedPaths: uploadedPaths,
        );
      }

      throw _convertCreateError(error);
    }
  }

  Future<Kost> updateKost({
    required String kostId,
    required String namaKost,
    required String lokasi,
    required int harga,
    required int tersedia,
    required String deskripsi,
    required List<int> facilityIds,
    required List<String> retainedImageUrls,
    required List<XFile> newImages,
  }) async {
    final String ownerId = _requireCurrentUserId();

    final Kost previousKost = await getKostById(kostId);
    final List<int> previousFacilityIds = await getKostFacilityIds(kostId);

    final List<String> uploadedPaths = <String>[];
    final List<String> uploadedUrls = <String>[];

    bool kostDataUpdated = false;
    bool facilitiesUpdated = false;

    try {
      final existingImageData = await _supabase
          .from('kost_images')
          .select('id, image_url')
          .eq('kost_id', kostId);

      final List<Map<String, dynamic>> existingImageRows = existingImageData
          .map<Map<String, dynamic>>((item) {
            return Map<String, dynamic>.from(item);
          })
          .toList();

      final List<Map<String, dynamic>> newImageRows = await _uploadImages(
        ownerId: ownerId,
        kostId: kostId,
        images: newImages,
        uploadedPaths: uploadedPaths,
      );

      uploadedUrls.addAll(
        newImageRows.map<String>((row) {
          return row['image_url'].toString();
        }),
      );

      final updatedKost = await _supabase
          .from('kosts')
          .update({
            'nama_kost': namaKost,
            'lokasi': lokasi,
            'harga': harga,
            'deskripsi': deskripsi,
            'tersedia': tersedia,
          })
          .eq('id', kostId)
          .eq('owner_id', ownerId)
          .select('id')
          .maybeSingle();

      if (updatedKost == null) {
        throw const KostServiceException(
          'Data kost tidak ditemukan atau tidak dapat diedit.',
        );
      }

      kostDataUpdated = true;

      await _supabase.from('kost_facilities').delete().eq('kost_id', kostId);

      facilitiesUpdated = true;

      if (facilityIds.isNotEmpty) {
        await _supabase
            .from('kost_facilities')
            .insert(
              _buildFacilityRows(kostId: kostId, facilityIds: facilityIds),
            );
      }

      if (newImageRows.isNotEmpty) {
        await _supabase.from('kost_images').insert(newImageRows);
      }

      final Set<String> retainedUrls = retainedImageUrls.toSet();

      final List<String> removedImageIds = <String>[];
      final List<String> removedStoragePaths = <String>[];

      for (final Map<String, dynamic> imageRow in existingImageRows) {
        final String imageUrl = imageRow['image_url']?.toString() ?? '';

        if (retainedUrls.contains(imageUrl)) {
          continue;
        }

        final String imageId = imageRow['id']?.toString() ?? '';

        if (imageId.isNotEmpty) {
          removedImageIds.add(imageId);
        }

        final String? storagePath = _extractStoragePath(imageUrl);

        if (storagePath != null) {
          removedStoragePaths.add(storagePath);
        }
      }

      if (removedImageIds.isNotEmpty) {
        await _supabase
            .from('kost_images')
            .delete()
            .inFilter('id', removedImageIds);
      }

      if (removedStoragePaths.isNotEmpty) {
        try {
          await _supabase.storage
              .from(_kostImageBucket)
              .remove(removedStoragePaths);
        } catch (_) {}
      }

      return await getKostById(kostId);
    } catch (error) {
      await _rollbackUpdatedKost(
        kostId: kostId,
        previousKost: previousKost,
        previousFacilityIds: previousFacilityIds,
        uploadedPaths: uploadedPaths,
        uploadedUrls: uploadedUrls,
        restoreKostData: kostDataUpdated,
        restoreFacilities: facilitiesUpdated,
      );

      throw _convertUpdateError(error);
    }
  }

  Future<void> deleteKost(String kostId) async {
    final String ownerId = _requireCurrentUserId();

    try {
      final Map<String, dynamic>? kostData = await _supabase
          .from('kosts')
          .select('id, owner_id')
          .eq('id', kostId)
          .maybeSingle();

      if (kostData == null) {
        throw const KostServiceException('Data kost tidak ditemukan.');
      }

      if (kostData['owner_id']?.toString() != ownerId) {
        throw const KostServiceException(
          'Kamu tidak memiliki izin untuk menghapus kost ini.',
        );
      }

      final List<dynamic> bookingData = await _supabase
          .from('bookings')
          .select('id')
          .eq('kost_id', kostId)
          .limit(1);

      if (bookingData.isNotEmpty) {
        throw const KostServiceException(
          'Kost tidak dapat dihapus karena sudah memiliki riwayat pemesanan.',
        );
      }

      final List<dynamic> imageData = await _supabase
          .from('kost_images')
          .select('image_url')
          .eq('kost_id', kostId);

      final List<String> storagePaths = <String>[];

      for (final dynamic item in imageData) {
        final Map<String, dynamic> image = Map<String, dynamic>.from(
          item as Map,
        );

        final String imageUrl = image['image_url']?.toString() ?? '';

        final String? storagePath = _extractStoragePath(imageUrl);

        if (storagePath != null) {
          storagePaths.add(storagePath);
        }
      }

      await _supabase.from('wishlists').delete().eq('kost_id', kostId);

      await _supabase.from('reviews').delete().eq('kost_id', kostId);

      await _supabase.from('kost_facilities').delete().eq('kost_id', kostId);

      await _supabase.from('kost_images').delete().eq('kost_id', kostId);

      final Map<String, dynamic>? deletedKost = await _supabase
          .from('kosts')
          .delete()
          .eq('id', kostId)
          .eq('owner_id', ownerId)
          .select('id')
          .maybeSingle();

      if (deletedKost == null) {
        throw const KostServiceException(
          'Kost gagal dihapus atau sudah tidak tersedia.',
        );
      }

      if (storagePaths.isNotEmpty) {
        try {
          await _supabase.storage.from(_kostImageBucket).remove(storagePaths);
        } catch (_) {}
      }
    } on KostServiceException {
      rethrow;
    } on PostgrestException catch (error) {
      throw KostServiceException(
        _buildPostgrestMessage(title: 'Gagal menghapus kost', error: error),
      );
    } on StorageException catch (error) {
      throw KostServiceException(
        'Data kost terhapus, tetapi foto gagal dibersihkan: '
        '${error.message}',
      );
    } catch (error) {
      throw KostServiceException(
        'Terjadi kesalahan saat menghapus kost: $error',
      );
    }
  }

  Future<List<Map<String, dynamic>>> _uploadImages({
    required String ownerId,
    required String kostId,
    required List<XFile> images,
    required List<String> uploadedPaths,
  }) async {
    final List<Map<String, dynamic>> imageRows = <Map<String, dynamic>>[];

    for (int index = 0; index < images.length; index++) {
      final XFile image = images[index];
      final String fileName = _sanitizeFileName(image.name);

      final String storagePath =
          '$ownerId/$kostId/'
          '${DateTime.now().microsecondsSinceEpoch}_'
          '${index + 1}_$fileName';

      final bytes = await image.readAsBytes();

      await _supabase.storage
          .from(_kostImageBucket)
          .uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(
              contentType: image.mimeType ?? _getContentType(image.name),
              upsert: false,
            ),
          );

      uploadedPaths.add(storagePath);

      final String imageUrl = _supabase.storage
          .from(_kostImageBucket)
          .getPublicUrl(storagePath);

      imageRows.add({'kost_id': kostId, 'image_url': imageUrl});
    }

    return imageRows;
  }

  List<Map<String, dynamic>> _buildFacilityRows({
    required String kostId,
    required List<int> facilityIds,
  }) {
    return facilityIds.map<Map<String, dynamic>>((int facilityId) {
      return {'kost_id': kostId, 'facility_id': facilityId};
    }).toList();
  }

  Future<void> _rollbackCreatedKost({
    required String kostId,
    required List<String> uploadedPaths,
  }) async {
    await _removeStorageFiles(uploadedPaths);

    try {
      await _supabase.from('kost_facilities').delete().eq('kost_id', kostId);
    } catch (_) {}

    try {
      await _supabase.from('kost_images').delete().eq('kost_id', kostId);
    } catch (_) {}

    try {
      await _supabase.from('kosts').delete().eq('id', kostId);
    } catch (_) {}
  }

  Future<void> _rollbackUpdatedKost({
    required String kostId,
    required Kost previousKost,
    required List<int> previousFacilityIds,
    required List<String> uploadedPaths,
    required List<String> uploadedUrls,
    required bool restoreKostData,
    required bool restoreFacilities,
  }) async {
    if (uploadedUrls.isNotEmpty) {
      for (final String imageUrl in uploadedUrls) {
        try {
          await _supabase
              .from('kost_images')
              .delete()
              .eq('kost_id', kostId)
              .eq('image_url', imageUrl);
        } catch (_) {}
      }
    }

    await _removeStorageFiles(uploadedPaths);

    if (restoreFacilities) {
      try {
        await _supabase.from('kost_facilities').delete().eq('kost_id', kostId);

        if (previousFacilityIds.isNotEmpty) {
          await _supabase
              .from('kost_facilities')
              .insert(
                _buildFacilityRows(
                  kostId: kostId,
                  facilityIds: previousFacilityIds,
                ),
              );
        }
      } catch (_) {}
    }

    if (restoreKostData) {
      try {
        await _supabase
            .from('kosts')
            .update({
              'nama_kost': previousKost.namaKost,
              'lokasi': previousKost.lokasi,
              'harga': previousKost.harga,
              'deskripsi': previousKost.deskripsi,
              'tersedia': previousKost.tersedia,
            })
            .eq('id', kostId);
      } catch (_) {}
    }
  }

  Future<void> _removeStorageFiles(List<String> storagePaths) async {
    if (storagePaths.isEmpty) {
      return;
    }

    try {
      await _supabase.storage.from(_kostImageBucket).remove(storagePaths);
    } catch (_) {}
  }

  String _requireCurrentUserId() {
    final String? userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      throw const KostServiceException(
        'Sesi admin tidak ditemukan. Silakan masuk kembali.',
      );
    }

    return userId;
  }

  int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value == null) {
      return null;
    }

    return int.tryParse(value.toString());
  }

  String _sanitizeFileName(String fileName) {
    final String cleaned = fileName.trim().replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]'),
      '_',
    );

    if (cleaned.isEmpty) {
      return 'kost_image.jpg';
    }

    return cleaned;
  }

  String _getContentType(String fileName) {
    final String extension = fileName.split('.').last.toLowerCase();

    if (extension == 'png') {
      return 'image/png';
    }

    if (extension == 'webp') {
      return 'image/webp';
    }

    if (extension == 'heic') {
      return 'image/heic';
    }

    if (extension == 'gif') {
      return 'image/gif';
    }

    return 'image/jpeg';
  }

  String? _extractStoragePath(String imageUrl) {
    final String marker = '/object/public/$_kostImageBucket/';

    final int markerIndex = imageUrl.indexOf(marker);

    if (markerIndex == -1) {
      return null;
    }

    final String rawPath = imageUrl
        .substring(markerIndex + marker.length)
        .split('?')
        .first;

    if (rawPath.isEmpty) {
      return null;
    }

    return Uri.decodeFull(rawPath);
  }

  KostServiceException _convertCreateError(Object error) {
    if (error is KostServiceException) {
      return error;
    }

    if (error is PostgrestException) {
      return KostServiceException(
        _buildPostgrestMessage(
          title: 'Gagal menyimpan data kost',
          error: error,
        ),
      );
    }

    if (error is StorageException) {
      return KostServiceException(
        'Gagal mengunggah foto kost: ${error.message}',
      );
    }

    return KostServiceException(
      'Terjadi kesalahan saat menambahkan kost: $error',
    );
  }

  KostServiceException _convertUpdateError(Object error) {
    if (error is KostServiceException) {
      return error;
    }

    if (error is PostgrestException) {
      return KostServiceException(
        _buildPostgrestMessage(
          title: 'Gagal memperbarui data kost',
          error: error,
        ),
      );
    }

    if (error is StorageException) {
      return KostServiceException(
        'Gagal memperbarui foto kost: ${error.message}',
      );
    }

    return KostServiceException(
      'Terjadi kesalahan saat memperbarui kost: $error',
    );
  }

  String _buildPostgrestMessage({
    required String title,
    required PostgrestException error,
  }) {
    final StringBuffer message = StringBuffer('$title: ${error.message}');

    if (error.code != null && error.code!.isNotEmpty) {
      message.write(' (${error.code})');
    }

    if (error.details != null && error.details.toString().trim().isNotEmpty) {
      message.write('\n${error.details}');
    }

    if (error.hint != null && error.hint.toString().trim().isNotEmpty) {
      message.write('\n${error.hint}');
    }

    return message.toString();
  }
}

class KostServiceException implements Exception {
  final String message;

  const KostServiceException(this.message);

  @override
  String toString() => message;
}
