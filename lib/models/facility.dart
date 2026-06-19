import 'package:flutter/material.dart';

class FacilityModel {
  final int id;
  final String name;

  const FacilityModel({
    required this.id,
    required this.name,
  });

  factory FacilityModel.fromMap(Map<String, dynamic> map) {
    return FacilityModel(
      id: int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      name: map['name']?.toString() ?? 'Fasilitas',
    );
  }

  static List<FacilityModel> defaultFacilities() {
    return const [
      FacilityModel(
        id: 2,
        name: 'TV',
      ),
      FacilityModel(
        id: 5,
        name: 'Lemari',
      ),
      FacilityModel(
        id: 6,
        name: 'Tempat Tidur',
      ),
      FacilityModel(
        id: 3,
        name: 'AC',
      ),
    ];
  }

  IconData get icon {
    final lowerName = name.toLowerCase();

    if (lowerName.contains('tv')) {
      return Icons.tv_rounded;
    }

    if (lowerName.contains('lemari')) {
      return Icons.door_sliding_rounded;
    }

    if (lowerName.contains('tidur')) {
      return Icons.bed_rounded;
    }

    if (lowerName.contains('ac')) {
      return Icons.ac_unit_rounded;
    }

    if (lowerName.contains('wifi')) {
      return Icons.wifi_rounded;
    }

    if (lowerName.contains('parkir')) {
      return Icons.local_parking_rounded;
    }

    if (lowerName.contains('mandi')) {
      return Icons.bathtub_rounded;
    }

    return Icons.check_circle_outline_rounded;
  }
}