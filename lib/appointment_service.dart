// Bu dosya Firebase Firestore işlemleri için kullanılan servis sınıfını içerir.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'appointment_model.dart';

// Firebase işlemleri için servis sınıfı
class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  AppointmentService(this.userId);

  // Randevuları getir
  Stream<List<AppointmentModel>> getAppointments() {
    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return AppointmentModel.fromJson(data);
          }).toList();
        });
  }

  // Randevu ekle
  Future<void> addAppointment(AppointmentModel appointment) async {
    await _firestore.collection('appointments').add({
      'doctorType': appointment.doctorType,
      'doctorName': appointment.doctorName,
      'hospital': appointment.hospital,
      'date': appointment.date,
      'time': appointment.time,
      'userId': appointment.userId,
      'dateTime': appointment.dateTime.toIso8601String(),
    });
  }

  // Randevu sil
  Future<void> deleteAppointment(String appointmentId) async {
    await _firestore.collection('appointments').doc(appointmentId).delete();
  }
}