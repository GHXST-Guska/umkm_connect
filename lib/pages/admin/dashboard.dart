import 'package:flutter/material.dart';
import 'package:umkm_connect/pages/admin/shop_list_page.dart';
import 'package:umkm_connect/pages/admin/user_list_page.dart'; 
import 'package:umkm_connect/pages/admin/content_list_page.dart'; 
import 'package:umkm_connect/pages/admin/order_list_page.dart'; 
import 'package:umkm_connect/pages/login_page.dart';
import 'package:umkm_connect/services/api_static.dart';

// Mengubah menjadi StatefulWidget untuk bisa menggunakan state dan memanggil ApiService
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  // Membuat instance dari ApiService
  final APIStatic _api = APIStatic();

  // Fungsi untuk menangani proses logout
  void _logout(BuildContext context) async {
    // Tampilkan dialog konfirmasi sebelum logout
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // Jika pengguna tidak menekan 'Logout', hentikan proses
    if (confirm != true) return;

    try {
      await _api.logout();
      if (!mounted) return;
      // Arahkan ke halaman login dan hapus semua halaman sebelumnya
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal logout: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Daftar menu untuk dashboard admin
    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Validasi Toko', 'icon': Icons.store_mall_directory, 'page': const ShopListPage()},
      {'title': 'Manajemen Pengguna', 'icon': Icons.people, 'page': const UserListPage()},
      {'title': 'Manajemen Konten', 'icon': Icons.article, 'page': const ContentListPage()},
      {'title': 'Semua Pesanan', 'icon': Icons.receipt_long, 'page': const OrderListPage()},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.indigo,
        // Menambahkan tombol aksi di AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return GestureDetector(
            onTap: () {
              // Navigasi ke halaman yang sesuai saat menu diklik
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => item['page']),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icon'], size: 48, color: Colors.indigo),
                  const SizedBox(height: 12),
                  Text(
                    item['title'], 
                    textAlign: TextAlign.center, 
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}