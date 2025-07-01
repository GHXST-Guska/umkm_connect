import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:umkm_connect/pages/admin/admin_dashboard.dart';
import 'package:umkm_connect/pages/login_page.dart';
import 'package:umkm_connect/pages/main_menu.dart';
import 'package:umkm_connect/services/api_static.dart';

// Inisialisasi locale untuk pemformatan tanggal
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UMKM Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.pink.shade600,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.pink)
            .copyWith(secondary: Colors.pinkAccent),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final APIStatic _api = APIStatic();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // FUNGSI INI SUDAH DISESUAIKAN DENGAN ROLE
  Future<void> _checkLoginStatus() async {
    // Beri jeda agar splash screen terlihat
    await Future.delayed(const Duration(seconds: 3));
    
    final token = await _api.getToken();

    // Cek jika token ada
    if (token != null && token.isNotEmpty) {
      try {
        // Jika token ada, coba ambil profil untuk mendapatkan role
        final userProfile = await _api.getUserProfile();
        final role = userProfile.role;
        
        if (!mounted) return; // Pastikan widget masih ada

        if (role == 'admin') {
          // Jika admin, ke dashboard admin
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
          );
        } else {
          // Jika bukan admin, ke halaman utama
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainPage()),
          );
        }
      } catch (e) {
        // Jika gagal ambil profil (misal: token kedaluwarsa), arahkan ke Login
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } else {
      // Jika token tidak ada, arahkan ke Login
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan UI Splash Screen tidak ada yang berubah
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.pink.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.storefront, size: 60, color: Colors.pink.shade700),
            ),
            const SizedBox(height: 20),
            Text(
              "UMKM Connect",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.pink.shade700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Solusi Digital UMKM Indonesia",
              style: TextStyle(
                fontSize: 14,
                color: Colors.pink.shade400,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 32),
            CircularProgressIndicator(
              color: Colors.pink.shade400,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}