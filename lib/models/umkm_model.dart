class UMKMService {
  final int id;
  final int userId;
  final String title;
  final String description;
  final int price;
  final int stock;
  final String image;
  final String location;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  UMKMService({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.price,
    required this.stock,
    required this.image,
    required this.location,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UMKMService.fromJson(Map<String, dynamic> json) {
    return UMKMService(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      stock: json['stock'],
      image: json['image'],
      location: json['location'] ?? 'Tidak diketahui',
      category: json['category'] ?? 'Umum',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
