class UserModel {
  final String id;
  final String role;
  final String email;
  final String phone;
  final String fullName;

  const UserModel({
    required this.id,
    required this.role,
    required this.email,
    required this.phone,
    required this.fullName,
  });

  factory UserModel.empty() {
    return const UserModel(
      id: '',
      role: '',
      email: '',
      phone: '',
      fullName: 'Pengguna',
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      role: map['role']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      fullName: map['full_name']?.toString() ?? 'Pengguna',
    );
  }

  bool get isAdmin {
    return role.toLowerCase() == 'admin';
  }

  bool get isPenyewa {
    return role.toLowerCase() == 'penyewa';
  }
}