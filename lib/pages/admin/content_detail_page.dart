// lib/pages/admin/content_detail_page.dart

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:umkm_connect/models/content_model.dart';
import 'package:umkm_connect/services/api_static.dart';
import 'package:umkm_connect/pages/admin/content_form_page.dart';

class ContentDetailPage extends StatefulWidget {
  final int contentId;
  const ContentDetailPage({super.key, required this.contentId});

  @override
  State<ContentDetailPage> createState() => _ContentDetailPageState();
}

class _ContentDetailPageState extends State<ContentDetailPage> {
  late Future<ContentModel> _contentFuture;
  final APIStatic _api = APIStatic();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  void _loadContent() {
    _contentFuture = _api.getContentDetail(widget.contentId);
  }

  // Fungsi hapus yang sudah diperbaiki
  Future<void> _deleteContent() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        // Ubah pesan konfirmasi
        content: const Text('Apakah Anda yakin ingin menghapus konten ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);
    try {
      // Panggil fungsi yang benar: deleteContent
      await _api.deleteContent(widget.contentId); 
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        // Ubah pesan sukses
        const SnackBar(content: Text('Konten berhasil dihapus'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // Fungsi untuk refresh halaman setelah edit
  void _navigateAndRefresh(ContentModel content) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContentFormPage(content: content)),
    );
    // Muat ulang data setelah kembali dari halaman edit
    setState(() {
      _contentFuture = _api.getContentDetail(widget.contentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ContentModel>(
        future: _contentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasError) {
            return Scaffold(appBar: AppBar(title: const Text("Error")), body: Center(child: Text("Error: ${snapshot.error}")));
          }
          if (!snapshot.hasData) {
            return Scaffold(appBar: AppBar(), body: const Center(child: Text("Konten tidak ditemukan.")));
          }

          final content = snapshot.data!;
          final YoutubePlayerController controller = YoutubePlayerController(
            initialVideoId: content.videoId,
            flags: const YoutubePlayerFlags(autoPlay: false),
          );

          return Scaffold(
            appBar: AppBar(
              title: const Text("Detail Konten"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _navigateAndRefresh(content),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _isProcessing ? null : _deleteContent,
                ),
              ],
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Player Video
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: YoutubePlayer(
                          controller: controller,
                          showVideoProgressIndicator: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Judul
                      Text(content.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      // Kreator & Playlist
                      _buildDetailRow(Icons.person, "Kreator", content.creator),
                      _buildDetailRow(Icons.playlist_play, "Playlist", content.playlist),
                      const Divider(height: 32),

                      // Deskripsi
                      Text("Deskripsi", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(content.description, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                if (_isProcessing)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget helper untuk membuat baris detail
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}