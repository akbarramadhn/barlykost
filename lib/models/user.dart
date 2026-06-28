class UserModel {
  final String id;
  final String role;
  final String email;
  final String phone;
  final String fullName;
  final String createdAt;
  final String profileImageUrl;

  const UserModel({
    required this.id,
    required this.role,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.createdAt,
    required this.profileImageUrl,
  });

  factory UserModel.empty() {
    return const UserModel(
      id: '',
      role: '',
      email: '',
      phone: '',
      fullName: 'Pengguna',
      createdAt: '',
      profileImageUrl: '',
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      role: map['role']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      fullName: map['full_name']?.toString() ?? 'Pengguna',
      createdAt: map['created_at']?.toString() ?? '',
      profileImageUrl: map['profile_image_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'email': email,
      'phone': phone,
      'full_name': fullName,
      'created_at': createdAt,
      'profile_image_url': profileImageUrl,
    };
  }

  UserModel copyWith({
    String? id,
    String? role,
    String? email,
    String? phone,
    String? fullName,
    String? createdAt,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      createdAt: createdAt ?? this.createdAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  bool get isAdmin {
    return role.toLowerCase().trim() == 'admin';
  }

  bool get isPenyewa {
    return role.toLowerCase().trim() == 'penyewa';
  }

  bool get hasProfileImage {
    return profileImageUrl.trim().isNotEmpty;
  }

  String get displayName {
    if (fullName.trim().isEmpty) {
      return 'Pengguna';
    }

    return fullName.trim();
  }

  String get displayEmail {
    if (email.trim().isEmpty) {
      return '-';
    }

    return email.trim();
  }

  String get displayPhone {
    if (phone.trim().isEmpty) {
      return '-';
    }

    return phone.trim();
  }

  String get displayRole {
    if (role.trim().isEmpty) {
      return 'Pengguna';
    }

    if (isAdmin) {
      return 'Admin';
    }

    if (isPenyewa) {
      return 'Penyewa';
    }

    return role.trim();
  }

  String get displayProfileImageUrl {
    return profileImageUrl.trim();
  }
}