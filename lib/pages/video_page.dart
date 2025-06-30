// lib/pages/halamanVideo.dart

import 'package:flutter/material.dart';
import 'package:umkm_connect/services/api_static.dart';
import 'package:umkm_connect/models/content_model.dart';
import 'package:umkm_connect/pages/detailVideo.dart'; // Import halaman detail

class HalamanVideo extends StatefulWidget {
  const HalamanVideo({super.key});

  @override
  State<HalamanVideo> createState() => _HalamanVideoState();
}

class _HalamanVideoState extends State<HalamanVideo> {
  late Future<List<ContentModel>> _contentsFuture;

  @override
  void initState() {
    super.initState();
    // Buat objek dari APIStatic, lalu panggil metodenya
    _contentsFuture = APIStatic().getAllContents(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Konten"),
      ),
      body: FutureBuilder<List<ContentModel>>(
        future: _contentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.hasData) {
            final contents = snapshot.data!;
            return ListView.builder(
              itemCount: contents.length,
              itemBuilder: (context, index) {
                final content = contents[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    // Tampilkan gambar thumbnail jika ada
                    title: Text(content.title),
                    subtitle: Text(content.creator),
                    onTap: () {
                      // Navigasi ke halaman detail saat item diklik
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailVideo(contentId: content.id),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          return const Center(child: Text("Tidak ada konten."));
        },
      ),
    );
  }
}