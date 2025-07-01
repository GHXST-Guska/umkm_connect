import 'package:flutter/material.dart';
import 'package:umkm_connect/models/shop_model.dart';
import 'package:umkm_connect/models/user_model.dart';
import 'package:umkm_connect/pages/admin/content_list_page.dart';
import 'package:umkm_connect/pages/admin/order_list_page.dart';
import 'package:umkm_connect/pages/admin/shop_detail_page.dart';
import 'package:umkm_connect/pages/admin/shop_list_page.dart';
import 'package:umkm_connect/pages/admin/user_list_page.dart';
import 'package:umkm_connect/pages/login_page.dart';
import 'package:umkm_connect/services/api_static.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final APIStatic _api = APIStatic();
  UserProfile? _adminProfile;
  List<ShopModel> _pendingShops = [];

  @override
  void initState() {
    super.initState();
    _loadProfileAndShops();
  }

  Future<void> _loadProfileAndShops() async {
    try {
      final profile = await _api.getUserProfile();
      final allShops = await _api.getAllShops();
      final filtered = allShops.where((shop) => shop.status == 'Menunggu Verifikasi').toList();

      setState(() {
        _adminProfile = profile;
        _pendingShops = filtered;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  void _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Yakin ingin keluar?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Logout", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    await _api.logout();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Validasi Toko', 'icon': Icons.store, 'page': const ShopListPage(), 'colors': [Colors.purple, Colors.deepPurple]},
      {'title': 'Manajemen Pengguna', 'icon': Icons.people, 'page': const UserListPage(), 'colors': [Colors.orange, Colors.deepOrange]},
      {'title': 'Manajemen Konten', 'icon': Icons.play_circle_fill, 'page': const ContentListPage(), 'colors': [Colors.green, Colors.teal]},
      {'title': 'Semua Pesanan', 'icon': Icons.shopping_cart, 'page': const OrderListPage(), 'colors': [Colors.indigo, Colors.blueAccent]},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6FA),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Halo admin', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    Text(
                      _adminProfile?.name ?? 'Loading...',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  tooltip: 'Logout',
                  onPressed: () => _logout(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Menu Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: menuItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return GestureDetector(
                  onTap: () {
                    if (item['page'] != null) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => item['page']));
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: List<Color>.from(item['colors']),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item['icon'], size: 40, color: Colors.white),
                        const SizedBox(height: 8),
                        Text(item['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 36),

            // Notifikasi Validasi Toko
            const Text('Toko Belum Divalidasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_pendingShops.isEmpty)
              const Text('Semua toko telah divalidasi.')
            else
              ..._pendingShops.map((shop) => Card(
                    child: ListTile(
                      title: Text(shop.name),
                      subtitle: Text('Status: ${shop.status}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ShopDetailPage(shopId: shop.id)),
                        );
                      },
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
