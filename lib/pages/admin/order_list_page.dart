// lib/pages/admin/order_list_page.dart

import 'package:flutter/material.dart';
import 'package:umkm_connect/models/order_model.dart';
import 'package:umkm_connect/services/api_static.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  late Future<List<OrderModel>> _ordersFuture;
  final APIStatic _api = APIStatic();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _ordersFuture = _api.getAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Semua Pesanan"),
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: FutureBuilder<List<OrderModel>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Tidak ada pesanan."));
            }
            
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.invoiceNumber,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Chip(
                              label: Text(
                                order.status, 
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                              ),
                              backgroundColor: _getStatusColor(order.status),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        _buildDetailRow("User ID", order.userId.toString()),
                        _buildDetailRow("Total", order.formattedPrice),
                        _buildDetailRow("Alamat", order.shippingAddress),
                        _buildDetailRow("Tanggal", order.formattedDate),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Widget helper untuk membuat baris detail
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Widget helper untuk memberikan warna pada status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'diterima':
        return Colors.green;
      case 'unpaid':
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}