import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:umkm_connect/services/api_static.dart';
import 'package:umkm_connect/models/product_model.dart';
import 'package:umkm_connect/pages/detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final APIStatic _api = APIStatic();
  List<ProductModel> _allProducts = []; // Ganti nama variabel agar lebih jelas

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      // Panggil method yang benar dari API service
      final data = await _api.getAllProducts(); 
      setState(() {
        _allProducts = data;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final populer = _allProducts.take(5).toList();
    // final diskon = _allProducts.where((e) => e.price < 50000).take(5).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6FA),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            _buildCarousel(),
            _buildSectionTitle('🔥 Terpopuler'),
            _buildHorizontalList(populer),
            _buildSectionTitle('🎓 Yuk Belajar Lagi!'),
            // Untuk section kedua, Anda mungkin ingin menampilkan data yang berbeda,
            // misalnya konten edukasi, bukan produk diskon.
            // Namun untuk saat ini kita gunakan data yang sama.
            _buildHorizontalList(populer),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    final bannerImages = ['assets/banner1.jpg', 'assets/banner2.jpg', 'assets/banner3.jpg'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CarouselSlider.builder(
          itemCount: bannerImages.length,
          itemBuilder: (context, index, realIdx) {
            return Image.asset(
              bannerImages[index],
              fit: BoxFit.cover,
              width: double.infinity,
            );
          },
          options: CarouselOptions(
            height: 160,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {IconData? withIcon}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
      child: Row(
        children: [
          if (withIcon != null) ...[
            Icon(withIcon, color: Colors.pink, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List<ProductModel> list) {
    return SizedBox(
      height: 180,
      child: list.isEmpty
          ? const Center(child: Text("Memuat data..."))
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = list[index];
                return SizedBox(
                  width: 140,
                  // TAMBAHKAN GESTUREDETECTOR UNTUK NAVIGASI
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPage(item: item),
                        ),
                      );
                    },
                    child: Card(
                      // ... (sisa Card tetap sama) ...
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                            // GUNAKAN imageUrl dari model
                            child: Image.network(
                              item.imageUrl ?? '', // Gunakan URL dari accessor
                              height: 80,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title, // DIUBAH dari title ke name
                                  maxLines: 2, // Beri ruang lebih untuk nama
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text('Rp ${item.price}', style: const TextStyle(color: Colors.pink)),
                                // ... (sisa Text widget tetap sama) ...
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
