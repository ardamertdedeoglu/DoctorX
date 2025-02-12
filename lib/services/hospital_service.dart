import '../models/hospital_model.dart';

class HospitalService {
  static final List<HospitalModel> hospitals = [
    HospitalModel(
      id: '1',
      name: 'Merkez Hastanesi',
      address: 'Merkez Mah. Hastane Cad. No:1',
      departments: [
        DepartmentModel(
          id: '1',
          name: 'Dahiliye',
          doctors: [
            DoctorModel(
              id: '1',
              name: 'Ahmet Yılmaz',
              title: 'Prof. Dr.',
              departmentId: '1',
              availableSlots: _generateTimeSlots(),
            ),
            DoctorModel(
              id: '2',
              name: 'Ayşe Kaya',
              title: 'Doç. Dr.',
              departmentId: '1',
              availableSlots: _generateTimeSlots(),
            ),
          ],
        ),
        DepartmentModel(
          id: '2',
          name: 'Kardiyoloji',
          doctors: [
            DoctorModel(
              id: '3',
              name: 'Mehmet Demir',
              title: 'Prof. Dr.',
              departmentId: '2',
              availableSlots: _generateTimeSlots(),
            ),
          ],
        ),
      ],
    ),
    HospitalModel(
      id: '2',
      name: 'Şehir Hastanesi',
      address: 'Yeni Mah. Şehir Hastanesi Cad. No:5',
      departments: [
        DepartmentModel(
          id: '3',
          name: 'Dahiliye',
          doctors: [
            DoctorModel(
              id: '4',
              name: 'Zeynep Şahin',
              title: 'Uzm. Dr.',
              departmentId: '3',
              availableSlots: _generateTimeSlots(),
            ),
          ],
        ),
        DepartmentModel(
          id: '4',
          name: 'Nöroloji',
          doctors: [
            DoctorModel(
              id: '5',
              name: 'Can Yıldız',
              title: 'Prof. Dr.',
              departmentId: '4',
              availableSlots: _generateTimeSlots(),
            ),
            DoctorModel(
              id: '6',
              name: 'Elif Öztürk',
              title: 'Doç. Dr.',
              departmentId: '4',
              availableSlots: _generateTimeSlots(),
            ),
          ],
        ),
      ],
    ),
  ];

  static List<DateTime> _generateTimeSlots() {
    final now = DateTime.now();
    final slots = <DateTime>[];
    
    // Gelecek 14 gün için randevu slotları oluştur
    for (var i = 1; i <= 14; i++) {
      final date = now.add(Duration(days: i));
      // Her gün için 09:00-17:00 arası saatlik slotlar
      for (var hour = 9; hour < 17; hour++) {
        slots.add(DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          0,
        ));
      }
    }
    return slots;
  }

  static List<HospitalModel> getHospitals() => hospitals;
  
  static HospitalModel? getHospitalById(String id) {
    try {
      return hospitals.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }
}
