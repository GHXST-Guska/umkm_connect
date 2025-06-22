import 'package:flutter/material.dart';
import 'package:umkm_connect/pages/video_page.dart';

class UpdatePage extends StatelessWidget {
  const UpdatePage({super.key});

  final List<Map<String, String>> videos = const [
    {
      'title': 'Cara Daftar UMKM Online',
      'url': 'https://www.youtube.com/watch?v=ysz5S6PUM-U',
    },
    {
      'title': 'Strategi Memulai Bisnis Modal Kecil',
      'url': 'https://www.youtube.com/watch?v=ysz5S6PUM-U',
    },
    // Tambahkan video lainnya di sini
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Pelatihan'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFDF6FA),
      body: ListView.separated(
        itemCount: videos.length,
        padding: const EdgeInsets.all(16),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final video = videos[index];
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            tileColor: Colors.white,
            leading: const Icon(
              Icons.play_circle_fill,
              size: 40,
              color: Colors.pink,
            ),
            title: Text(
              video['title']!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => VideoPlayerPage(
                        videoUrl: video['url']!,
                        title: video['title']!,
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
