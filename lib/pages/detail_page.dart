import 'package:flutter/material.dart';
import 'package:umkm_connect/models/product_model.dart';
import 'package:umkm_connect/services/api_static.dart';

class DetailPage extends StatelessWidget {
  final ProductModel item;

  const DetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: Text(item.title), // Judul AppBar sesuai nama produk
        backgroundColor: Colors.white,
        foregroundColor: Colors.pink,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
              const Text('4.8 (rating)'), // Anda bisa menambahkan rating di model
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

          // 📍 Lokasi dan 🏷 Kategori
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

          // 🛍️ Rekomendasi Serupa
          const Text(
            'Rekomendasi Serupa',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          _buildSimilarProducts(),
        ],
      ),
    );
  }

  Widget _buildSimilarProducts() {
    return FutureBuilder<List<ProductModel>>(
      future: APIStatic().getAllProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: SizedBox(height: 100, child: CircularProgressIndicator()));
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("Gagal memuat rekomendasi.");
        }

        // Filter rekomendasi berdasarkan kategori yang sama, dan bukan produk ini sendiri
        final similar = snapshot.data!
            .where((e) => e.category == item.category && e.id != item.id)
            .take(5)
            .toList();

        if (similar.isEmpty) {
          return const Text('Tidak ada rekomendasi serupa.');
        }

        return SizedBox(
          height: 180, // Sesuaikan tinggi agar pas
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: similar.length,
            itemBuilder: (context, index) {
              final simItem = similar[index];
              return SizedBox(
                width: 140,
                child: GestureDetector(
                  onTap: () {
                    // Gunakan pushReplacement agar tidak menumpuk halaman detail
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPage(item: simItem),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            simItem.imageUrl ?? '',
                            height: 80,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox(
                                height: 80,
                                child: Center(child: Icon(Icons.broken_image, size: 40))),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(simItem.title,
                                  maxLines: 2, // Beri ruang lebih
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w500)),
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