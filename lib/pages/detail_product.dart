import 'package:flutter/material.dart';
import 'package:umkm_connect/models/product_model.dart';
import 'package:umkm_connect/services/api_static.dart';

class DetailProduct extends StatelessWidget {
  final ProductModel item;

  const DetailProduct({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6FA),
      appBar: AppBar(
        title: Text("Produk"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.pink,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), // beri padding bawah agar shadow terlihat
        children: [
          // 🖼 Gambar besar
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              item.imageUrl ?? '',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 60),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 🏷 Nama Produk
          Text(
            item.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // ⭐ Rating & 💰 Harga
          Row(
            children: [
              Icon(Icons.star, color: Colors.orange.shade400, size: 20),
              const SizedBox(width: 4),
              Text(item.rating),
              const Spacer(),
              Text(
                'Rp ${item.price}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 📍 Lokasi dan Kategori
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Text(item.location),
              const Spacer(),
              const Icon(Icons.category, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Text(item.category),
            ],
          ),
          const SizedBox(height: 16),

          // 📝 Deskripsi
          const Text(
            'Deskripsi Produk',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            item.description,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 20),

          // 🛍️ Rekomendasi
          const Text(
            'Rekomendasi Serupa',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          _buildSimilarProducts(item),
          const SizedBox(height: 20), // agar card terakhir tidak terpotong
        ],
      ),
    );
  }

  Widget _buildSimilarProducts(ProductModel item) {
    return FutureBuilder<List<ProductModel>>(
      future: APIStatic().getAllProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: SizedBox(height: 100, child: CircularProgressIndicator()));
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("Gagal memuat rekomendasi.");
        }

        final similar = snapshot.data!
            .where((e) => e.category == item.category && e.id != item.id)
            .take(5)
            .toList();

        if (similar.isEmpty) {
          return const Text('Tidak ada rekomendasi serupa.');
        }

        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 16),
            itemCount: similar.length,
            itemBuilder: (context, index) {
              final simItem = similar[index];
              return Container(
                width: 140,
                margin: const EdgeInsets.only(left: 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailProduct(item: simItem),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            simItem.imageUrl ?? '',
                            height: 80,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox(
                              height: 80,
                              child: Center(child: Icon(Icons.broken_image)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                simItem.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${simItem.price}',
                                style: const TextStyle(color: Colors.pink),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
