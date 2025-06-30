// lib/models/order_model.dart

import 'package:intl/intl.dart';

class OrderModel {
  final int id;
  final int userId;
  final String invoiceNumber;
  final int totalAmount;
  final String status;
  final String shippingAddress;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.invoiceNumber,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.createdAt,
  });

  // Helper untuk memformat harga
  String get formattedPrice {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(totalAmount);
  }

  // Helper untuk memformat tanggal
  String get formattedDate {
    return DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(createdAt);
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['user_id'],
      invoiceNumber: json['invoice_number'] ?? 'N/A',
      totalAmount: json['total_amount'] ?? 0,
      status: json['status'] ?? 'unknown',
      shippingAddress: json['shipping_address'] ?? 'Alamat tidak ada',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}