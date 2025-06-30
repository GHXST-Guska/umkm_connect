// lib/pages/admin/user_list_page.dart

import 'package:flutter/material.dart';
import 'package:umkm_connect/models/user_model.dart';
import 'package:umkm_connect/services/api_static.dart';
import 'package:umkm_connect/pages/admin/user_detail_page.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late Future<List<UserProfile>> _usersFuture;
  final APIStatic _api = APIStatic();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _usersFuture = _api.getAllUsers();
    });
  }

  void _navigateToDetail(int userId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserDetailPage(userId: userId)),
    );
    _loadUsers(); // Muat ulang daftar setelah kembali dari halaman detail
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manajemen Pengguna")),
      body: RefreshIndicator(
        onRefresh: _loadUsers,
        child: FutureBuilder<List<UserProfile>>(
          future: _usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Tidak ada pengguna terdaftar."));
            }
            
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: user.role == 'admin' ? Colors.indigo.shade100 : Colors.pink.shade100,
                      child: Icon(user.role == 'admin' ? Icons.shield_outlined : Icons.person, color: user.role == 'admin' ? Colors.indigo : Colors.pink),
                    ),
                    title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(user.email),
                    trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                    onTap: () => _navigateToDetail(user.id),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}