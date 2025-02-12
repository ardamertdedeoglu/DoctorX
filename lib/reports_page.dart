import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart' show SfPdfViewer;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'reports_model.dart';
import 'theme_provider.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _selectedDepartment = 'Tümü';
  final _searchController = TextEditingController();

  final List<ReportsModel> _reports = [
    ReportsModel(
      title: 'Kan Tahlili Sonucu',
      department: 'Dahiliye',
      doctor: 'Dr. Ahmet Yılmaz',
      date: '15/01/2024',
      pdfUrl: 'assets/reports/kan_tahlili.pdf',
    ),
    ReportsModel(
      title: 'EKG Raporu',
      department: 'Kardiyoloji',
      doctor: 'Dr. Ayşe Demir',
      date: '18/01/2024',
      pdfUrl: 'assets/reports/ekg_raporu.pdf',
    ),
    ReportsModel(
      title: 'Akciğer Filmi',
      department: 'Göğüs Hastalıkları',
      doctor: 'Dr. Mehmet Kaya',
      date: '22/01/2024',
      pdfUrl: 'assets/reports/akciger_filmi.pdf',
    ),
    ReportsModel(
      title: 'MR Görüntüleme Sonucu',
      department: 'Nöroloji',
      doctor: 'Dr. Zeynep Şahin',
      date: '25/01/2024',
      pdfUrl: 'assets/reports/mr_sonuc.pdf',
    ),
  ];

  List<ReportsModel> get _filteredReports {
    return _reports.where((report) =>
      !report.isDeleted &&
      (_selectedDepartment == 'Tümü' || report.department == _selectedDepartment) &&
      (report.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
       report.doctor.toLowerCase().contains(_searchController.text.toLowerCase()))
    ).toList();
  }

  Map<String, List<ReportsModel>> get _groupedReports {
    final grouped = <String, List<ReportsModel>>{};
    for (var report in _filteredReports) {
      final monthYear = '${report.month}/${report.year}';
      grouped.putIfAbsent(monthYear, () => []).add(report);
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key))
    );
  }

  Future<void> _openPdfViewer(ReportsModel report) async {
    try {
      final isDarkMode = context.read<ThemeProvider>().isDarkMode;
      
      // Asset'ten PDF'i oku
      final ByteData data = await rootBundle.load(report.pdfUrl);
      final List<int> bytes = data.buffer.asUint8List();

      // Geçici dosya oluştur
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${report.pdfUrl.split('/').last}');
      await tempFile.writeAsBytes(bytes);

      // PDF görüntüleyici sayfasını aç
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(report.title),
              backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
              foregroundColor: isDarkMode ? Colors.white : Colors.black,
            ),
            body: SfPdfViewer.file(
              tempFile,
              canShowScrollHead: true,
              pageSpacing: 8,
            ),
          ),
        ),
      );
    } catch (e) {
      print('PDF Hata: $e'); // Hata ayıklama için
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF görüntülenirken bir hata oluştu: ${e.toString()}')),
      );
    }
  }

  Future<void> _showDeleteConfirmation(ReportsModel report) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Raporu Sil'),
        content: Text('Bu raporu silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Sil'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        report.isDeleted = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rapor başarıyla silindi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final departments = ['Tümü', ..._reports.map((e) => e.department).toSet()];
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Raporlarım'),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rapor veya doktor ara...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: departments.map((dept) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: _selectedDepartment == dept,
                          label: Text(dept),
                          onSelected: (selected) {
                            setState(() {
                              _selectedDepartment = selected ? dept : 'Tümü';
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _groupedReports.length,
              itemBuilder: (context, index) {
                final monthYear = _groupedReports.keys.elementAt(index);
                final reportsInMonth = _groupedReports[monthYear]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        monthYear,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...reportsInMonth.map((report) => Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(report.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(report.doctor),
                            Text(
                              '${report.department} - ${report.date}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_red_eye),
                              tooltip: 'Görüntüle',
                              onPressed: () => _openPdfViewer(report),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Sil',
                              onPressed: () => _showDeleteConfirmation(report),
                            ),
                          ],
                        ),
                        onTap: () => _openPdfViewer(report),
                      ),
                    )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}