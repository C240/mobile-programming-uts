class User {
  final int id;
  final String username;

  User({required this.id, required this.username});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
    );
  }
}