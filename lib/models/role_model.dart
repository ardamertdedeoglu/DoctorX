enum UserRole {
  doctor,
  patient
}

class DoctorDetails {
  final String hospital;
  final String title;
  final String specialization;
  final String licenseNumber;
  final List<String>? patientIds;

  DoctorDetails({
    required this.hospital,
    required this.title,
    required this.specialization,
    required this.licenseNumber,
    this.patientIds,
  });

  factory DoctorDetails.fromJson(Map<String, dynamic> json) {
    return DoctorDetails(
      hospital: json['hospital'] ?? '',
      title: json['title'] ?? '',
      specialization: json['specialization'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
      patientIds: List<String>.from(json['patientIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'hospital': hospital,
    'title': title,
    'specialization': specialization,
    'licenseNumber': licenseNumber,
    'patientIds': patientIds,
  };
}
