import 'package:flutter/material.dart';
import 'package:umkm_connect/pages/profile_form.dart';
import 'package:umkm_connect/services/api_static.dart';
import 'package:umkm_connect/models/user_model.dart';
import 'package:umkm_connect/pages/login_page.dart';
import 'package:umkm_connect/pages/shop_create.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final APIStatic _api = APIStatic();
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _api.getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6FA),
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<UserProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat profil: ${snapshot.error}'));
          }

          final profile = snapshot.data!;
          final avatarUrl = profile.pathImageUrl ??
              'https://ui-avatars.com/api/?name=${Uri.encodeComponent(profile.name)}&background=FC6C85&color=fff';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // 📸 Foto Profil
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.pink.shade100,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
              ),
              const SizedBox(height: 16),

              // ℹ️ Info User
              Center(
                child: Column(
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(profile.email),
                    const SizedBox(height: 4),
                    Text('🛍️ Role: ${profile.role}'),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Divider(),

              // ⚙️ Pengaturan Akun
              const Text(
                'Pengaturan Akun',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Profil'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final result = await Navigator.push<UserProfile>(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  );

                  // setelah kembali, perbarui state jika data baru tersedia
                  if (result != null) {
                    setState(() {
                      _profileFuture = Future.value(result); // tampilkan data hasil update
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.store_mall_directory),
                title: const Text('Buat Toko'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateShopPage()),
                  );
                },
              ),

              const SizedBox(height: 16),
              const Divider(),

              // 🚪 Logout
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Keluar',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  await _api.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
