class User {
  final String username;
  final String userId;
  final String? email;

  User({required this.username, required this.userId, this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      userId: json['user_id'] ?? '',
      email: json['email'],
    );
  }
}