class ContentModel {
  final int id;
  final String title;
  final String videoId;
  final String description;
  final String creator;
  final String? playlist;
  final String? thumbnail; // URL untuk thumbnail

  ContentModel({
    required this.id,
    required this.title,
    required this.videoId,
    required this.description,
    required this.creator,
    this.playlist,
    this.thumbnail,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'],
      title: json['title'] ?? 'Tanpa Judul',
      videoId: json['video'] ?? '', // Mengambil dari key 'video'
      description: json['description'] ?? '',
      creator: json['creator'] ?? 'Anonim',
      playlist: json['playlist'],
      thumbnail: json['thumbnail'],
    );
  }
}