import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AppointmentModel {
  final String? id;
  final String doctorType;
  final String doctorName;
  final String hospital;
  final String date;
  final String time;
  final String userId;
  final DateTime dateTime;

  AppointmentModel({
    this.id,
    required this.doctorType,
    required this.doctorName,
    required this.hospital,
    required this.date,
    required this.time,
    required this.userId,
    required this.dateTime,
  });

  bool isWithinTwoWeeks() {
    final now = DateTime.now();
    final difference = dateTime.difference(now).inDays;
    return difference >= 0 && difference <= 14;
  }

  // Helper method to parse date and time to DateTime
  static DateTime _parseDateTime(String dateStr, String timeStr) {
    try {
      final format = DateFormat('dd/MM/yyyy HH:mm');
      return format.parse('$dateStr $timeStr');
    } catch (e) {
      return DateTime.now();
    }
  }

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String dateStr = data['date'] ?? '';
    final String timeStr = data['time'] ?? '';
    return AppointmentModel(
      id: doc.id,
      doctorType: data['doctorType'] ?? '',
      doctorName: data['doctorName'] ?? '',
      hospital: data['hospital'] ?? '',
      date: dateStr,
      time: timeStr,
      userId: data['userId'] ?? '',
      dateTime: (dateStr.isNotEmpty && timeStr.isNotEmpty)
          ? _parseDateTime(dateStr, timeStr)
          : DateTime.now(),
    );
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final String dateStr = json['date'] ?? '';
    final String timeStr = json['time'] ?? '';
    return AppointmentModel(
      id: json['id'],
      doctorType: json['doctorType'] ?? '',
      doctorName: json['doctorName'] ?? '',
      hospital: json['hospital'] ?? '',
      date: dateStr,
      time: timeStr,
      userId: json['userId'] ?? '',
      dateTime: (dateStr.isNotEmpty && timeStr.isNotEmpty)
          ? _parseDateTime(dateStr, timeStr)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'doctorType': doctorType,
    'doctorName': doctorName,
    'hospital': hospital,
    'date': date,
    'time': time,
    'userId': userId,
    'dateTime': dateTime.toIso8601String(), // İsteğe bağlı olarak saklayabilirsiniz
  };
}
