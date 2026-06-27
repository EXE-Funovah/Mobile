enum UserRole { student, teacher, parent, admin, unknown }

UserRole roleFromString(String? s) {
  switch ((s ?? '').toLowerCase()) {
    case 'student':
      return UserRole.student;
    case 'teacher':
      return UserRole.teacher;
    case 'parent':
      return UserRole.parent;
    case 'admin':
      return UserRole.admin;
    default:
      return UserRole.unknown;
  }
}

class AppUser {
  final String id;
  final String fullName;
  final String email;
  final UserRole role;

  AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id:
          json['id']?.toString() ??
          json['userId']?.toString() ??
          json['Id']?.toString() ??
          '',
      fullName: json['fullName'] ?? json['FullName'] ?? json['name'] ?? '',
      email: json['email'] ?? json['Email'] ?? '',
      role: roleFromString(json['role'] ?? json['Role']),
    );
  }
}
