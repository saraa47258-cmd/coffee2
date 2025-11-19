class Profile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarPath;

  const Profile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarPath,
  });

  Profile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarPath,
  }) => Profile(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    avatarPath: avatarPath ?? this.avatarPath,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'avatarPath': avatarPath,
  };

  factory Profile.fromMap(Map<String, dynamic> m) => Profile(
    id: (m['id'] ?? '').toString(),
    name: (m['name'] ?? '').toString(),
    email: (m['email'] ?? '').toString(),
    phone: (m['phone'] ?? '').toString(),
    avatarPath: m['avatarPath']?.toString(),
  );
}
