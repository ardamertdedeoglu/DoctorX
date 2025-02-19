import 'package:flutter/material.dart';
import '../generated/l10n.dart';

class PatientCard {
  final String name;
  final String email;
  final String lastSeen;
  final String imageUrl;

  PatientCard({
    required this.name,
    required this.email,
    required this.lastSeen,
    required this.imageUrl,
  });
}

class PatientListSection extends StatefulWidget {
  const PatientListSection({super.key});

  @override
  _PatientListSectionState createState() => _PatientListSectionState();
}

class _PatientListSectionState extends State<PatientListSection> {
  final List<PatientCard> allPatients = [
    PatientCard(
      name: "Ayşe Yılmaz",
      email: "ayse.yilmaz@email.com",
      lastSeen: "2024-02-15",
      imageUrl: "https://picsum.photos/200/200?random=1",
    ),
    PatientCard(
      name: "Mehmet Demir",
      email: "mehmet.demir@email.com",
      lastSeen: "2024-02-14",
      imageUrl: "https://picsum.photos/200/200?random=2",
    ),
    PatientCard(
      name: "Zeynep Kaya",
      email: "zeynep.kaya@email.com",
      lastSeen: "2024-02-13",
      imageUrl: "https://picsum.photos/200/200?random=3",
    ),
    PatientCard(
      name: "Ali Öztürk",
      email: "ali.ozturk@email.com",
      lastSeen: "2024-02-12",
      imageUrl: "https://picsum.photos/200/200?random=4",
    ),
  ];
  
  List<PatientCard> filteredPatients = [];
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredPatients = allPatients;
    
    searchController.addListener(() {
      filterPatients();
    });
  }

  void filterPatients() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredPatients = allPatients.where((patient) {
        return patient.name.toLowerCase().contains(query) ||
               patient.email.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override 
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: S.of(context).searchPatients,
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredPatients.length,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final patient = filteredPatients[index];
              return Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(patient.imageUrl),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              patient.email,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "${S.of(context).lastSeen}: ${patient.lastSeen}",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(Icons.message, color: Colors.blue),
                            onPressed: () {
                              // Mesajlaşma işlevi devre dışı
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(S.of(context).featureNotAvailable)),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.phone, color: Colors.green),
                            onPressed: () {
                              // Arama işlevi devre dışı
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(S.of(context).featureNotAvailable)),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
