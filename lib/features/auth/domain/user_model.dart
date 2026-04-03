class User {
  final String id;
  final String correo;
  final String fullName;

  User({required this.id, required this.correo, required this.fullName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      correo: json['correo'],
      fullName: json['fullName'],
    );
  }
}
