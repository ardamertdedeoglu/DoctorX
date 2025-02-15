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
  HospitalModel? _selectedHospital;
  DoctorModel? _selectedDoctor;
  late List<HospitalModel> _hospitals;

  @override
  void initState() {
    super.initState();
    // Başlangıç listesini direkt oluştur
    _hospitals = HospitalService.baseHospitals;
  }

  List<HospitalModel> _getLocalizedHospitals() {
    return _hospitals.map((hospital) {
      String name = hospital.name;
      if (name.contains('Merkez')) {
        return HospitalModel(
          id: hospital.id,
          name: 'Merkez ${S.of(context).hospital}',
          address: hospital.address,
          departments: hospital.departments,
        );
      } else if (name.contains('Şehir')) {
        return HospitalModel(
          id: hospital.id,
          name: 'Şehir ${S.of(context).hospital}',
          address: hospital.address,
          departments: hospital.departments,
        );
      }
      return hospital;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final localizedHospitals = _getLocalizedHospitals();
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Hastane Seçimi
        DropdownButtonFormField<HospitalModel>(
          value: _selectedHospital,
          hint: Text(S.of(context).chooseHospitalLabel),
          isExpanded: true,
          items: localizedHospitals.map((hospital) => DropdownMenuItem(
            value: hospital,
            child: Text(
              hospital.name,
              overflow: TextOverflow.ellipsis,
            ),
          )).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedHospital = newValue;
              _selectedDoctor = null; // Hastane değişince doktoru sıfırla
            });
          },
        ),
        
        SizedBox(height: 16),
        
        // Doktor Seçimi
        if (_selectedHospital != null) ...[
          DropdownButtonFormField<DoctorModel>(
            value: _selectedDoctor,
            hint: Text(S.of(context).chooseDoctor),
            isExpanded: true,
            items: _selectedHospital!.departments
                .expand((dept) => dept.doctors)
                .map((doctor) => DropdownMenuItem(
                      value: doctor,
                      child: Text(
                        '${doctor.title} ${doctor.name}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: (doctor) {
              setState(() {
                _selectedDoctor = doctor;
                if (doctor != null) {
                  widget.onSelectionComplete(_selectedHospital!, doctor);
                }
              });
            },
          ),
        ],
      ],
    );
  }
}
