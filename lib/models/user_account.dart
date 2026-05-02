class UserAccount {
  UserAccount({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.displayName,
    required this.storeCode,
  });

  final String id;
  final String username;
  final String password;
  final String role;
  final String displayName;
  final String storeCode;

  bool get isAdmin => role == 'admin';
  bool get isStore => role == 'store';

  factory UserAccount.fromJson(Map<String, dynamic> json) => UserAccount(
    id: json['id'] as String,
    username: json['username'] as String,
    password: json['password'] as String,
    role: json['role'] as String,
    displayName: json['displayName'] as String,
    storeCode: json['storeCode'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'password': password,
    'role': role,
    'displayName': displayName,
    'storeCode': storeCode,
  };

  UserAccount copyWith({
    String? id,
    String? username,
    String? password,
    String? role,
    String? displayName,
    String? storeCode,
  }) {
    return UserAccount(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      storeCode: storeCode ?? this.storeCode,
    );
  }
}
