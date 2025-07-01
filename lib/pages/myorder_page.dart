// lib/pages/my_orders_page.dart

import 'package:flutter/material.dart';
import 'package:umkm_connect/models/order_model.dart';
import 'package:umkm_connect/services/api_static.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  final APIStatic _api = APIStatic();
  late Future<List<OrderModel>> _myOrdersFuture;

  @override
  void initState() {
    super.initState();
    _myOrdersFuture = _api.getMyOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Pesanan Saya"),
      ),
      body: FutureBuilder<List<OrderModel>>(
        future: _myOrdersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Anda belum memiliki riwayat pesanan."));
          }
          
          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              // Gunakan UI Card yang sama seperti di halaman admin
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(order.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Chip(
                            label: Text(order.status, style: const TextStyle(color: Colors.white)),
                            backgroundColor: Colors.orange, // Sesuaikan warna
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Text("Total: ${order.formattedPrice}"),
                      Text("Alamat: ${order.shippingAddress}"),
                      Text("Tanggal: ${order.formattedDate}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}