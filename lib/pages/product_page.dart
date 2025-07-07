import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:umkm_connect/models/order_model.dart';
import 'package:umkm_connect/models/product_model.dart';
import 'package:umkm_connect/models/shop_model.dart';
import 'package:umkm_connect/pages/product_form.dart';
import 'package:umkm_connect/services/api_static.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final APIStatic _api = APIStatic();
  Future<ShopModel>? _shopFuture;
  Future<List<ProductModel>>? _productsFuture;
  Future<List<OrderModel>>? _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _shopFuture = _api.getMyStore();
      _productsFuture = _api.getMyProducts();
      _ordersFuture = _api.getMyStoreOrders();
    });
  }

  void _navigateAndRefresh(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Toko Saya"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: FutureBuilder<ShopModel>(
          future: _shopFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text("Error: ${snapshot.error}")));
            }
            if (!snapshot.hasData) {
              return const Center(child: Text("Gagal memuat data toko."));
            }

            final shop = snapshot.data!;
            return ListView(
              children: [
                _buildShopHeader(shop),
                _buildEarningsCard(shop),
                _buildSectionTitle("Pesanan Masuk (3 Terbaru)"),
                _buildIncomingOrdersList(),
                _buildSectionTitle("Produk Anda"),
                _buildMyProductsGrid(),
                const SizedBox(height: 80),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndRefresh(const ProductFormPage()),
        tooltip: 'Tambah Produk',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildShopHeader(ShopModel shop) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.pink.shade50,
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: (shop.fotoProfilTokoUrl != null)
                ? NetworkImage(shop.fotoProfilTokoUrl!)
                : null,
            child: (shop.fotoProfilTokoUrl == null)
                ? const Icon(Icons.store, size: 40)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shop.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Chip(
                  label: Text(shop.status,
                      style: const TextStyle(color: Colors.white)),
                  backgroundColor:
                      shop.status.toLowerCase().contains('verifikasi')
                          ? Colors.green
                          : Colors.orange,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEarningsCard(ShopModel shop) {
    final formattedEarnings = NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(shop.penghasilan);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Penghasilan",
                    style: TextStyle(color: Colors.grey.shade600)),
                Text(formattedEarnings,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur ini belum tersedia.')));
              },
              child: const Text("Tarik Saldo"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIncomingOrdersList() {
    return FutureBuilder<List<OrderModel>>(
      future: _ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Memuat pesanan...")));
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Belum ada pesanan yang masuk.")));
        }

        final orders = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length > 3 ? 3 : orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return ListTile(
              title: Text(order.invoiceNumber),
              subtitle: Text("Total: ${order.formattedPrice}"),
              trailing: Chip(
                  label: Text(order.status),
                  backgroundColor: _getStatusColor(order.status).withOpacity(0.2)),
            );
          },
        );
      },
    );
  }

  Widget _buildMyProductsGrid() {
    return FutureBuilder<List<ProductModel>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text("Anda belum punya produk.")));
        }

        final products = snapshot.data!;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final item = products[index];
            return GestureDetector(
              onTap: () =>
                  _navigateAndRefresh(ProductFormPage(existingProduct: item)),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Image.network(item.imageUrl ?? '',
                        height: 100, width: double.infinity, fit: BoxFit.cover),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'unpaid':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}