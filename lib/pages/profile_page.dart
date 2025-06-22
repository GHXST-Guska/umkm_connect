import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data user, bisa diganti ambil dari API
    final String name = 'Gusti Putu Bagus Eka Prastanto';
    final String email = 'guseka@gmail.com';
    final String location = 'Singaraja, Bali';
    final String role = 'UMKM Enthusiast';

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6FA),
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 📸 Foto Profil
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.pink.shade100,
              backgroundImage: const NetworkImage(
                'https://ui-avatars.com/api/?name=UMKM+User&background=FC6C85&color=fff',
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 🧾 Informasi Akun
          Center(
            child: Column(
              children: [
                Text(name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 4),
                Text(email),
                const SizedBox(height: 4),
                Text('📍 $location'),
                const SizedBox(height: 4),
                Text('🛍️ Role: $role'),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),

          // ⚙️ Menu Pengaturan
          const Text(
            'Pengaturan Akun',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Ganti Email'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigasi ke form ganti email
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Ganti Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigasi ke form ganti password
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Ubah Lokasi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigasi ke form ubah lokasi
            },
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Kelola Produk/Jasa'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigasi ke halaman manajemen produk/jasa UMKM
            },
          ),

          const SizedBox(height: 16),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Keluar',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              // TODO: Implementasi logout jika diperlukan dari sini
            },
          ),
        ],
      ),
    );
  }
}
