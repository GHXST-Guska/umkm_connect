import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:umkm_connect/services/api_static.dart';
import 'package:umkm_connect/models/content_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailVideo extends StatefulWidget {
  final int contentId;

  const DetailVideo({super.key, required this.contentId});

  @override
  State<DetailVideo> createState() => _DetailVideoState();
}

class _DetailVideoState extends State<DetailVideo> {
  late Future<ContentModel> _contentFuture;
  YoutubePlayerController? _controller;
  bool _quizShown = false;

  @override
  void initState() {
    super.initState();
    _contentFuture = APIStatic().getContentDetail(widget.contentId);
  }

  Future<void> _initController(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedSeconds = prefs.getInt('video_${widget.contentId}_seconds') ?? 0;

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: false),
    )..addListener(() async {
      final position = _controller!.value.position.inSeconds;

      // Simpan posisi terakhir
      await prefs.setInt('video_${widget.contentId}_seconds', position);

      // Tampilkan kuis saat menit ke-3 jika belum ditampilkan
      if (!_quizShown && position >= 180) {
        _quizShown = true;
        _controller!.pause();
        _showQuiz();
      }
    });

    // Tampilkan dialog untuk melanjutkan
    if (savedSeconds > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showResumeDialog(savedSeconds);
      });
    }
  }

  void _showResumeDialog(int savedSeconds) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Lanjutkan Menonton?"),
            content: Text(
              "Anda sebelumnya menonton sampai menit ke-${(savedSeconds / 60).floor()}",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  _controller!.seekTo(Duration(seconds: savedSeconds));
                  _controller!.play();
                },
                child: const Text("Lanjutkan"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _controller!.seekTo(Duration.zero);
                  _controller!.play();
                },
                child: const Text("Mulai dari Awal"),
              ),
            ],
          ),
    );
  }

  void _showQuiz() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Kuis Singkat"),
            content: const Text(
              "Apa manfaat dari pemasaran digital untuk UMKM?\n\nA. Meningkatkan jangkauan pelanggan\nB. Membatasi promosi\nC. Mengurangi pendapatan",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _controller?.play();
                },
                child: const Text("Jawaban A (Benar)"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _controller?.play();
                },
                child: const Text("Jawaban B"),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6FA),
      appBar: AppBar(title: const Text("Konten Video")),
      body: FutureBuilder<ContentModel>(
        future: _contentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData)
            return const Center(child: Text("Tidak ada data."));

          final content = snapshot.data!;
          if (_controller == null) _initController(content.videoId);

          return YoutubePlayerBuilder(
            player: YoutubePlayer(controller: _controller!),
            builder: (context, player) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    player,
                    const SizedBox(height: 16),
                    Text(
                      content.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Oleh: ${content.creator}",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
