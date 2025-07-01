class ProductModel {
  final int id;
  final int shopId;
  final String title;
  final String description;
  final int price;
  final int stock;
  final String rating;
  final String? image;
  final String? imageUrl;
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
    required this.rating,
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
      shopId: json['shop_id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      stock: json['stock'],
      rating: (json['rating'] ?? '0.0').toString(), // aman dari null
      image: json['image'],
      imageUrl: json['image_url'],
      location: json['location'] ?? 'Tidak diketahui',
      category: json['category'] ?? 'Umum',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
