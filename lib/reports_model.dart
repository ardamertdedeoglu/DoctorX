class ReportsModel {
  final String title;
  final String department;
  final String doctor;
  final String date;
  final String pdfUrl;
  bool isDeleted;
  final String month;
  final String year;

  ReportsModel({
    required this.title,
    required this.department,
    required this.doctor,
    required this.date,
    required this.pdfUrl,
    this.isDeleted = false,
  }) : month = date.split('/')[1],
       year = date.split('/')[2];
}
