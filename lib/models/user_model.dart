// lib/models/user_model.dart

class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? imageUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.imageUrl
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      imageUrl: json['image_url'],
    );
  }
}
