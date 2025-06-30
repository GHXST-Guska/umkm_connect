import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:umkm_connect/services/api_static.dart';
import 'package:umkm_connect/pages/main_page.dart';
import 'package:umkm_connect/pages/admin/dashboard.dart'; // Pastikan Anda sudah membuat halaman ini

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final APIStatic _api = APIStatic();
  Duration get loginTime => const Duration(milliseconds: 2250);

  // Fungsi ini hanya bertugas untuk login dan menyimpan token.
  // Jika berhasil, kembalikan null. Jika gagal, kembalikan pesan error.
  Future<String?> _authUser(LoginData data) async {
    try {
      // Panggil API login
      final response = await _api.login(data.name, data.password);
      
      // Cek jika API mengembalikan token, pertanda login berhasil
      if (response.containsKey('access_token')) {
        return null; // Sukses
      } else {
        return response['message'] ?? 'Login gagal: Token tidak ditemukan.';
      }
    } catch (e) {
      // Tangkap error dari API service (misal: "User tidak ditemukan")
      return e.toString().replaceFirst("Exception: ", "");
    }
  }

  Future<String?> _recoverPassword(String name) async {
    // Logika untuk lupa password
    return 'Fitur ini belum tersedia.';
  }

  // Navigasi setelah login sukses berdasarkan role
  void _navigateBasedOnRole() async {
    try {
      // Ambil data profil pengguna yang baru saja login
      final userProfile = await _api.getUserProfile();
      final role = userProfile['role'];

      if (!mounted) return; // Pastikan widget masih ada di tree

      if (role == 'admin') {
        // Jika role adalah 'admin', arahkan ke Dashboard Admin
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminDashboardPage()),
        );
      } else {
        // Jika role lain ('normal', dll), arahkan ke Halaman Utama
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      }
    } catch (e) {
      // Handle jika gagal mengambil profil setelah login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memverifikasi role: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'UMKM Connect',
      onLogin: _authUser,
      onSignup: (data) async => 'Fitur daftar belum diimplementasikan.', // Signup
      onRecoverPassword: _recoverPassword,
      
      // Ini adalah bagian kunci: dieksekusi setelah onLogin berhasil (mengembalikan null)
      onSubmitAnimationCompleted: _navigateBasedOnRole,

      theme: LoginTheme(
        // ... (semua konfigurasi theme Anda tetap sama seperti sebelumnya) ...
        primaryColor: Colors.pink.shade600,
        accentColor: Colors.pinkAccent,
        errorColor: Colors.redAccent,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
        cardTheme: CardTheme(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        buttonTheme: LoginButtonTheme(
          splashColor: Colors.pinkAccent,
          backgroundColor: Colors.pink.shade600,
          highlightColor: Colors.pink.shade700,
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        pageColorLight: Colors.pink.shade50,
        pageColorDark: Colors.pink.shade900,
      ),
    );
  }
}