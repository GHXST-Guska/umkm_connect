class ShopModel {
  final int id;
  final String name;
  final String? fotoKtp;
  final String status;

  ShopModel({
    required this.id,
    required this.name,
    this.fotoKtp,
    required this.status,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'],
      name: json['name'],
      fotoKtp: json['foto_ktp'],
      status: json['status'],
    );
  }
}
