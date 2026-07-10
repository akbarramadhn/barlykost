class AdminProfile {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final DateTime? joinedAt;

  const AdminProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    this.joinedAt,
  });

  factory AdminProfile.fromMap(
    Map<String, dynamic> map, {
    required String userId,
    String? fallbackEmail,
    DateTime? fallbackJoinedAt,
  }) {
    return AdminProfile(
      id: userId,
      fullName: map['full_name']?.toString().trim().isNotEmpty == true
          ? map['full_name'].toString().trim()
          : 'Admin',
      email: map['email']?.toString().trim().isNotEmpty == true
          ? map['email'].toString().trim()
          : (fallbackEmail?.trim().isNotEmpty == true
                ? fallbackEmail!.trim()
                : '-'),
      phone: map['phone']?.toString().trim().isNotEmpty == true
          ? map['phone'].toString().trim()
          : '-',
      profileImageUrl:
          map['profile_image_url']?.toString().trim().isNotEmpty == true
              ? map['profile_image_url'].toString().trim()
              : null,
      joinedAt: fallbackJoinedAt,
    );
  }
}
