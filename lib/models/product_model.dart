class ProductModel {
  final int id;
  final int shopId; // Diubah dari userId
  final String title; // Diubah dari title
  final String description;
  final int price;
  final int stock;
  final String? image; // Nama file asli, bisa null
  final String? imageUrl; // URL lengkap untuk ditampilkan, bisa null
  final String location;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.shopId,
    required this.title,
    required this.description,
    required this.price,
    required this.stock,
    this.image,
    this.imageUrl,
    required this.location,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      shopId: json['shop_id'], // Disesuaikan dengan ERD
      title: json['title'],     // Disesuaikan dengan ERD
      description: json['description'],
      price: json['price'],
      stock: json['stock'],
      image: json['image'], // Nama file dari database
      imageUrl: json['image_url'], // URL lengkap dari accessor
      location: json['location'] ?? 'Tidak diketahui',
      category: json['category'] ?? 'Umum',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}