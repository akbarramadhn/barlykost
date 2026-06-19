class KostModel {
  final String id;
  final String name;
  final String location;
  final int price;
  final double rating;
  final int available;
  final String description;
  final String imageUrl;

  const KostModel({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.available,
    required this.description,
    required this.imageUrl,
  });

  factory KostModel.empty() {
    return const KostModel(
      id: '',
      name: 'Kost',
      location: 'Lokasi belum tersedia',
      price: 0,
      rating: 0,
      available: 0,
      description: '',
      imageUrl: '',
    );
  }

  factory KostModel.fromMap(
    Map<String, dynamic> map, {
    String imageUrl = '',
  }) {
    return KostModel(
      id: map['id']?.toString() ?? '',
      name: map['nama_kost']?.toString() ?? 'Nama kost belum tersedia',
      location: map['lokasi']?.toString() ?? 'Lokasi belum tersedia',
      price: int.tryParse(map['harga']?.toString() ?? '0') ?? 0,
      rating: double.tryParse(map['rating']?.toString() ?? '0') ?? 0,
      available: int.tryParse(map['tersedia']?.toString() ?? '0') ?? 0,
      description: map['deskripsi']?.toString() ?? '',
      imageUrl: imageUrl.isNotEmpty
          ? imageUrl
          : map['image_url']?.toString() ?? '',
    );
  }
}