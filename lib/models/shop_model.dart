import 'package:umkm_connect/models/user_model.dart';

class ShopModel {
  final int id;
  final String name;
  final String status;
  final int? userId;
  final String? fotoKtpUrl;
  final String? fotoProfilTokoUrl; // Tambahkan untuk foto profil toko
  final UserModel? user;

  ShopModel({
    required this.id,
    required this.name,
    required this.status,
    this.userId,
    this.fotoKtpUrl,
    this.fotoProfilTokoUrl,
    this.user,
  });

  // lib/models/shop_model.dart
  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'],
      name: json['name'] ?? 'Nama Toko Tidak Ada',
      status: json['status'] ?? 'pending',
      // Beri nilai default jika user_id null dari API
      userId: json['user_id'], 
      
      // Asumsikan accessor di backend sudah Anda buat
      fotoKtpUrl: json['foto_ktp_url'], 
      fotoProfilTokoUrl: json['foto_profil_toko_url'],

      // INI BAGIAN PENTING:
      // Cek dulu apakah 'user' ada di dalam JSON sebelum di-parse
      user: json.containsKey('user') && json['user'] != null 
          ? UserModel.fromJson(json['user']) 
          : null,
    );
  }
}