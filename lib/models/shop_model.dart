import 'package:umkm_connect/models/user_model.dart';

class ShopModel {
  final int id;
  final String name;
  final String? fotoKtp;
  final String status;
  final int? userId;
  final String? fotoKtpUrl;
  final String? fotoProfilTokoUrl;
  final UserProfile? user;

  ShopModel({
    required this.id,
    required this.name,
    this.fotoKtp,
    required this.status,
    this.userId,
    this.fotoKtpUrl,
    this.fotoProfilTokoUrl,
    this.user,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'],
      name: json['name'],
      fotoKtp: json['foto_ktp'],
      status: json['status'],
      userId: json['user_id'],
      fotoKtpUrl: json['foto_ktp_url'], 
      fotoProfilTokoUrl: json['foto_profil_toko_url'],

      // INI BAGIAN PENTING:
      // Cek dulu apakah 'user' ada di dalam JSON sebelum di-parse
      user: json.containsKey('user') && json['user'] != null 
          ? UserProfile.fromJson(json['user']) 
          : null,
    );
  }
}