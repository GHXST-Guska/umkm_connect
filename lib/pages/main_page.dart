import 'package:flutter/material.dart';
import 'package:umkm_connect/pages/home_page.dart';
import 'package:umkm_connect/pages/product_page.dart';
import 'package:umkm_connect/pages/login_page.dart';
import 'package:umkm_connect/pages/profile_page.dart';
import 'package:umkm_connect/pages/video_page.dart';
import 'package:umkm_connect/services/api_static.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final APIStatic _api = APIStatic();

  final List<Widget> _pages = const [
    HomePage(),
    ProductPage(),
    VideoPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout(BuildContext context) async {
    try {
      await _api.logout();
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Tutup drawer
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal logout: $e')),
        );
      }
    }
  }

  void _goToProfilePage() {
    setState(() {
      _selectedIndex = 3; // ⬅️ Index untuk ProfilePage
    });
    Navigator.of(context).pop(); // ⬅️ Tutup drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.pink.shade600),
              child: const Text(
                'Fast Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.face),
              title: const Text('Teman saya'),
              onTap: _goToProfilePage, // ✅ Navigasi ke profil
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Kelola toko'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text('Top-up saldo'),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Smart UMKM'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.pink.shade600,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.pink.shade600,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
