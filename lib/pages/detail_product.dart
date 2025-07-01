import 'package:flutter/material.dart';
import 'package:umkm_connect/models/product_model.dart';
import 'package:umkm_connect/services/api_static.dart';
import 'package:umkm_connect/pages/quantitySelectionSheet.dart';

class DetailProduct extends StatelessWidget {
  final ProductModel item;

  const DetailProduct({super.key, required this.item});

  // Fungsi untuk menampilkan Bottom Sheet
  void _showQuantityBottomSheet(BuildContext context, {required bool isBuyNow}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Penting agar sheet tidak tertutup keyboard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Gunakan widget terpisah agar state-nya tidak tercampur
        return QuantitySelectionSheet(
          product: item,
          isBuyNow: isBuyNow,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6FA),
      // Gunakan Stack untuk menumpuk tombol di atas body
      body: Stack(
        children: [
          // Konten Utama yang bisa di-scroll
          ListView(
            // Beri padding bawah seukuran tombol
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 80), 
            children: [
              _buildProductImage(),
              _buildProductInfo(),
            ],
          ),
          // Tombol Aksi di Bagian Bawah
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Stack(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: Image.network(
            item.imageUrl ?? '',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
            ),
          ),
        ),
        // Tombol kembali
        Positioned(
          top: 40,
          left: 16,
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.5),
            child: BackButton(color: Colors.white),
          ),
        ),
      ],
    );
  }
  
  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Harga Produk
          Text(
            'Rp ${item.price}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.pink),
          ),
          const SizedBox(height: 8),

          // Nama Produk
          Text(
            item.title, // PERBAIKAN: Gunakan .name
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Rating & Stok
          Row(
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 20),
              const SizedBox(width: 4),
              Text('4.9 (rating)'), // Anda bisa menambahkan rating di model
              const SizedBox(width: 16),
              const Icon(Icons.inventory_2, color: Colors.grey, size: 20),
              const SizedBox(width: 4),
              Text('Stok: ${item.stock}'),
            ],
          ),
          const Divider(height: 32),
          
          // Deskripsi
          const Text('Deskripsi Produk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          Text(item.description, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 20),

          // Rekomendasi
          const Text('Rekomendasi Serupa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _buildSimilarProducts(item),
        ],
      ),
    );
  }

  // Widget untuk tombol aksi di bawah
  Widget _buildActionButtons(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 70,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Ke Keranjang'),
                onPressed: () => _showQuantityBottomSheet(context, isBuyNow: false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.pink,
                  side: const BorderSide(color: Colors.pink),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                child: const Text('Beli Sekarang'),
                onPressed: () => _showQuantityBottomSheet(context, isBuyNow: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  
  // Widget _buildSimilarProducts tidak berubah
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