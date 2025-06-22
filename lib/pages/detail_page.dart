import 'package:flutter/material.dart';
import 'package:umkm_connect/models/umkm_model.dart';
import 'package:umkm_connect/services/api_static.dart';

class DetailPage extends StatelessWidget {
  final UMKMService item;

  const DetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: const Text('Detail Produk'),
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
              'http://192.168.18.35:8000/storage/product/${item.image}',
              height: 200,
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
              const Text('4.8'),
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
              const Icon(Icons.shopping_cart, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Text(item.category),
            ],
          ),
          const SizedBox(height: 16),

          // 📝 Deskripsi
          const Text(
            'Deskripsi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            item.description,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 20),

          // 💬 Komentar & Penilaian
          const Text(
            'Komentar & Penilaian',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildDummyComment("Bagus banget! Sangat membantu UMKM."),
          _buildDummyComment("Produk cepat sampai dan sesuai deskripsi."),
          _buildDummyComment("Penjual responsif dan ramah."),
          const SizedBox(height: 20),

          // 🛍️ Rekomendasi Serupa
          const Text(
            'Rekomendasi Serupa',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<UMKMService>>(
            future: APIStatic().getUmkmList(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || snapshot.data == null) {
                return const Text("Gagal memuat rekomendasi.");
              }

              // Filter rekomendasi berdasarkan kategori/kesamaan
              final similar = snapshot.data!
                  .where((e) =>
                      e.category == item.category && e.title != item.title)
                  .take(5)
                  .toList();

              if (similar.isEmpty) {
                return const Text('Tidak ada rekomendasi serupa.');
              }

              return SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: similar.length,
                  itemBuilder: (context, index) {
                    final simItem = similar[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailPage(item: simItem),
                          ),
                        );
                      },
                      child: Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12),
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Image.network(
                                  'http://192.168.18.35:8000/storage/product/${simItem.image}',
                                  height: 80,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.broken_image,
                                      size: 40),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(simItem.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rp ${simItem.price}',
                                      style:
                                          const TextStyle(color: Colors.pink),
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
          ),
        ],
      ),
    );
  }

  Widget _buildDummyComment(String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.person, color: Colors.grey),
        title: const Text('Pengguna'),
        subtitle: Text(content),
      ),
    );
  }
}
