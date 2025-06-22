import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:umkm_connect/services/api_static.dart';
import 'package:umkm_connect/pages/main_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key}); // ✅ gunakan const

  Duration get loginTime => const Duration(milliseconds: 2250);
  static const Color magenta = Color(0xFFE91E63); // 🌸 warna magenta

  Future<String?> _authUser(LoginData data) async {
    try {
      final api = APIStatic();
      final response = await api.login(data.name, data.password);
      if (response.containsKey('access_token')) {
        return null;
      } else {
        return 'Login gagal: Token tidak ditemukan.';
      }
    } catch (e) {
      return 'Login gagal: ${e.toString()}';
    }
  }

  Future<String?> _signUpUser(SignupData data) async {
    await Future.delayed(loginTime);
    return 'Fitur daftar belum tersedia.';
  }

  Future<String?> _recoverPassword(String name) async {
    return 'Fitur reset sandi belum tersedia.';
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'UMKM Connect',
      // logo: 'assets/logo_umkm.png', // opsional kalau ada logo
      onLogin: _authUser,
      onSignup: _signUpUser,
      onRecoverPassword: _recoverPassword,
      onSubmitAnimationCompleted: () {
        // 🟢 Navigasi setelah login sukses
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      },
      theme: LoginTheme(
        primaryColor: magenta,
        accentColor: Colors.pinkAccent,
        errorColor: Colors.redAccent,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
        bodyStyle: const TextStyle(
          fontStyle: FontStyle.normal,
          decoration: TextDecoration.none,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        buttonStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        buttonTheme: LoginButtonTheme(
          splashColor: Colors.pinkAccent,
          backgroundColor: magenta,
          highlightColor: Colors.pink.shade700,
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        pageColorLight: Colors.pink.shade50,
        pageColorDark: Colors.pink.shade900,
        beforeHeroFontSize: 14,
        afterHeroFontSize: 20,
      ),
    );
  }
}
