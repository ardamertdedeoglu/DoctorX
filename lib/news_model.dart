class NewsModel {
  final String title;
  final String summary;
  final String content;
  final String imageUrl;

  NewsModel({
    required this.title,
    required this.summary,
    required this.content,
    required this.imageUrl,
  });

  // Factory method to create from Firestore document
  factory NewsModel.fromMap(String id, Map<String, dynamic> data) {
    return NewsModel(
      title: data['title'] ?? '',
      summary: data['summary'] ?? '',
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'summary': summary,
      'content': content,
      'imageUrl': imageUrl,
    };
  }
}