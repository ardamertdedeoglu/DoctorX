import 'package:flutter/material.dart';
import 'document_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'generated/l10n.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  _DocumentsPageState createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  String? _selectedCategory;
  final _searchController = TextEditingController();

  final List<DocumentModel> _documents = [
    DocumentModel(
      title: 'Diyabet Nedir?',
      category: 'Diyabet',
      summary: 'Diyabet hastalığı hakkında temel bilgiler',
      content: 'Diyabet, vücudunuzun kan şekerini (glikoz) düzenleyen insülin hormonunu '
          'yeterince üretemediği veya etkili kullanamadığı bir metabolizma hastalığıdır...',
      author: 'Dr. Ahmet Yılmaz',
      date: '01/02/2024',
    ),
    DocumentModel(
      title: 'Tip 2 Diyabet Tedavisi',
      category: 'Diyabet',
      summary: 'Tip 2 diyabet tedavi yöntemleri',
      content: 'Tip 2 diyabet tedavisinde beslenme düzeni, egzersiz ve gerekli durumlarda '
          'ilaç tedavisi uygulanır...',
      author: 'Dr. Ayşe Demir',
      date: '05/02/2024',
    ),
    DocumentModel(
      title: 'Sağlıklı Beslenme Rehberi',
      category: 'Beslenme',
      summary: 'Dengeli ve sağlıklı beslenme önerileri',
      content: 'Sağlıklı beslenme, vücudumuzun ihtiyaç duyduğu tüm besin öğelerini '
          'dengeli bir şekilde almayı gerektirir...',
      author: 'Dyt. Zeynep Kaya',
      date: '10/02/2024',
    ),
  ];

  List<DocumentModel> get filteredDocuments {
    return _documents.where((doc) {
      final matchesCategory = _selectedCategory == S.of(context).allReports || 
                            doc.category == _selectedCategory;
      final matchesSearch = doc.title.toLowerCase()
          .contains(_searchController.text.toLowerCase()) ||
          doc.summary.toLowerCase()
          .contains(_searchController.text.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _showDocumentDetail(DocumentModel document) async {
    final prefs = await SharedPreferences.getInstance();
    // Dokümanı okundu olarak işaretle
    document.isRead = true;
    // Durumu kaydet
    await prefs.setBool('doc_${document.title}_read', true);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(document.title),
            Text(
              '${document.author} - ${document.date}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(document.content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).close),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = S.of(context).allReports;
    _loadReadStatus();
  }

  Future<void> _loadReadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var doc in _documents) {
        doc.isRead = prefs.getBool('doc_${doc.title}_read') ?? false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final categories = [S.of(context).allReports, ..._documents.map((e) => e.category).toSet()];
    
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).documents),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Arama çubuğu
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: S.of(context).searchDocuments,
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                SizedBox(height: 16),
                // Kategori filtreleri
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: _selectedCategory == category,
                          label: Text(category),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category : S.of(context).allReports;
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
              itemCount: filteredDocuments.length,
              itemBuilder: (context, index) {
                final doc = filteredDocuments[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Row(
                      children: [
                        Expanded(child: Text(doc.title)),
                        if (doc.isRead)
                          Icon(Icons.check_circle, 
                            color: Colors.green, 
                            size: 16
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doc.summary),
                        SizedBox(height: 4),
                        Text(
                          '${doc.author} - ${doc.date}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () => _showDocumentDetail(doc),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
