import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hospital_model.dart';
import '../models/user_model.dart';
import '../generated/l10n.dart';

class HospitalSelector extends StatefulWidget {
  final Function(HospitalModel, UserModel) onSelectionComplete;

  const HospitalSelector({
    super.key,
    required this.onSelectionComplete,
  });

  @override
  _HospitalSelectorState createState() => _HospitalSelectorState();
}

class _HospitalSelectorState extends State<HospitalSelector> {
  HospitalModel? _selectedHospital;
  UserModel? _selectedDoctor;
  List<UserModel>? _hospitalDoctors;

  Future<List<HospitalModel>> _getHospitals() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('hospitals')
        .get();
    
    return snapshot.docs
        .map((doc) => HospitalModel.fromJson(doc.data()))
        .toList();
  }

  Future<List<UserModel>> _getDoctorsForHospital(String hospitalId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'UserRole.doctor')
        .where('hospitalId', isEqualTo: hospitalId)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<List<HospitalModel>>(
          future: _getHospitals(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            final hospitals = snapshot.data ?? [];
            
            return DropdownButtonFormField<HospitalModel>(
              value: _selectedHospital,
              decoration: InputDecoration(
                labelText: S.of(context).chooseHospitalLabel,
                border: OutlineInputBorder(),
              ),
              items: hospitals.map((hospital) {
                return DropdownMenuItem(
                  value: hospital,
                  child: Text(hospital.name),
                );
              }).toList(),
              onChanged: (hospital) async {
                setState(() {
                  _selectedHospital = hospital;
                  _selectedDoctor = null;
                });
                
                if (hospital != null) {
                  final doctors = await _getDoctorsForHospital(hospital.id);
                  setState(() {
                    _hospitalDoctors = doctors;
                  });
                }
              },
            );
          },
        ),
        if (_selectedHospital != null && _hospitalDoctors != null) ...[
          SizedBox(height: 16),
          DropdownButtonFormField<UserModel>(
            value: _selectedDoctor,
            decoration: InputDecoration(
              labelText: S.of(context).chooseDoctor,
              border: OutlineInputBorder(),
            ),
            items: _hospitalDoctors!.map((doctor) {
              return DropdownMenuItem(
                value: doctor,
                child: Text('${doctor.doctorTitle} ${doctor.firstName} ${doctor.lastName} - ${doctor.specialization}'),
              );
            }).toList(),
            onChanged: (doctor) {
              setState(() => _selectedDoctor = doctor);
              if (doctor != null && _selectedHospital != null) {
                widget.onSelectionComplete(_selectedHospital!, doctor);
              }
            },
          ),
        ],
      ],
    );
  }
} 