class HospitalModel {
  final String id;
  String name;
  final String address;
  final List<DepartmentModel> departments;

  HospitalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.departments,
  });

  HospitalModel copyWith({
    String? id,
    String? name,
    String? address,
    List<DepartmentModel>? departments,
  }) {
    return HospitalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      departments: departments ?? this.departments,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HospitalModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DepartmentModel {
  final String id;
  final String name;
  final List<DoctorModel> doctors;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.doctors,
  });
}

class DoctorModel {
  final String id;
  final String name;
  final String title;
  final String departmentId;
  final List<DateTime> availableSlots;

  DoctorModel({
    required this.id,
    required this.name,
    required this.title,
    required this.departmentId,
    required this.availableSlots,
  });
}
