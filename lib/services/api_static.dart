import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:umkm_connect/models/product_model.dart';
import 'package:umkm_connect/models/content_model.dart';
import 'package:umkm_connect/models/shop_model.dart';
import 'package:umkm_connect/models/user_model.dart';
import 'package:umkm_connect/models/order_model.dart';

class APIStatic {
  final String _baseUrl = "http://192.168.18.35:8000/";
  final _storage = const FlutterSecureStorage();

  // ✅ Menyimpan token login
  Future<void> _saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  // ✅ Mengambil token
  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  // ✅ Hapus token (logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: 'access_token');
  }

  // ✅ Register
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
      if (responseData.containsKey('access_token')) {
        await _saveToken(responseData['access_token']);
      }
      return responseData;
    } else {
      throw Exception(responseData['message'] ?? 'Gagal melakukan registrasi');
    }
  }

  // ✅ Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    final responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      if (responseData.containsKey('access_token')) {
        await _saveToken(responseData['access_token']);
      }
      return responseData;
    } else {
      throw Exception(responseData['message'] ?? 'Login gagal');
    }
  }

  // ✅ Logout
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
    await deleteToken();
  }

  Future<UserProfile> updateUserProfile({
    required String name,
    required String email,
    String? password,
    File? imageFile,
  }) async {
    final token = await getToken();
    final url = Uri.parse('$_baseUrl/users/updateProfile');

    final request =
        http.MultipartRequest('POST', url)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['name'] = name
          ..fields['email'] = email;

    if (password != null && password.isNotEmpty) {
      request.fields['password'] = password;
    }

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('path_image', imageFile.path),
      );
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(body);
      return UserProfile.fromJson(data['data']);
    } else {
      final error = jsonDecode(body);
      throw Exception(error['message'] ?? 'Gagal memperbarui profil');
    }
  }

  // ✅ Bikin toko
  Future<ShopModel> createShop({
    required String name,
    required File ktpFile,
  }) async {
    final token = await getToken();
    final url = Uri.parse('$_baseUrl/shop/save');

    final request =
        http.MultipartRequest('POST', url)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['name'] = name;

    request.files.add(
      await http.MultipartFile.fromPath(
        'foto_ktp',
        ktpFile.path,
        filename: basename(ktpFile.path),
      ),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    // ✅ Tangani case jika responseBody kosong atau bukan JSON
    if (response.statusCode == 201 || response.statusCode == 200) {
      try {
        final decoded = jsonDecode(responseBody);
        return ShopModel.fromJson(decoded['data'] ?? decoded);
      } catch (_) {
        // Jika tidak bisa di-decode, tapi status 201, anggap berhasil
        return ShopModel(id: 0, name: name, fotoKtp: null, status: 'Pending');
      }
    } else {
      try {
        final decoded = jsonDecode(responseBody);
        throw (decoded['message'] ?? 'Gagal membuat toko');
      } catch (e) {
        throw ('${e.toString()}');
      }
    }
  }

  Future<List<ProductModel>> getMyProducts() async {
    final token = await getToken();
    final url = Uri.parse('$_baseUrl/product/myproduct');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'];
      return list.map((e) => ProductModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil produk milik sendiri');
    }
  }

  Future<void> createProduct({
    required String title,
    required String description,
    required int price,
    required int stock,
    required String category,
    required String location,
    required File imageFile,
  }) async {
    final token = await getToken();
    final url = Uri.parse('$_baseUrl/product/save');

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['title'] = title
      ..fields['description'] = description
      ..fields['price'] = price.toString()
      ..fields['stock'] = stock.toString()
      ..fields['category'] = category
      ..fields['location'] = location
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 201) {
      final decoded = jsonDecode(responseBody);
      throw Exception(decoded['message'] ?? 'Gagal menambahkan produk');
    }
  }

  Future<ProductModel> updateProduct({
    required int id,
    required String title,
    required String description,
    required int price,
    required int stock,
    required String category,
    required String location,
    File? imageFile,
  }) async {
    final token = await getToken();
    final url = Uri.parse('$_baseUrl/product/update/$id');

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['title'] = title
      ..fields['description'] = description
      ..fields['price'] = price.toString()
      ..fields['stock'] = stock.toString()
      ..fields['category'] = category
      ..fields['location'] = location
      ..fields['_method'] = 'POST';

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: basename(imageFile.path),
      ));
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return ProductModel.fromJson(data['data'] ?? data);
    } else {
      try {
        final err = jsonDecode(responseBody);
        throw Exception(err['message'] ?? 'Gagal memperbarui produk');
      } catch (_) {
        throw Exception('Gagal memperbarui produk: ${response.reasonPhrase ?? responseBody}');
      }
    }
  }
  
  Future<void> deleteProduct(int id) async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}product/delete/$id');
    final response = await http.delete(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Gagal menghapus produk');
    }
  }

  // ✅ Ambil data profil user dari endpoint /user-profile
  Future<UserProfile> getUserProfile() async {
    final token = await getToken();
    if (token == null)
      throw Exception('Token tidak ditemukan, silakan login ulang.');

    final url = Uri.parse('${_baseUrl}user-profile');
    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return UserProfile.fromJson(jsonData);
    } else {
      throw Exception('Gagal mengambil data profil.');
    }
  }

  // ✅ Ambil semua produk
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
      return list.map((e) => ProductModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data produk');
    }
  }

  // ✅ Ambil semua konten pelatihan
  Future<List<ContentModel>> getAllContents() async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan, silakan login.');

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

  // ✅ Detail satu konten berdasarkan ID
  Future<ContentModel> getContentDetail(int contentId) async {
    final token = await getToken();
    if (token == null) throw Exception('Token tidak ditemukan, silakan login.');

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
  Future<List<UserProfile>> getAllUsers() async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}users/getall'); // Sesuaikan endpoint

    final response = await http.get(url, headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'];
      return list.map((e) => UserProfile.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data pengguna');
    }
  }

  /// ADMIN: Mengambil detail satu pengguna.
  Future<UserProfile> getUserDetail(int userId) async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}users/detail/$userId'); // Sesuaikan endpoint

    final response = await http.get(url, headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserProfile.fromJson(data['data']);
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
