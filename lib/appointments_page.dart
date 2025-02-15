import 'package:flutter/material.dart';
import 'appointment_model.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctorx/generated/l10n.dart';

class AppointmentsPage extends StatelessWidget {
  final int initialTab;
  final AppointmentModel? highlightedAppointment;

  const AppointmentsPage({
    super.key,
    this.initialTab = 0,
    this.highlightedAppointment,
  });

  Stream<List<AppointmentModel>> _getAppointmentsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID to data
        return AppointmentModel.fromJson(data);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    
    return StreamBuilder<List<AppointmentModel>>(
      stream: _getAppointmentsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(S.of(context).quickAppointmentsList)),
            body: Center(child: Text('${S.of(context).basicErrorMessage} ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text(S.of(context).quickAppointmentsList)),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final allAppointments = snapshot.data ?? [];
        final now = DateTime.now();
        final upcomingAppointments = allAppointments
            .where((apt) => apt.dateTime.isAfter(now))
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
        
        final pastAppointments = allAppointments
            .where((apt) => apt.dateTime.isBefore(now))
            .toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime)); // Reverse chronological

        return DefaultTabController(
          length: 2,
          initialIndex: initialTab,
          child: Scaffold(
            appBar: AppBar(
              title: Text(S.of(context).quickAppointmentsList),
              bottom: TabBar(
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_available),
                        SizedBox(width: 8),
                        Text('${S.of(context).futureAppointments} (${upcomingAppointments.length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history),
                        SizedBox(width: 8),
                        Text('${S.of(context).pastAppointments} (${pastAppointments.length})'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildAppointmentList(context, upcomingAppointments, true, isDarkMode),
                _buildAppointmentList(context, pastAppointments, false, isDarkMode),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentList(BuildContext context, List<AppointmentModel> appointments, bool isUpcoming, bool isDarkMode) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming ? Icons.event_available : Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              isUpcoming 
                ? S.of(context).noUpcomingAppointments
                : S.of(context).noPastAppointments,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final apt = appointments[index];
        final isHighlighted = highlightedAppointment?.id == apt.id;

        return Card(
          elevation: isHighlighted ? 8 : 2,
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isHighlighted 
              ? BorderSide(color: Colors.blue, width: 2)
              : BorderSide.none,
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isUpcoming ? Colors.green[100] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        apt.doctorType,
                        style: TextStyle(
                          color: isUpcoming ? Colors.green[900] : Colors.grey[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Spacer(),
                    if (isUpcoming)
                      PopupMenuButton(
                        icon: Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit, color: Colors.blue),
                              title: Text(S.of(context).editButton),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'cancel',
                            child: ListTile(
                              leading: Icon(Icons.cancel, color: Colors.red),
                              title: Text(S.of(context).cancel),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                        onSelected: (value) async {
                          if (value == 'edit') {
                            final now = DateTime.now();
                            final daysDifference = apt.dateTime.difference(now).inDays;
                            
                            if (daysDifference < 3) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(S.of(context).cantEditAppointmentWithin3Days)),
                              );
                              return;
                            }

                            // Show time picker for the same day
                            final newTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(apt.dateTime),
                            );

                            if (newTime != null) {
                              // Create new DateTime with same date but new time
                              final newDateTime = DateTime(
                                apt.dateTime.year,
                                apt.dateTime.month,
                                apt.dateTime.day,
                                newTime.hour,
                                newTime.minute,
                              );

                              // Yeni zaman bilgilerini formatla
                              final newTimeStr = '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';
                              
                              // Firebase'i güncelle
                              await FirebaseFirestore.instance
                                  .collection('appointments')
                                  .doc(apt.id)
                                  .update({
                                    'dateTime': newDateTime.toIso8601String(),
                                    'time': newTimeStr,
                                  });
                            }
                          } else if (value == 'cancel') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(S.of(context).confirmCancellation),
                                content: Text(S.of(context).cancelAppointmentConfirmation),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text(S.of(context).noButton),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text(S.of(context).yesButton),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await FirebaseFirestore.instance
                                  .collection('appointments')
                                  .doc(apt.id)
                                  .delete();
                            }
                          }

                        },
                      ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.blue[100],
                      child: Icon(
                        Icons.person,
                        color: Colors.blue[900],
                        size: 32,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            apt.doctorName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            apt.hospital,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.blue),
                          SizedBox(height: 4),
                          Text(
                            apt.date,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey[300],
                      ),
                      Column(
                        children: [
                          Icon(Icons.access_time, color: Colors.blue),
                          SizedBox(height: 4),
                          Text(
                            apt.time,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}