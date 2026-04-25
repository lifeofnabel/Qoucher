class AppUser {
  final String id;
  final String firstName;
  final String username;
  final String email;
  final String role;
  final DateTime? createdAt;

  const AppUser({
    required this.id,
    required this.firstName,
    required this.username,
    required this.email,
    required this.role,
    this.createdAt,
  });

  bool get isMerchant => role == 'merchant';
  bool get isCustomer => role == 'customer';

  AppUser copyWith({
    String? id,
    String? firstName,
    String? username,
    String? email,
    String? role,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id']?.toString() ?? '',
      firstName: map['firstName']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      role: map['role']?.toString() ?? 'customer',
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'username': username,
      'email': email,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  @override
  String toString() {
    return 'AppUser(id: $id, firstName: $firstName, username: $username, email: $email, role: $role, createdAt: $createdAt)';
  }
}