import 'package:flutter/material.dart';
import 'package:umkm_connect/pages/product_form.dart';
import 'package:umkm_connect/services/api_static.dart';
import 'package:umkm_connect/models/product_model.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final APIStatic _api = APIStatic();
  late Future<List<ProductModel>> _productFuture;

  @override
  void initState() {
    super.initState();
    _loadMyProducts();
  }

  void _loadMyProducts() {
    setState(() {
      _productFuture = _api.getMyProducts(); // ✅ menggunakan endpoint /product/myproduct
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6FA),
      appBar: AppBar(
        title: const Text('Katalog Produk Saya'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat produk: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(child: Text('Belum ada produk.'));
          }

          return ListView.builder(
            itemCount: products.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final item = products[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      item.imageUrl ?? '',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                    ),
                  ),
                  title: Text(item.title),
                  subtitle: Text('Rp ${item.price} • ${item.category}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Tampilkan detail atau halaman edit
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormPage()),
          );
          if (result == true) _loadMyProducts(); // 🔄 refresh saat kembali
        },
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add),
      ),
    );
  }
}
