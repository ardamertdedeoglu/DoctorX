class DocumentModel {
  final String title;
  final String category;
  final String summary;
  final String content;
  final String author;
  final String date;
  bool isRead; // Okundu bilgisi eklendi

  DocumentModel({
    required this.title,
    required this.category,
    required this.summary,
    required this.content,
    required this.author,
    required this.date,
    this.isRead = false,
  });
}
