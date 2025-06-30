class ContentModel {
  final int id;
  final String title;
  final String videoId;
  final String description;
  final String creator;
  final String playlist;
  final String thumbnail;

  ContentModel({
    required this.id,
    required this.title,
    required this.videoId,
    required this.description,
    required this.creator,
    required this.playlist,
    required this.thumbnail,
  });

  // Factory constructor untuk membuat objek dari JSON
  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'],
      title: json['title'],
      videoId: json['video'],
      description: json['description'],
      creator: json['creator'],
      playlist: json['playlist'],
      thumbnail: json['thumbnail'],
    );
  }
}
