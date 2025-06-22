import 'package:flutter/material.dart';
import 'package:umkm_connect/services/api_static.dart';
import 'package:umkm_connect/models/umkm_model.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final APIStatic _api = APIStatic();
  List<UMKMService> _allProducts = [];
  List<UMKMService> _filteredProducts = [];

  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'Semua';
  String _selectedPrice = 'Semua';
  String _selectedLocation = 'Semua';

  final List<String> _kategoriList = ['Semua', 'Makanan', 'Minuman', 'Fashion', 'Kerajinan', 'Jasa'];
  final List<String> _priceRange = ['Semua', '< 50K', '50K - 100K', '> 100K'];
  final List<String> _locations = ['Semua', 'Denpasar', 'Singaraja', 'Tabanan', 'Badung'];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(() {
      _applyFilters();
    });
  }

  Future<void> _loadProducts() async {
    try {
      final data = await _api.getUmkmList();
      setState(() {
        _allProducts = data;
        _filteredProducts = data;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat produk: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((item) {
        final matchText = item.title.toLowerCase().contains(query);
        final matchCategory = _selectedCategory == 'Semua' || item.description.toLowerCase().contains(_selectedCategory.toLowerCase());
        final matchLocation = _selectedLocation == 'Semua' || item.description.toLowerCase().contains(_selectedLocation.toLowerCase());
        final price = item.price;
        final matchPrice = _selectedPrice == 'Semua' ||
            (_selectedPrice == '< 50K' && price < 50000) ||
            (_selectedPrice == '50K - 100K' && price >= 50000 && price <= 100000) ||
            (_selectedPrice == '> 100K' && price > 100000);

        return matchText && matchCategory && matchLocation && matchPrice;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header + Search
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Cari produk atau jasa...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Filter Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(child: _buildDropdown('Kategori', _selectedCategory, _kategoriList, (val) {
                    setState(() {
                      _selectedCategory = val!;
                      _applyFilters();
                    });
                  })),
                  const SizedBox(width: 8),
                  Expanded(child: _buildDropdown('Harga', _selectedPrice, _priceRange, (val) {
                    setState(() {
                      _selectedPrice = val!;
                      _applyFilters();
                    });
                  })),
                  const SizedBox(width: 8),
                  Expanded(child: _buildDropdown('Lokasi', _selectedLocation, _locations, (val) {
                    setState(() {
                      _selectedLocation = val!;
                      _applyFilters();
                    });
                  })),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Grid Produk
            Expanded(
              child: _filteredProducts.isEmpty
                  ? const Center(child: Text('Tidak ada produk ditemukan.'))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: GridView.builder(
                        itemCount: _filteredProducts.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemBuilder: (context, index) {
                          final item = _filteredProducts[index];
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                  child: Image.network(
                                    "http://192.168.18.35:8000/storage/product/${item.image}",
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const SizedBox(
                                      height: 120,
                                      child: Center(child: Icon(Icons.broken_image)),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.title,
                                          style: const TextStyle(fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 4),
                                      Text('Rp ${item.price}', style: TextStyle(color: Colors.pink.shade600)),
                                      const SizedBox(height: 4),
                                      Text('📍 ${item.location}', maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const Text('⭐ 4.9'),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.black, // pastikan teks terlihat
      ),
      dropdownColor: Colors.white,
      items: items.map((e) {
        return DropdownMenuItem<String>(
          value: e,
          child: Text(
            e,
            style: const TextStyle(fontSize: 15, color: Colors.black),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 17, color: Colors.black54),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
