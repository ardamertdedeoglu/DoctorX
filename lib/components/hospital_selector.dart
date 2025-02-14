import 'package:flutter/material.dart';
import '../models/hospital_model.dart';
import '../services/hospital_service.dart';
import 'package:doctorx/generated/l10n.dart';

class HospitalSelector extends StatefulWidget {
  final Function(HospitalModel hospital, DoctorModel doctor) onSelectionComplete;

  const HospitalSelector({
    super.key,
    required this.onSelectionComplete,
  });

  @override
  _HospitalSelectorState createState() => _HospitalSelectorState();
}

class _HospitalSelectorState extends State<HospitalSelector> {
  HospitalModel? selectedHospital;
  DoctorModel? selectedDoctor;

  final hospitals = HospitalService.getHospitals();

  List<DoctorModel> _getAllDoctors(HospitalModel hospital) {
    return hospital.departments.expand((dept) => dept.doctors).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hospital selection remains.
        DropdownButtonFormField<HospitalModel>(
          decoration: InputDecoration(
            labelText: S.of(context).chooseHospitalLabel,
            border: OutlineInputBorder(),
          ),
          value: selectedHospital,
          items: hospitals.map((hospital) {
            return DropdownMenuItem(
              value: hospital,
              child: Text(hospital.name),
            );
          }).toList(),
          onChanged: (hospital) {
            setState(() {
              selectedHospital = hospital;
              selectedDoctor = null;
            });
          },
        ),
        SizedBox(height: 16),
        // Doctor selection: list all doctors from the selected hospital.
        if (selectedHospital != null)
          DropdownButtonFormField<DoctorModel>(
            decoration: InputDecoration(
              labelText: S.of(context).chooseDoctor,
              border: OutlineInputBorder(),
            ),
            value: selectedDoctor,
            items: _getAllDoctors(selectedHospital!).map((doctor) {
              return DropdownMenuItem(
                value: doctor,
                child: Text('${doctor.title} ${doctor.name}'),
              );
            }).toList(),
            onChanged: (doctor) {
              if (doctor != null) {
                setState(() {
                  selectedDoctor = doctor;
                });
                widget.onSelectionComplete(selectedHospital!, doctor);
              }
            },
          ),
      ],
    );
  }
}
