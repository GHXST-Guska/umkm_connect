import 'package:flutter/material.dart';
import 'package:umkm_connect/models/product_model.dart';
import 'package:umkm_connect/services/api_static.dart';

class QuantitySelectionSheet extends StatefulWidget {
  final ProductModel product;
  final bool isBuyNow;

  const QuantitySelectionSheet({
    super.key,
    required this.product,
    required this.isBuyNow,
  });

  @override
  State<QuantitySelectionSheet> createState() => _QuantitySelectionSheetState();
}

class _QuantitySelectionSheetState extends State<QuantitySelectionSheet> {
  int _quantity = 1;
  bool _isLoading = false;
  final APIStatic _api = APIStatic();

  void _increment() {
    if (_quantity < widget.product.stock) {
      setState(() => _quantity++);
    }
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      if (widget.isBuyNow) {
        // Logika Beli Sekarang
        // Anda perlu membuat halaman baru untuk checkout, 
        // di sini kita hanya tampilkan pesan sukses
        await _api.directOrder(productId: widget.product.id, quantity: _quantity);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Pesanan berhasil dibuat!'),
          backgroundColor: Colors.green,
        ));
      } else {
        // Logika Tambah ke Keranjang
        await _api.addToCart(productId: widget.product.id, quantity: _quantity);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Berhasil ditambahkan ke keranjang!'),
          backgroundColor: Colors.green,
        ));
      }
      if (mounted) Navigator.pop(context); // Tutup bottom sheet
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.product.imageUrl ?? '',
                  width: 80, height: 80, fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rp ${widget.product.price}', style: const TextStyle(color: Colors.pink, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Stok: ${widget.product.stock}'),
                ],
              )
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Jumlah'),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.remove), onPressed: _decrement, color: Colors.pink),
                    Text('$_quantity'),
                    IconButton(icon: const Icon(Icons.add), onPressed: _increment, color: Colors.pink),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink, 
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12)
              ),
              child: _isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : Text(widget.isBuyNow ? 'Beli Sekarang' : 'Masukkan Keranjang'),
            ),
          )
        ],
      ),
    );
  }
}