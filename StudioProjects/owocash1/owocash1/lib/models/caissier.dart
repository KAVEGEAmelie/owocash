
class Caissier {
  final String id;
  final String username;
  final String role;

  Caissier({
    required this.id,
    required this.username,
    required this.role,
  });

  factory Caissier.fromJson(Map<String, dynamic> json) {
    return Caissier(
      id: json['id'].toString(),
      username: json['username'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
    };
  }
}
