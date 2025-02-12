class HospitalModel {
  final String id;
  final String name;
  final String address;
  final List<DepartmentModel> departments;

  HospitalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.departments,
  });
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
