import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:umkm_connect/models/product_model.dart';
import 'package:umkm_connect/models/content_model.dart';
import 'package:umkm_connect/models/shop_model.dart';
import 'package:umkm_connect/models/user_model.dart';
import 'package:umkm_connect/models/order_model.dart';

class APIStatic {
  // Ganti dengan IP address sesuai dengan server API Yudik
  // final String _baseUrl = "http://192.168.18.35:8000/";
  final String _baseUrl = "http://192.168.18.35:8000/";
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
    final response = await http.post(
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

  Future<List<ProductModel>> getAllProducts() async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}product/getall');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'];
      // Menggunakan ProductModel.fromJson yang sudah kita perbaiki
      return list.map((e) => ProductModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data produk');
    }
  }

  Future<List<ContentModel>> getAllContents() async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan, silakan login.');

    // Sesuaikan endpoint jika ada prefix '/api'
    final url = Uri.parse('${_baseUrl}contents/getall');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'];
      return list.map((e) => ContentModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil daftar konten');
    }
  }

  /// ADMIN: Membuat konten baru.
  Future<void> createContent(Map<String, dynamic> data) async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}contents/save'); // Sesuaikan endpoint

    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) { // 201 Created
      throw Exception('Gagal membuat konten baru');
    }
  }

  /// ADMIN: Mengupdate konten yang sudah ada.
  Future<void> updateContent(int contentId, Map<String, dynamic> data) async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}contents/update/$contentId'); // Sesuaikan

    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) { // 200 OK
      throw Exception('Gagal mengupdate konten');
    }
  }

  /// ADMIN: Menghapus konten.
  Future<void> deleteContent(int contentId) async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}contents/delete/$contentId'); // Sesuaikan

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus konten');
    }
  }

  /// Mengambil detail satu konten berdasarkan ID.
  Future<ContentModel> getContentDetail(int contentId) async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan, silakan login.');

    // Sesuaikan endpoint jika ada prefix '/api'
    final url = Uri.parse('${_baseUrl}contents/detail/$contentId');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ContentModel.fromJson(data['data']);
    } else {
      throw Exception('Gagal mengambil detail konten');
    }
  }

  /// ADMIN: Mengambil semua data pengguna.
  Future<List<UserModel>> getAllUsers() async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}users/getall'); // Sesuaikan endpoint

    final response = await http.get(url, headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'];
      return list.map((e) => UserModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data pengguna');
    }
  }

  /// ADMIN: Mengambil detail satu pengguna.
  Future<UserModel> getUserDetail(int userId) async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}users/detail/$userId'); // Sesuaikan endpoint

    final response = await http.get(url, headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data['data']);
    } else {
      throw Exception('Gagal mengambil detail pengguna');
    }
  }

  /// ADMIN: Menghapus pengguna.
  Future<void> deleteUser(int userId) async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}users/delete/$userId'); // Sesuaikan endpoint
    
    final response = await http.delete(url, headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus pengguna');
    }
  }

  Future<List<ShopModel>> getAllShops() async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}shop/shopall'); // Ganti dengan endpoint Anda

    final response = await http.get(url, headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'];
      return list.map((e) => ShopModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data toko');
    }
  }

  /// ADMIN: Mengambil detail satu toko.
  Future<ShopModel> getShopDetail(int shopId) async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}shop/detail/$shopId'); // Ganti dengan endpoint Anda

    final response = await http.get(url, headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ShopModel.fromJson(data['data']);
    } else {
      throw Exception('Gagal mengambil detail toko');
    }
  }

  /// ADMIN: Memvalidasi toko (menyetujui atau menolak).
  Future<void> validateShop(int shopId, String newStatus) async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}shop/validasi/$shopId');
    
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode({'status': newStatus}),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal memvalidasi toko');
    }
  }

  /// ADMIN: Menghapus toko.
  Future<void> deleteShop(int shopId) async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}shop/delete/$shopId'); // Ganti dengan endpoint Anda
    
    final response = await http.delete(url, headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus toko');
    }
  }

  Future<List<OrderModel>> getAllOrders() async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}order/getall'); // Sesuaikan endpoint

    final response = await http.get(url, headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'];
      return list.map((e) => OrderModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data pesanan');
    }
  }
}
