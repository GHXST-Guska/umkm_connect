// lib/pages/cart_page.dart

import 'package:flutter/material.dart';
import 'package:umkm_connect/models/cart_model.dart';
import 'package:umkm_connect/services/api_static.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final APIStatic _api = APIStatic();
  late Future<List<CartItemModel>> _cartFuture;
  
  // State untuk menyimpan item yang dipilih
  final Set<int> _selectedCartIds = {};
  int _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  void _loadCartItems() {
    setState(() {
      _cartFuture = _api.getCartItems();
      _selectedCartIds.clear();
      _calculateTotal();
    });
  }

  void _onItemSelect(bool? selected, CartItemModel item) {
    setState(() {
      if (selected == true) {
        _selectedCartIds.add(item.id);
      } else {
        _selectedCartIds.remove(item.id);
      }
      _calculateTotal();
    });
  }

  void _calculateTotal() {
    // Fungsi ini perlu akses ke daftar item, jadi kita panggil di dalam FutureBuilder
  }

  void _handleCheckout() async {
    if (_selectedCartIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk yang ingin di-checkout')),
      );
      return;
    }
    
    // Di aplikasi nyata, Anda akan meminta alamat dari dialog/halaman baru
    const address = 'Jl. Udayana No. 11, Singaraja';

    try {
      await _api.checkoutFromCart(
        cartIds: _selectedCartIds.toList(),
        shippingAddress: address,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout berhasil!'), backgroundColor: Colors.green),
      );
      _loadCartItems(); // Muat ulang keranjang setelah checkout
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal checkout: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang Saya')),
      body: FutureBuilder<List<CartItemModel>>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Keranjang Anda kosong.'));
          }

          final cartItems = snapshot.data!;
          
          // Hitung total harga setiap kali UI di-build ulang
          _totalPrice = cartItems
              .where((item) => _selectedCartIds.contains(item.id))
              .fold(0, (sum, item) => sum + (item.product.price * item.quantity));

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return _buildCartItem(item);
                  },
                ),
              ),
              _buildCheckoutBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(CartItemModel item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Checkbox(
              value: _selectedCartIds.contains(item.id),
              onChanged: (selected) => _onItemSelect(selected, item),
            ),
            Image.network(item.product.imageUrl ?? '', width: 80, height: 80, fit: BoxFit.cover),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                  Text('Rp ${item.product.price}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pink)),
                  Text('Jumlah: ${item.quantity}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total:'),
              Text('Rp $_totalPrice', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          ElevatedButton(
            onPressed: _handleCheckout,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white),
            child: Text('Checkout (${_selectedCartIds.length})'),
          ),
        ],
      ),
    );
  }
}