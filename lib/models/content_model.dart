class ContentModel {
  final int id;
  final String title;
  final String videoId;
  final String description;
  final String creator;
  final String playlist;
  final String thumbnail;
  final Map<int, String> quizTimes; // format: { menit_ke: 'soal' }

  ContentModel({
    required this.id,
    required this.title,
    required this.videoId,
    required this.description,
    required this.creator,
    required this.playlist,
    required this.thumbnail,
    required this.quizTimes,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'],
      title: json['title'],
      videoId: json['video'],
      description: json['description'],
      creator: json['creator'],
      playlist: json['playlist'],
      thumbnail: json['thumbnail'],
      quizTimes: Map<String, dynamic>.from(json['quiz_times'] ?? {})
          .map((key, value) => MapEntry(int.parse(key), value.toString())),
    );
  }
}