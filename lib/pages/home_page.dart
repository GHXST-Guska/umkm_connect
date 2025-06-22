import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:umkm_connect/services/api_static.dart';
import 'package:umkm_connect/models/umkm_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final APIStatic _api = APIStatic();
  List<UMKMService> _allUMKM = [];

  @override
  void initState() {
    super.initState();
    _loadUMKM();
  }

  Future<void> _loadUMKM() async {
    try {
      final data = await _api.getUmkmList();
      setState(() {
        _allUMKM = data;
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
    final populer = _allUMKM.take(5).toList();
    final diskon = _allUMKM.where((e) => e.price < 50000).take(5).toList();

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
            _buildHorizontalList(diskon),
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

  Widget _buildHorizontalList(List<UMKMService> list) {
    return SizedBox(
      height: 180,
      child: list.isEmpty
          ? const Center(child: Text("Tidak ada data."))
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = list[index];
                return SizedBox(
                  width: 140,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gambar
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          child: Image.network(
                            "http://192.168.18.35:8000/storage/product/${item.image}",
                            height: 80,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text('Rp ${item.price}',
                                  style: const TextStyle(color: Colors.pink)),
                              Text('⭐ 4.9',
                                  style: TextStyle(color: Colors.orange.shade400)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
