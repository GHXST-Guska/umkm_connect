// lib/pages/admin/user_detail_page.dart

import 'package:flutter/material.dart';
import 'package:umkm_connect/models/user_model.dart';
import 'package:umkm_connect/services/api_static.dart';

class UserDetailPage extends StatefulWidget {
  final int userId;
  const UserDetailPage({super.key, required this.userId});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late Future<UserProfile> _userFuture;
  final APIStatic _api = APIStatic();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _userFuture = _api.getUserDetail(widget.userId);
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus pengguna ini? Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);
    try {
      await _api.deleteUser(widget.userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengguna berhasil dihapus'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(); // Kembali ke halaman list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Pengguna")),
      body: FutureBuilder<UserProfile>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("Data pengguna tidak ditemukan."));
          }
          
          final user = snapshot.data!;
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200, // Warna latar belakang untuk fallback
                        
                        // Secara kondisional menampilkan gambar dari URL
                        backgroundImage: (user.pathImageUrl != null && user.pathImageUrl!.isNotEmpty) 
                            ? NetworkImage(user.pathImageUrl!) 
                            : null,

                        // Tampilkan Icon HANYA JIKA tidak ada gambar
                        child: (user.pathImageUrl!= null && user.pathImageUrl!.isNotEmpty)
                            ? null // Kosongkan child jika ada gambar
                            : Icon(
                                user.role == 'admin' ? Icons.shield_outlined : Icons.person,
                                size: 50,
                                color: Colors.grey.shade600,
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow("Nama:", user.name),
                    _buildDetailRow("Email:", user.email),
                    _buildDetailRow("Role:", user.role.toUpperCase()),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _handleDelete,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text("Hapus Pengguna", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isProcessing)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          const Text(": "),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}