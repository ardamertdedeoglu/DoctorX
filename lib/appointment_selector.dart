import 'package:flutter/material.dart';

class AppointmentSelector extends StatefulWidget {
  final Function(DateTime) onAppointmentSelected;

  const AppointmentSelector({
    super.key,
    required this.onAppointmentSelected,
  });

  @override
  _AppointmentSelectorState createState() => _AppointmentSelectorState();
}

class _AppointmentSelectorState extends State<AppointmentSelector> {
  DateTime? selectedDate;
  int? selectedHour;
  final List<int> availableHours = [10, 12, 14, 16, 18];

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedHour = null; // Reset hour when date changes
      });
    }
  }

  void _selectHour(int hour) {
    setState(() {
      selectedHour = hour;
    });

    if (selectedDate != null) {
      final selectedDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        hour,
      );
      widget.onAppointmentSelected(selectedDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          onPressed: _selectDate,
          icon: Icon(Icons.calendar_today),
          label: Text(
            selectedDate == null
                ? 'Tarih Seçin'
                : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
          ),
        ),
        if (selectedDate != null) ...[
          SizedBox(height: 16),
          Text(
            'Müsait Saatler:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableHours.map((hour) {
              final isSelected = selectedHour == hour;
              return ElevatedButton(
                onPressed: () => _selectHour(hour),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
                  foregroundColor: isSelected ? Colors.white : Colors.black,
                ),
                child: Text('$hour:00'),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
