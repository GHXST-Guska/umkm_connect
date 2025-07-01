import 'package:umkm_connect/models/product_model.dart';

class CartItemModel {
  final int id;
  final int userId;
  final int productId;
  final int quantity;
  final ProductModel product; // Data produk yang terkait

  CartItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      userId: json['user_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      product: ProductModel.fromJson(json['product']),
    );
  }
}