enum UserRole {
  student('Student'),
  staff('Staff');

  const UserRole(this.label);

  final String label;

  static UserRole parse(Object? value) => switch (value) {
    'student' => student,
    'staff' => staff,
    _ => throw const FormatException('Unknown account role.'),
  };
}

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.createdAt,
  });

  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final DateTime? createdAt;
}
