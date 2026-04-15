// User entity (Domain layer)
class UserEntity {
  final String uid;
  final String email;
  final String? role;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserEntity({
    required this.uid,
    required this.email,
    this.role,
    required this.createdAt,
    this.updatedAt,
  });
}
