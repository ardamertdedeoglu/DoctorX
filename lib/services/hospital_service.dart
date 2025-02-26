import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hospital_model.dart';
import 'package:doctorx/generated/l10n.dart';

class HospitalService {
  final BuildContext context;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  HospitalService(this.context);
  
  Future<List<HospitalModel>> getHospitals() async {
    try {
      // Check if hospitals collection exists and has documents
      final hospitalsSnapshot = await _firestore.collection('hospitals').get();
      
      if (hospitalsSnapshot.docs.isEmpty) {
        // If no hospitals, create sample hospitals
        await _createSampleHospitals();
        return _getSampleHospitals();
      }
      
      // Map the documents to hospital models
      return hospitalsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return HospitalModel.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching hospitals: $e');
      // Return sample hospitals as fallback
      return _getSampleHospitals();
    }
  }
  
  Future<void> _createSampleHospitals() async {
    try {
      // Create sample hospitals in Firestore
      await _firestore.collection('hospitals').add({
        'name': 'Şehir Hastanesi',
        'address': 'Şehir Merkezi, Ana Cadde No: 123',
        'phone': '(555) 123-4567',
        'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/doctorx-app.appspot.com/o/hospitals%2Fsehir_hastanesi.jpg?alt=media',
      });
      
      await _firestore.collection('hospitals').add({
        'name': 'Merkez Hastanesi',
        'address': 'Yeni Mahalle, Park Caddesi No: 45',
        'phone': '(555) 987-6543',
        'imageUrl': 'https://firebasestorage.googleapis.com/v0/b/doctorx-app.appspot.com/o/hospitals%2Fmerkez_hastanesi.jpg?alt=media',
      });
    } catch (e) {
      print('Error creating sample hospitals: $e');
    }
  }
  
  List<HospitalModel> _getSampleHospitals() {
    return [
      HospitalModel(
        id: 'hospital-1',
        name: 'Şehir Hastanesi',
        address: 'Şehir Merkezi, Ana Cadde No: 123',
        phone: '(555) 123-4567',
        imageUrl: 'https://firebasestorage.googleapis.com/v0/b/doctorx-app.appspot.com/o/hospitals%2Fsehir_hastanesi.jpg?alt=media',
        departments: [
          DepartmentModel(
            id: 'dept-1',
            name: S.of(context).department1name,
            doctors: [
              DoctorModel(
                id: 'doc-1',
                name: 'Ahmet Yılmaz',
                title: 'Prof. Dr.',
                departmentId: 'dept-1',
                availableSlots: List.generate(
                  7,
                  (index) => DateTime.now().add(Duration(days: index, hours: 9)),
                ),
              ),
              DoctorModel(
                id: 'doc-2',
                name: 'Ayşe Kaya',
                title: 'Doç. Dr.',
                departmentId: 'dept-1',
                availableSlots: List.generate(
                  7,
                  (index) => DateTime.now().add(Duration(days: index, hours: 14)),
                ),
              ),
            ],
          ),
          DepartmentModel(
            id: 'dept-2',
            name: S.of(context).department2name,
            doctors: [
              DoctorModel(
                id: 'doc-3',
                name: 'Mehmet Demir',
                title: 'Prof. Dr.',
                departmentId: 'dept-2',
                availableSlots: List.generate(
                  7,
                  (index) => DateTime.now().add(Duration(days: index, hours: 10)),
                ),
              ),
            ],
          ),
        ],
      ),
      HospitalModel(
        id: 'hospital-2',
        name: 'Merkez Hastanesi',
        address: 'Yeni Mahalle, Park Caddesi No: 45',
        phone: '(555) 987-6543',
        imageUrl: 'https://firebasestorage.googleapis.com/v0/b/doctorx-app.appspot.com/o/hospitals%2Fmerkez_hastanesi.jpg?alt=media',
        departments: [
          DepartmentModel(
            id: 'dept-3',
            name: S.of(context).department3name,
            doctors: [
              DoctorModel(
                id: 'doc-4',
                name: 'Zeynep Şahin',
                title: 'Uzm. Dr.',
                departmentId: 'dept-3',
                availableSlots: List.generate(
                  7,
                  (index) => DateTime.now().add(Duration(days: index, hours: 11)),
                ),
              ),
            ],
          ),
          DepartmentModel(
            id: 'dept-4',
            name: S.of(context).department4name,
            doctors: [
              DoctorModel(
                id: 'doc-5',
                name: 'Can Özkan',
                title: 'Prof. Dr.',
                departmentId: 'dept-4',
                availableSlots: List.generate(
                  7,
                  (index) => DateTime.now().add(Duration(days: index, hours: 13)),
                ),
              ),
            ],
          ),
        ],
      ),
    ];
  }
  
  Future<HospitalModel?> getHospitalById(String hospitalId) async {
    try {
      final doc = await _firestore.collection('hospitals').doc(hospitalId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return HospitalModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching hospital by ID: $e');
      return null;
    }
  }
}
