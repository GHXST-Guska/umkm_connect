import 'package:flutter/material.dart';
import 'package:umkm_connect/models/user_model.dart';
import 'package:umkm_connect/pages/admin/shop_list_page.dart';
import 'package:umkm_connect/pages/admin/user_list_page.dart';
import 'package:umkm_connect/pages/admin/content_list_page.dart';
import 'package:umkm_connect/pages/admin/order_list_page.dart';
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

  @override
  void initState() {
    super.initState();
    _loadAdminProfile();
  }

  Future<void> _loadAdminProfile() async {
    try {
      final profile = await _api.getUserProfile();
      if (mounted) {
        setState(() {
          _adminProfile = profile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sesi tidak valid: $e')),
        );
        _logout(context, showConfirmation: false);
      }
    }
  }

  void _logout(BuildContext context, {bool showConfirmation = true}) async {
    bool confirm = true;
    if (showConfirmation) {
      confirm = await showDialog<bool>(
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
      ) ?? false;
    }

    if (!confirm) return;

    try {
      await _api.logout();
      if (!mounted) return;
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
    final List<Map<String, dynamic>> menuItems = [
      {'title': 'Validasi Toko', 'icon': Icons.store_mall_directory, 'page': const ShopListPage()},
      {'title': 'Manajemen Pengguna', 'icon': Icons.people, 'page': const UserListPage()},
      {'title': 'Manajemen Konten', 'icon': Icons.article, 'page': const ContentListPage()},
      {'title': 'Semua Pesanan', 'icon': Icons.receipt_long, 'page': const OrderListPage()},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                _adminProfile?.name ?? 'Admin',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: Text(_adminProfile?.email ?? 'Memuat...'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: (_adminProfile?.pathImageUrl != null && _adminProfile!.pathImageUrl!.isNotEmpty)
                    ? NetworkImage(_adminProfile!.pathImageUrl!)
                    : null,
                child: (_adminProfile?.pathImageUrl == null || _adminProfile!.pathImageUrl!.isEmpty)
                    ? Icon(Icons.shield_outlined, size: 48, color: Colors.pink.shade700)
                    : null,
              ),
              decoration: const BoxDecoration(
                color: Colors.pink,
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context); // Tutup drawer dulu
                _logout(context);
              },
            ),
          ],
        ),
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
                  Icon(item['icon'], size: 48, color: Colors.pink),
                  const SizedBox(height: 12),
                  Text(
                    item['title'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
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