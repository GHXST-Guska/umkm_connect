import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:umkm_connect/models/product_model.dart';
import 'package:umkm_connect/models/content_model.dart';
import 'package:umkm_connect/models/shop_model.dart';
import 'package:umkm_connect/models/user_model.dart';
import 'package:umkm_connect/models/order_model.dart';
import 'package:umkm_connect/models/cart_model.dart';

class APIStatic {
  final String _baseUrl =
      "https://e2f3-182-253-163-199.ngrok-free.app/UMKMConnect/public/";
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
    final url = Uri.parse('${_baseUrl}register');
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
    final url = Uri.parse('${_baseUrl}login');
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
    final url = Uri.parse('${_baseUrl}logout');

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
    final url = Uri.parse('${_baseUrl}users/updateProfile');

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
    final url = Uri.parse('${_baseUrl}shop/save');

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
        return ShopModel(id: 0, name: name, fotoKtpUrl: null, status: 'Pending', penghasilan: 0);
      }
    } else {
      try {
        final decoded = jsonDecode(responseBody);
        throw (decoded['message'] ?? 'Gagal membuat toko');
      } catch (e) {
        throw (e.toString());
      }
    }
  }

  Future<List<ProductModel>> getMyProducts() async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}product/myproduct');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
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
    required String title, // Ganti dari title
    required String description,
    required int price,
    required int stock,
    required String category,
    required String location,
    required File imageFile,
  }) async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}product/save'); // Sesuaikan endpoint

    // Buat multipart request
    var request = http.MultipartRequest('POST', url);

    // Tambahkan headers
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // Tambahkan field teks
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();
    request.fields['stock'] = stock.toString();
    request.fields['category'] = category;
    request.fields['location'] = location;

    // Tambahkan file gambar
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    // Kirim request
    var response = await request.send();

    if (response.statusCode != 201) {
      // Baca respons error jika ada
      final respStr = await response.stream.bytesToString();
      print(respStr);
      throw Exception('Gagal membuat produk');
    }
  }

  Future<void> updateProduct({
    required int id,
    required String title,
    required String description,
    required int price,
    required int stock,
    required String category,
    required String location,
    File? imageFile, // Gambar bersifat opsional saat update
  }) async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}product/update/$id'); // Sesuaikan

    var request = http.MultipartRequest(
      'POST',
      url,
    ); // Gunakan POST untuk method spoofing

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // Method Spoofing untuk memberi tahu backend ini adalah request PUT/PATCH
    request.fields['_method'] = 'PUT';

    // Tambahkan field teks
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();
    request.fields['stock'] = stock.toString();
    request.fields['category'] = category;
    request.fields['location'] = location;

    // Tambahkan file gambar HANYA JIKA ada file baru yang dipilih
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    var response = await request.send();

    if (response.statusCode != 200) {
      final respStr = await response.stream.bytesToString();
      print(respStr);
      throw Exception('Gagal memperbarui produk');
    }
  }

  Future<void> deleteProduct(int id) async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}product/delete/$id');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Gagal menghapus produk');
    }
  }

  // ✅ Ambil data profil user dari endpoint /user-profile
  Future<UserProfile> getUserProfile() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan, silakan login ulang.');
    }

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
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      // 201 Created
      throw Exception('Gagal membuat konten baru');
    }
  }

  /// ADMIN: Mengupdate konten yang sudah ada.
  Future<void> updateContent(int contentId, Map<String, dynamic> data) async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}contents/update/$contentId'); // Sesuaikan

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      // 200 OK
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

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
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
    final url = Uri.parse(
      '${_baseUrl}users/detail/$userId',
    ); // Sesuaikan endpoint

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
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
    final url = Uri.parse(
      '${_baseUrl}users/delete/$userId',
    ); // Sesuaikan endpoint

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus pengguna');
    }
  }

  Future<List<ShopModel>> getAllShops() async {
    final token = await getToken();
    final url = Uri.parse(
      '${_baseUrl}shop/shopall',
    ); // Ganti dengan endpoint Anda

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
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
    final url = Uri.parse(
      '${_baseUrl}shop/detail/$shopId',
    ); // Ganti dengan endpoint Anda

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
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
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'status': newStatus}),
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal memvalidasi toko');
    }
  }

  /// ADMIN: Menghapus toko.
  Future<void> deleteShop(int shopId) async {
    final token = await getToken();
    final url = Uri.parse(
      '${_baseUrl}shop/delete/$shopId',
    ); // Ganti dengan endpoint Anda

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus toko');
    }
  }

  Future<List<OrderModel>> getAllOrders() async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}order/getall'); // Sesuaikan endpoint

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'];
      return list.map((e) => OrderModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data pesanan');
    }
  }

  Future<void> addToCart({
    required int productId,
    required int quantity,
  }) async {
    final token = await getToken();
    // Endpoint sesuai rute Anda: POST /order/cart/{id}
    final url = Uri.parse('${_baseUrl}order/cart/$productId');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'quantity': quantity}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      // Baca pesan error dari server jika ada
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal menambahkan ke keranjang');
    }
  }

  /// Membuat pesanan langsung (Buy Now).
  Future<void> directOrder({
    required int productId,
    required int quantity,
  }) async {
    final token = await getToken();
    // Endpoint sesuai rute Anda: POST /order/directOrder/{id}
    final url = Uri.parse('${_baseUrl}order/directOrder/$productId');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'quantity': quantity,
        // CATATAN: Alamat pengiriman perlu diambil dari input pengguna.
        // Untuk contoh ini, kita hardcode.
        'shipping_address': 'Alamat tes dari Flutter',
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal membuat pesanan');
    }
  }

  Future<List<CartItemModel>> getCartItems() async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}order/cart'); // Endpoint GET /cart

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'];
      return list.map((e) => CartItemModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data keranjang');
    }
  }

  /// Melakukan checkout untuk item yang dipilih dari keranjang.
  Future<void> checkoutFromCart({
    required List<int> cartIds,
    required String shippingAddress,
  }) async {
    final token = await getToken();
    final url = Uri.parse(
      '${_baseUrl}order/orderCart',
    ); // Endpoint POST /orderCart

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'cart_ids': cartIds,
        'shipping_address': shippingAddress,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal melakukan checkout');
    }
  }

  Future<List<OrderModel>> getMyOrders() async {
    final token = await getToken();
    final url = Uri.parse('${_baseUrl}order/myorder'); // Panggil endpoint baru

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'];
      return list.map((e) => OrderModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil riwayat pesanan');
    }
  }

  Future<String> requestMidtransPaymentUrl(int orderId) async {
    final token = await getToken();
    final url = Uri.parse(
      '${_baseUrl}orders/$orderId/pay',
    ); // Sesuaikan dengan rute Anda

    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['payment_url'];
    } else {
      throw Exception('Gagal membuat link pembayaran');
    }
  }

  Future<List<OrderModel>> getMyStoreOrders() async {
    final token = await getToken();
    // Anda perlu membuat endpoint ini di backend
    final url = Uri.parse('${_baseUrl}shop/orders'); 

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['data'];
      return list.map((e) => OrderModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil pesanan toko');
    }
  }

  Future<ShopModel> getMyStore() async {
    final token = await getToken();
    // Asumsi endpoint-nya adalah /shop/show
    final url = Uri.parse('${_baseUrl}shop/show'); 
    
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Asumsi API mengembalikan data toko di dalam key 'data'
      return ShopModel.fromJson(data['data']);
    } else if (response.statusCode == 404) {
      throw Exception('Anda belum memiliki toko. Silakan buat toko terlebih dahulu.');
    } else {
      throw Exception('Gagal mengambil data toko');
    }
  }

  // Simpan progres video (shared preferences atau backend)
  Future<void> saveVideoProgress(int contentId, int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('video_progress_$contentId', seconds);
  }

  Future<int> getVideoProgress(int contentId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('video_progress_$contentId') ?? 0;
  }

  Future<void> markQuizAsShown(int contentId, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('quiz_shown_${contentId}_$minute', true);
  }

  Future<bool> isQuizAlreadyShown(int contentId, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('quiz_shown_${contentId}_$minute') ?? false;
  }
}
