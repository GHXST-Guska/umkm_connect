import 'package:flutter/material.dart';
import 'package:umkm_connect/services/api_static.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:umkm_connect/models/content_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailVideo extends StatefulWidget {
  final int contentId;
  const DetailVideo({super.key, required this.contentId});

  @override
  State<DetailVideo> createState() => _DetailVideoState();
}

class _DetailVideoState extends State<DetailVideo> {
  // Gunakan satu Future untuk semua proses inisialisasi yang kompleks
  late final Future<YoutubePlayerController> _controllerFuture;
  final APIStatic _api = APIStatic();
  ContentModel? _content; // Untuk menyimpan data konten agar bisa diakses di UI

  @override
  void initState() {
    super.initState();
    // Panggil fungsi inisialisasi utama di initState
    _controllerFuture = _initializePlayer();
  }
  
  // Fungsi async utama untuk mengambil data dan membuat controller
  Future<YoutubePlayerController> _initializePlayer() async {
    // 1. Ambil data konten dari API
    final content = await _api.getContentDetail(widget.contentId);
    
    // Simpan data konten untuk digunakan di build method nanti
    if (mounted) {
      setState(() { _content = content; });
    }

    if (content.videoId.isEmpty) {
      throw Exception("Video ID tidak ditemukan untuk konten ini.");
    }

    // 2. Buat controller
    final controller = YoutubePlayerController(
      initialVideoId: content.videoId,
      flags: const YoutubePlayerFlags(autoPlay: false),
    );

    // 3. Tambahkan listener untuk menyimpan progres dan menampilkan kuis
    controller.addListener(() => _videoListener(controller, content));
    
    // 4. Setelah controller dibuat, cek progres dan tampilkan dialog jika perlu
    final savedSeconds = await _loadVideoProgress();
    if (savedSeconds > 5) { // Hanya tampilkan jika progres signifikan
      _showResumeDialog(controller, savedSeconds);
    } else {
      controller.play(); // Mainkan dari awal jika tidak ada progres
    }
    
    return controller;
  }
  
  // Fungsi terpisah untuk listener agar lebih rapi
  void _videoListener(YoutubePlayerController controller, ContentModel content) async {
    final prefs = await SharedPreferences.getInstance();
    final position = controller.value.position.inSeconds;
    
    // Simpan progres (misalnya setiap 5 detik agar tidak terlalu sering)
    if (position > 0 && position % 5 == 0) {
      await prefs.setInt('video_progress_${widget.contentId}', position);
    }
    
    // Logika untuk menampilkan kuis dari data API
    for (var quizEntry in content.quizTimes.entries) {
        final quizTimeInSeconds = quizEntry.key;
        // Cek jika waktu video cocok dengan waktu kuis
        if (position == quizTimeInSeconds) {
          final quizKey = 'quiz_shown_${widget.contentId}_$quizTimeInSeconds';
          final bool quizShown = prefs.getBool(quizKey) ?? false;
          if (!quizShown) {
            controller.pause();
            await prefs.setBool(quizKey, true); // Tandai kuis sudah tampil
            _showQuizDialog(controller, quizEntry.value);
            break; // Hentikan loop setelah kuis pertama ditemukan
          }
        }
    }
  }

  // Helper untuk memuat progres dari SharedPreferences
  Future<int> _loadVideoProgress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('video_progress_${widget.contentId}') ?? 0;
  }
  
  // Menampilkan dialog untuk melanjutkan video
  void _showResumeDialog(YoutubePlayerController controller, int savedSeconds) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Lanjutkan Menonton?"),
          content: Text("Anda terakhir menonton di menit ke-${(savedSeconds / 60).floor()}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.seekTo(Duration(seconds: savedSeconds));
                controller.play();
              },
              child: const Text("Lanjutkan"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.play();
              },
              child: const Text("Mulai dari Awal"),
            ),
          ],
        ),
      );
    });
  }

  // Menampilkan dialog kuis
  void _showQuizDialog(YoutubePlayerController controller, String question) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Kuis Singkat!"),
        content: Text(question),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.play();
            },
            child: const Text("Lanjutkan Video"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controllerFuture.then((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6FA),
      appBar: AppBar(title: Text(_content?.title ?? "Konten Video")),
      body: FutureBuilder<YoutubePlayerController>(
        future: _controllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Gagal memuat video: ${snapshot.error}"),
            ));
          }
          
          final controller = snapshot.data!;
          return YoutubePlayerBuilder(
            player: YoutubePlayer(controller: controller),
            builder: (context, player) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(borderRadius: BorderRadius.circular(12), child: player),
                    const SizedBox(height: 16),
                    if (_content != null) ...[
                      Text(_content!.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text("Oleh: ${_content!.creator}", style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(_content!.description, style: Theme.of(context).textTheme.bodyMedium),
                    ]
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