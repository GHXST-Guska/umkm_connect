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
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ShopDetailPage(shopId: shopId)),
    );
    _loadShops();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6FA),
      appBar: AppBar(
        title: const Text("Manajemen Toko"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
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
              return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Belum ada toko yang terdaftar."));
            }

            final shops = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: shops.length,
              itemBuilder: (context, index) {
                final shop = shops[index];
                final isVerified = shop.status == 'Telah Terverifikasi';

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: (isVerified && shop.fotoProfilTokoUrl != null)
                          ? NetworkImage(shop.fotoProfilTokoUrl!)
                          : null,
                      child: (isVerified && shop.fotoProfilTokoUrl != null)
                          ? null
                          : const Icon(Icons.store, color: Colors.grey),
                    ),
                    title: Text(
                      shop.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text("Pemilik: ${shop.user?.name ?? 'Tidak diketahui'}"),
                    ),
                    trailing: Icon(
                      isVerified ? Icons.check_circle : Icons.error_outline,
                      color: isVerified ? Colors.green : Colors.red,
                      size: 28,
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
