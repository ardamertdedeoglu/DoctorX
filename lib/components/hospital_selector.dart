import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hospital_model.dart';
import '../services/hospital_service.dart';
import '../generated/l10n.dart';

class HospitalSelector extends StatefulWidget {
  final Function(HospitalModel, DoctorModel?) onSelectionComplete;
  final bool showDoctors;

  const HospitalSelector({
    Key? key,
    required this.onSelectionComplete,
    this.showDoctors = true,
  }) : super(key: key);

  @override
  _HospitalSelectorState createState() => _HospitalSelectorState();
}

class _HospitalSelectorState extends State<HospitalSelector> {
  HospitalModel? selectedHospital;
  DoctorModel? selectedDoctor;
  bool _isLoadingDoctors = false;

  void _handleDoctorSelection(DoctorModel? doctor) {
    if (!mounted) return;
    
    setState(() {
      selectedDoctor = doctor;
    });

    if (selectedHospital != null) {
      widget.onSelectionComplete(selectedHospital!, doctor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: FutureBuilder<List<HospitalModel>>(
              future: HospitalService(context).getHospitals(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final hospitals = snapshot.data ?? [];

                return InputDecorator(
                  decoration: InputDecoration(
                    labelText: S.of(context).hospital,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<HospitalModel>(
                      value: selectedHospital,
                      isExpanded: true,
                      hint: Text(S.of(context).chooseHospitalLabel),
                      items: hospitals.map((hospital) {
                        return DropdownMenuItem(
                          value: hospital,
                          child: Text(
                            hospital.name,
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }).toList(),
                      onChanged: (hospital) {
                        if (hospital != null) {
                          setState(() {
                            selectedHospital = hospital;
                            selectedDoctor = null;
                            _isLoadingDoctors = false;
                          });
                          widget.onSelectionComplete(hospital, null);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.showDoctors && selectedHospital != null) ...[
            SizedBox(height: 16),
            if (_isLoadingDoctors)
              Center(child: CircularProgressIndicator())
            else
              InputDecorator(
                decoration: InputDecoration(
                  labelText: S.of(context).chooseDoctor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<DoctorModel>(
                    value: selectedDoctor,
                    isExpanded: true,
                    hint: Text(S.of(context).chooseDoctor),
                    items: selectedHospital?.departments
                        .expand((dept) => dept.doctors)
                        .map((doctor) {
                          return DropdownMenuItem(
                            value: doctor,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${doctor.title} ${doctor.name}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList() ?? [],
                    onChanged: _handleDoctorSelection,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
