import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:umkm_connect/models/umkm_model.dart';

class APIStatic {
  // Ganti dengan IP address sesuai dengan server API Yudik
  // final String _baseUrl = "http://192.168.18.35:8000/";
  final String _baseUrl = "http://10.23.2.97:8000/";
  final _storage = const FlutterSecureStorage();

  // Method untuk menyimpan token
  Future<void> _saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  // Method untuk mendapatkan token
  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Method untuk menghapus token (logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: 'access_token');
  }

  // Fungsi Register
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final url = Uri.parse('$_baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'email': email, 'password': password}),
    );

    final responseData = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Jika register berhasil dan langsung login (seperti di kode Anda)
      if (responseData.containsKey('access_token')) {
        await _saveToken(responseData['access_token']);
      }
      return responseData;
    } else {
      // Jika gagal, lempar error dengan pesan dari server
      throw Exception(responseData['massage'] ?? 'Gagal untuk register');
    }
  }

  // Fungsi Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    final responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      // Jika login berhasil, simpan token
      if (responseData.containsKey('access_token')) {
        await _saveToken(responseData['access_token']);
      }
      return responseData;
    } else {
      throw Exception(responseData['message'] ?? 'Gagal untuk login');
    }
  }

  // Fungsi Logout
  Future<void> logout() async {
    final token = await getToken();
    final url = Uri.parse('$_baseUrl/logout');

    await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // Hapus token dari storage lokal
    await deleteToken();
  }

  // Fungsi untuk mendapatkan data user (endpoint terproteksi)
  Future<Map<String, dynamic>> getUserProfile() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }

    final url = Uri.parse('$_baseUrl/user-profile');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Sertakan token di sini
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // Di sini Anda bisa menambahkan logika untuk refresh token jika status code 401
      throw Exception('Gagal mengambil data user.');
    }
  }

  Future<List<UMKMService>> getUmkmList() async {
    final token = await getToken();
    final url = Uri.parse(
      '${_baseUrl}product/getall',
    ); // Ganti endpoint sesuai backend

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data']; // Ganti sesuai struktur JSON
      return list.map((e) => UMKMService.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data UMKM');
    }
  }
}
