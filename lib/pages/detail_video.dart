import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:umkm_connect/services/api_static.dart';
import 'package:umkm_connect/models/content_model.dart';

class DetailVideo extends StatefulWidget {
  // Terima ID dari halaman sebelumnya
  final int contentId; 

  const DetailVideo({super.key, required this.contentId});

  @override
  State<DetailVideo> createState() => _DetailVideoState();
}

class _DetailVideoState extends State<DetailVideo> {
  late final Future<ContentModel> _contentFuture;

  @override
  void initState() {
    super.initState();
    // Buat objek dari APIStatic, lalu panggil metodenya
    _contentFuture = APIStatic().getContentDetail(widget.contentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6FA),
      appBar: AppBar(
        title: const Text("Konten Video"),
      ),
      body: FutureBuilder<ContentModel>(
        future: _contentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.hasData) {
            final content = snapshot.data!;
            // Pastikan videoId tidak null sebelum membuat controller
            if (content.videoId == Null) {
              return const Center(child: Text("Video tidak tersedia."));
            }
            final YoutubePlayerController controller = YoutubePlayerController(
              initialVideoId: content.videoId,
              flags: const YoutubePlayerFlags(autoPlay: false),
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  YoutubePlayer(controller: controller),
                  const SizedBox(height: 16),
                  Text(content.title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 20),
                  Text("Oleh: ${content.creator}", style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(content.description, style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            );
          }
          return const Center(child: Text("Tidak ada data."));
        },
      ),
    );
  }
}