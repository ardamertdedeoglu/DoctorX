class HospitalModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String? imageUrl;
  final List<DepartmentModel> departments;

  HospitalModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.imageUrl,
    required this.departments,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      imageUrl: json['imageUrl'],
      departments: List<DepartmentModel>.from(
        json['departments'].map((x) => DepartmentModel.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'imageUrl': imageUrl,
      'departments': List<dynamic>.from(departments.map((x) => x.toJson())),
    };
  }

  HospitalModel copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? imageUrl,
    List<DepartmentModel>? departments,
  }) {
    return HospitalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
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

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      doctors: List<DoctorModel>.from(
        json['doctors'].map((x) => DoctorModel.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'doctors': List<dynamic>.from(doctors.map((x) => x.toJson())),
    };
  }
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

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      departmentId: json['departmentId'] ?? '',
      availableSlots: List<DateTime>.from(
        json['availableSlots'].map((x) => DateTime.parse(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'departmentId': departmentId,
      'availableSlots': List<String>.from(availableSlots.map((x) => x.toIso8601String())),
    };
  }
}
