import 'package:flutter/material.dart';
import 'package:umkm_connect/models/shop_model.dart';
import 'package:umkm_connect/services/api_static.dart';
import 'package:umkm_connect/pages/admin/shop_detail_page.dart';

class ShopListPage extends StatefulWidget {
  const ShopListPage({super.key});

  @override
  State<ShopListPage> createState() => _ShopListPageState();
}

class _ShopListPageState extends State<ShopListPage> {
  late Future<List<ShopModel>> _shopsFuture;
  final APIStatic _api = APIStatic();

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  Future<void> _loadShops() async {
    setState(() {
      _shopsFuture = _api.getAllShops();
    });
  }

  void _navigateToDetail(int shopId) async {
    // Navigasi ke halaman detail
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ShopDetailPage(shopId: shopId)),
    );
    // Setelah kembali dari halaman detail, muat ulang daftar toko untuk melihat perubahan
    _loadShops();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manajemen Toko"),
        backgroundColor: Colors.indigo,
      ),
      body: RefreshIndicator(
        onRefresh: _loadShops,
        child: FutureBuilder<List<ShopModel>>(
          future: _shopsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Tidak ada toko yang terdaftar."));
            }
            
            final shops = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: shops.length,
              itemBuilder: (context, index) {
                final shop = shops[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: (shop.status == 'Telah Terverifikasi' && shop.fotoProfilTokoUrl != null)
                          ? NetworkImage(shop.fotoProfilTokoUrl!)
                          : null,
                      child: (shop.status == 'Telah Terverifikasi' && shop.fotoProfilTokoUrl != null)
                          ? null 
                          : const Icon(Icons.store, color: Colors.grey),
                    ),
                    title: Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Pemilik: ${shop.user?.name ?? 'Tidak diketahui'}"),
                    trailing: Chip(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      label: Text(
                        shop.status.toUpperCase(), 
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)
                      ),
                      backgroundColor: shop.status == 'Telah Terverifikasi' 
                          ? Colors.green 
                          : (shop.status == 'Menunggu Verifikasi' ? Colors.orange.shade700 : Colors.red),
                    ),
                    onTap: () => _navigateToDetail(shop.id),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}