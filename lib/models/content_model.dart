class ContentModel {
  final int id;
  final String title;
  final String videoId;
  final String description;
  final String creator;

  ContentModel({
    required this.id,
    required this.title,
    required this.videoId,
    required this.description,
    required this.creator,
  });

  // Factory constructor untuk membuat objek dari JSON
  factory ContentModel.fromJson(Map<String, dynamic> json) {
    return ContentModel(
      id: json['id'],
      title: json['title'],
      videoId: json['video'], // Sesuaikan dengan key di API Anda
      description: json['description'],
      creator: json['creator'],
    );
  }
}