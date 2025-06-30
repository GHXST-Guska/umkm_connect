import 'package:flutter/material.dart';
import 'package:umkm_connect/models/shop_model.dart';
import 'package:umkm_connect/services/api_static.dart';

class ShopDetailPage extends StatefulWidget {
  final int shopId;
  const ShopDetailPage({super.key, required this.shopId});

  @override
  State<ShopDetailPage> createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends State<ShopDetailPage> {
  late Future<ShopModel> _shopFuture;
  final APIStatic _api = APIStatic();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _shopFuture = _api.getShopDetail(widget.shopId);
  }

  Future<void> _handleValidation(String status) async {
    setState(() => _isProcessing = true);
    try {
      await _api.validateShop(widget.shopId, status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Telah Terverifikasi'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(); // Kembali ke halaman list setelah berhasil
    } catch (e) {
      // Cetak error lengkap ke Debug Console
      print('VALIDATION ERROR: $e'); 

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus toko ini secara permanen?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);
    try {
      await _api.deleteShop(widget.shopId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toko berhasil dihapus'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail & Validasi Toko"),
        backgroundColor: Colors.indigo,
      ),
      body: FutureBuilder<ShopModel>(
        future: _shopFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("Data toko tidak ditemukan."));
          }
          
          final shop = snapshot.data!;
          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildDetailRow("Nama Toko:", shop.name),
                  _buildDetailRow("Nama Pemilik:", shop.user?.name ?? 'N/A'),
                  _buildDetailRow("Status:", shop.status.toUpperCase()),
                  const SizedBox(height: 20),
                  const Text("Foto KTP Pemilik:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  if (shop.fotoKtpUrl != null && shop.fotoKtpUrl!.isNotEmpty)
                    Center(child: Image.network(shop.fotoKtpUrl!))
                  else
                    const Center(child: Text("Tidak ada foto KTP.")),
                  
                  const SizedBox(height: 100), // Beri ruang untuk tombol di bawah
                ],
              ),
              // Tombol Aksi di Bagian Bawah
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: _buildActionButtons(shop),
                ),
              ),
              if (_isProcessing)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          const Text(": "),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ShopModel shop) {
    if (shop.status == 'Menunggu Verifikasi') {
      return Row(
        children: [
          Expanded(child: OutlinedButton(onPressed: _isProcessing ? null : () => _handleValidation('Ditolak'), style: OutlinedButton.styleFrom(foregroundColor: Colors.red), child: const Text("Tolak"))),
          const SizedBox(width: 16),
          Expanded(child: ElevatedButton(onPressed: _isProcessing ? null : () => _handleValidation('Telah Terverifikasi'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text("Setujui"))),
        ],
      );
    } else if (shop.status == 'Telah Terverifikasi') {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(onPressed: _isProcessing ? null : _handleDelete, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text("Hapus Toko")),
      );
    }
    // Jika status 'ditolak' atau lainnya
    return Center(child: Text("Tindakan tidak tersedia untuk status: ${shop.status}"));
  }
}