class Kost {
  final String id;
  final String? ownerId;
  final String namaKost;
  final String lokasi;
  final int harga;
  final String? deskripsi;
  final double rating;
  final int tersedia;
  final DateTime? createdAt;
  final List<String> imageUrls;

  const Kost({
    required this.id,
    this.ownerId,
    required this.namaKost,
    required this.lokasi,
    required this.harga,
    this.deskripsi,
    required this.rating,
    required this.tersedia,
    this.createdAt,
    this.imageUrls = const [],
  });

  bool get isAvailable => tersedia > 0;

  String? get coverImageUrl {
    if (imageUrls.isEmpty) {
      return null;
    }

    return imageUrls.first;
  }

  factory Kost.fromMap(Map<String, dynamic> map) {
    final List<String> images = [];

    final rawImages = map['kost_images'];

    if (rawImages is List) {
      for (final image in rawImages) {
        if (image is Map && image['image_url'] != null) {
          images.add(image['image_url'].toString());
        }
      }
    }

    return Kost(
      id: map['id'].toString(),
      ownerId: map['owner_id']?.toString(),
      namaKost: map['nama_kost']?.toString() ?? '',
      lokasi: map['lokasi']?.toString() ?? '',
      harga: (map['harga'] as num?)?.toInt() ?? 0,
      deskripsi: map['deskripsi']?.toString(),
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      tersedia: (map['tersedia'] as num?)?.toInt() ?? 0,
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'].toString()),
      imageUrls: images,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'owner_id': ownerId,
      'nama_kost': namaKost,
      'lokasi': lokasi,
      'harga': harga,
      'deskripsi': deskripsi,
      'rating': rating,
      'tersedia': tersedia,
    };
  }

  Kost copyWith({
    String? id,
    String? ownerId,
    String? namaKost,
    String? lokasi,
    int? harga,
    String? deskripsi,
    double? rating,
    int? tersedia,
    DateTime? createdAt,
    List<String>? imageUrls,
  }) {
    return Kost(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      namaKost: namaKost ?? this.namaKost,
      lokasi: lokasi ?? this.lokasi,
      harga: harga ?? this.harga,
      deskripsi: deskripsi ?? this.deskripsi,
      rating: rating ?? this.rating,
      tersedia: tersedia ?? this.tersedia,
      createdAt: createdAt ?? this.createdAt,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}