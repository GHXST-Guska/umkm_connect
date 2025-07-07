import 'package:umkm_connect/models/user_model.dart';

class ShopModel {
  final int id;
  final String name;
  final String status;
  final int? userId;
  final String? fotoKtpUrl;
  final String? fotoProfilTokoUrl;
  final int penghasilan; // <-- Properti baru
  final UserProfile? user;

  ShopModel({
    required this.id,
    required this.name,
    required this.status,
    this.userId,
    this.fotoKtpUrl,
    this.fotoProfilTokoUrl,
    required this.penghasilan, // <-- Ditambahkan ke constructor
    this.user,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'],
      name: json['name'] ?? 'Nama Toko Tidak Ada',
      status: json['status'] ?? 'pending',
      userId: json['user_id'],
      fotoKtpUrl: json['foto_ktp_url'],
      fotoProfilTokoUrl: json['foto_profil_toko_url'],
      // Ambil 'penghasilan' dari JSON, beri nilai 0 jika null
      penghasilan: int.tryParse(json['penghasilan']?.toString() ?? '0') ?? 0, 
      user: json['user'] != null ? UserProfile.fromJson(json['user']) : null,
    );
  }
}