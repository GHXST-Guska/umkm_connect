import 'package:flutter/material.dart';
import 'package:umkm_connect/pages/login_page.dart';
import 'package:umkm_connect/pages/main_menu.dart';
import 'package:umkm_connect/services/api_static.dart';

void main() {
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

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    final token = await _api.getToken();

    if (token != null && token.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🏪 Icon/logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.pink.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.storefront,
                  size: 60, color: Colors.pink.shade700),
            ),
            const SizedBox(height: 20),

            // 📝 Judul App
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

            // 🧾 Tagline
            Text(
              "Solusi Digital UMKM Indonesia",
              style: TextStyle(
                fontSize: 14,
                color: Colors.pink.shade400,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 32),

            // 🔄 Loading indicator
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
