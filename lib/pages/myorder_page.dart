import 'package:flutter/material.dart';
import 'package:umkm_connect/models/order_model.dart';
import 'package:umkm_connect/services/api_static.dart';
import 'package:umkm_connect/pages/payment_webview_page.dart'; // Import untuk halaman pembayaran

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  final APIStatic _api = APIStatic();
  late Future<List<OrderModel>> _myOrdersFuture;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _myOrdersFuture = _api.getMyOrders();
    });
  }

  Future<void> _handlePayment(OrderModel order) async {
    setState(() => _isProcessingPayment = true);
    try {
      String paymentUrl = await _api.requestMidtransPaymentUrl(order.id);
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebViewPage(url: paymentUrl),
          ),
        );
      }
      _loadOrders(); // Muat ulang setelah kembali dari pembayaran
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingPayment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Pesanan Saya"),
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: FutureBuilder<List<OrderModel>>(
          future: _myOrdersFuture,
          builder: (context, snapshot) {
            // 1. Saat future masih berjalan (loading)
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. Jika future selesai tapi menghasilkan error
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            // 3. Jika future selesai tapi TIDAK ADA DATA (null atau list kosong)
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Anda belum memiliki riwayat pesanan."));
            }
            
            // 4. Jika semua aman, kita bisa akses data
            final orders = snapshot.data!;
            
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              backgroundColor: _getStatusColor(order.status),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        _buildDetailRow("Total", order.formattedPrice),
                        _buildDetailRow("Alamat", order.shippingAddress),
                        _buildDetailRow("Tanggal", order.formattedDate),

                        // Tampilkan tombol bayar jika status 'unpaid'
                        if (order.status.toLowerCase() == 'unpaid') ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isProcessingPayment ? null : () => _handlePayment(order),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: _isProcessingPayment
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                                  : const Text("Bayar Sekarang", style: TextStyle(color: Colors.white),),
                            ),
                          ),
                        ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 70, child: Text(label, style: const TextStyle(color: Colors.grey))),
          const Text(": "),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'unpaid':
        return Colors.orange.shade700;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}