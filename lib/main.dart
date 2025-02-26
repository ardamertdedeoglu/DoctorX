import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:io';
import 'generated/l10n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Local imports
import 'theme_provider.dart';
import 'diabetes_page.dart';
import 'documents_page.dart';
import 'reports_page.dart';
import 'search_item_model.dart';
import 'appointments_page.dart';
import 'wallet_page.dart';
import 'appointment_service.dart';
import 'appointment_selector.dart';
import 'models/hospital_model.dart';
import 'components/hospital_selector.dart';
import 'services/hospital_service.dart';
import 'widgets/account_switcher.dart';
import 'widgets/account_type_dialog.dart';
import 'signup.dart';
import 'login.dart';
import 'home_page.dart';
import 'models/user_model.dart';
import 'news_detail.dart';
import 'news_model.dart';
import 'chatMessage_model.dart';
import 'packageItem_model.dart';
import 'appointment_model.dart';
import 'wallet_model.dart';
import 'services/profile_image_service.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'widgets/profile_image.dart';
import 'services/family_service.dart';
import 'doctor_home_page.dart';
import 'models/role_model.dart';
import 'widgets/patient_list_section.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'DoctorX',
          localizationsDelegates: [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            cardColor: Colors.white,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.grey[900],
            cardColor: Colors.grey[800],
          ),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          routes: {
            '/': (context) => LoginPage(),
            '/signup': (context) => SignupPage(),
            '/home': (context) => HomePage(),
            '/doctor_home': (context) => DoctorHomePage(), // Add this line
            '/newsDetail': (context) => NewsDetailPage(news: ModalRoute.of(context)!.settings.arguments as NewsModel),
          },
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Properties
  int _selectedIndex = 0;
  UserModel? _userData;
  final picker = ImagePicker();
  final _searchController = TextEditingController();
  bool _showSearchResults = false;

  List<SearchItem>? _searchItems;
  late Map<List<String>, String> _aiResponses;
  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  List<PackageItem>? _packages;
  List<NewsModel>? _news;
  
  // Stream'i nullable yapm;
  Stream<List<AppointmentModel>>? _appointmentsStream;
  AppointmentService? _appointmentService;
  final List<AppointmentModel> _appointments = [];
  
  final ProfileImageService _profileImageService = ProfileImageService();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  // Create a flag to track if initialization has happened
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadInitialData();
  }

  void _initializeServices() {
    _appointmentService = AppointmentService(FirebaseAuth.instance.currentUser?.uid ?? '');
    _appointmentsStream = _appointmentService?.getAppointments();
  }

  Future<void> _loadInitialData() async {
    await _loadUserData(); // Önce kullanıcı verilerini yükle
    _loadPackages();
    _loadNews();
    _initializeSearchItems(); // Sonra arama öğelerini oluştur
    
    // Initialize appointment service
    _appointmentService = AppointmentService(_userData?.id ?? '');
    _appointmentsStream = _appointmentService?.getAppointments();
    
    _initializeFirebase();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_initialized) {
      _initializeAIResponses();
      _loadProfileImage();
      _loadThemeMode();
      _initialized = true;
    }
  }

  List<AppointmentModel> get _upcomingAppointments {
    return _appointments
        .where((apt) => apt.dateTime.isAfter(DateTime.now()))
        .toList();
  }

  void _initializeAIResponses() {
    // Now it's safe to access S.of(context) here
    _aiResponses = {
      ['merhaba', 'selam', 'hello', 'hi', 'mrb', 'slm']: S.of(context).AIGreetingResponse,
      ['nasilsin', 'naber', 'nbr', 'ne haber', 'how are you', 'how you doing', 'whats up']: S.of(context).AIChattingResponse,
      ['randevu', 'randavu', 'randevu almak', 'randevu al', 'appointment']: S.of(context).AIAppointmentResponse,
      ['doktor', 'doctor', 'dr', 'hekim']: S.of(context).AIDoctorResponse,
      ['fiyat', 'fiyatlar', 'ucret', 'price']: S.of(context).AIPriceResponse,
      ['tesekkur', 'teşekkür', 'tesekkurler', 'teşekkürler', 'thanks', 'ty']: S.of(context).AIThanksResponse,
    };
  }

  String _getAIResponse(String message) {
    String lowercaseMessage = message.toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
    
    for (var entry in _aiResponses.entries) {
      if (entry.key.any((keyword) => 
          lowercaseMessage.contains(keyword) || 
          lowercaseMessage.contains(keyword
              .replaceAll('ı', 'i')
              .replaceAll('ğ', 'g')
              .replaceAll('ü', 'u')
              .replaceAll('ş', 's')
              .replaceAll('ö', 'o')
              .replaceAll('ç', 'c')))) {
        return entry.value;
      }
    }
    return S.of(context).aiErrorMessage;
  }

  void _handleSubmitted(String text) {
    if (text.isEmpty) return;
    
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
      ));
    });
    _messageController.clear();

    // Add delay for AI response
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _messages.add(ChatMessage(
          text: _getAIResponse(text),
          isUser: false,
        ));
      });
    });
  }

  void _initializeFirebase() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _appointmentService = AppointmentService(user.uid);
      _appointmentsStream = _appointmentService?.getAppointments();
    }
  }

  // Add this method to load packages from Firestore
  Future<void> _loadPackages() async {
    _packages = [
      PackageItem(
        title: S.of(context).donation,
        description: S.of(context).donationDesc,
        price: 100.0,
      ),
      PackageItem(
        title: S.of(context).dietician,
        description: S.of(context).dieticianDesc,
        price: 500.0,
      ),
      PackageItem(
        title: S.of(context).therapy,
        description: S.of(context).therapyDesc,
        price: 600.0,
      ),
      PackageItem(
        title: S.of(context).dieticianTherapy,
        description: S.of(context).dieticianTherapyDesc,
        price: 1000.0,
      ),
    ];
  }

  // Add this method to load news from Firestore
  Future<void> _loadNews() async {
    _news = [
      NewsModel(
        title: '${S.of(context).newsTitle} 1',
        summary: S.of(context).newsDesc1,
        content: S.of(context).newsContentPlaceholder,
        imageUrl: 'https://picsum.photos/200',
      ),
      NewsModel(
        title: '${S.of(context).newsTitle} 2',
        summary: S.of(context).newsDesc2,
        content: S.of(context).newsContentPlaceholder,
        imageUrl: 'https://picsum.photos/201',
      ),
      NewsModel(
        title: '${S.of(context).newsTitle} 3',
        summary: S.of(context).newsDesc3,
        content: S.of(context).newsContentPlaceholder,
        imageUrl: 'https://picsum.photos/202',
      ),
      NewsModel(
        title: '${S.of(context).newsTitle} 4',
        summary: S.of(context).newsDesc4,
        content: S.of(context).newsContentPlaceholder,
        imageUrl: 'https://picsum.photos/203',
      ),
    ];
  }

 void _initializeSearchItems() {
    if (_userData == null) return;
    
    _searchItems = [
      // Diyabet bölümü
      SearchItem(
        title: S.of(context).searchItemDiabetesTitle,
        category: S.of(context).searchCategoryHealth,
        description: S.of(context).searchItemDiabetesDesc,
        icon: Icons.vaccines,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DiabetesPage()),
        ),
      ),
      // Dokümanlar
      SearchItem(
        title: S.of(context).searchItemDocumentsTitle,
        category: S.of(context).documents,
        description: S.of(context).searchItemDocumentsDesc,
        icon: Icons.article,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DocumentsPage()),
        ),
      ),
      // Raporlar
      SearchItem(
        title: S.of(context).searchItemReportsTitle,
        category: S.of(context).reports,
        description: S.of(context).searchItemReportsDesc,
        icon: Icons.medical_services,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReportsPage()),
        ),
      ),
      // Paketler için öğeler
      ..._packages!.map((package) => SearchItem(
        title: package.title,
        category: S.of(context).packagesTitle,
        description: package.description,
        icon: Icons.medical_information,
        onTap: () => _showPackageDetails(package),
      )),
      // Randevular için arama öğesi ekle
      SearchItem(
        title: S.of(context).quickAppointmentsList,
        category: S.of(context).appointments,
        description: S.of(context).searchItemAppointmentDesc,
        icon: Icons.calendar_today,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AppointmentsPage()),
        ),
      ),
      // Yaklaşan randevular için arama öğeleri
      ..._upcomingAppointments.map((apt) => SearchItem(
        title: '${apt.doctorType} ${S.of(context).appointmentKeyword}',
        category: S.of(context).upcomingAppointments,
        description: '${apt.doctorName} - ${apt.date} ${apt.time}',
        icon: Icons.event,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentsPage(
              initialTab: 0,
              highlightedAppointment: apt,
            ),
          ),
        ),
      )),
      // Sohbetler sekmesi için arama öğesi
      SearchItem(
        title: S.of(context).searchItemChatsTitle,
        category: S.of(context).chatsTitle,
        description: S.of(context).searchItemChatsDesc,
        icon: Icons.chat,
        onTap: () {
          // PageController ile sayfayı değiştir
          _pageController.animateToPage(
            1, // Chats sayfasının indeksi
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          // SelectedIndex'i güncelle
          setState(() {
            _selectedIndex = 1;
            _searchController.clear();
            _showSearchResults = false;
          });
        },
      ),
      
      // AI yanıtları için arama öğeleri
      ..._aiResponses.entries.map((entry) => SearchItem(
        title: entry.value,
        category: S.of(context).searchItemQuestionsCategory,
        description: '${S.of(context).searchItemQuestionDesc} ${entry.key.first}',
        icon: Icons.question_answer,
        onTap: () {
          setState(() {
            _selectedIndex = 1; // Sohbetler sekmesine geç
            _searchController.clear();
            _showSearchResults = false;
            // Otomatik mesaj gönder
            _messageController.text = entry.key.first;
            _handleSubmitted(entry.key.first);
          });
        },
      )),
    ];
  }

  List<SearchItem> _getFilteredSearchItems(String query) {
    if (_searchItems == null) return [];
    
    final lowercaseQuery = query.toLowerCase();
    return _searchItems!.where((item) {
      return item.title.toLowerCase().contains(lowercaseQuery) ||
             item.category.toLowerCase().contains(lowercaseQuery) ||
             (item.description?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  void _showPackageDetails(PackageItem package) {
    DateTime? selectedDateTime;
    HospitalModel? selectedHospital;
    DoctorModel? selectedDoctor;
    bool isHospitalSelected = false;
    bool isDoctorSelected = false;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(package.title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(package.description),
                Text(
                  '\n${S.of(context).price} ${package.price.toStringAsFixed(2)} TL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 16),
                if (package.title != S.of(context).donation) ...[
                  Divider(),
                  Text(
                    S.of(context).hospitalDoctorTitle,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  HospitalSelector(
                    onSelectionComplete: (hospital, doctor) {
                      setState(() {
                        selectedHospital = hospital;
                        selectedDoctor = doctor;
                        isHospitalSelected = true;
                        isDoctorSelected = doctor != null;
                      });
                    },
                  ),
                  
                  if (isDoctorSelected && selectedDoctor != null) ...[
                    SizedBox(height: 16),
                    Divider(),
                    Text(
                      S.of(context).appointmentDateAndTimeTitle,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    AppointmentSelector(
                      onAppointmentSelected: (dateTime) {
                        setState(() => selectedDateTime = dateTime);
                      },
                    ),
                  ],
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.of(context).close),
            ),
            if (package.title != S.of(context).donation)
              TextButton(
                onPressed: (!isDoctorSelected || selectedDateTime == null) 
                    ? null 
                    : () {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null || !user.emailVerified) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(S.of(context).emailVerificationRequired)),
                          );
                          return;
                        }
                        Navigator.pop(context);
                        _showPackagePaymentDialog(
                          package, 
                          selectedDateTime!,
                          selectedHospital!,
                          selectedDoctor!,
                        );
                      },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green,
                  disabledForegroundColor: Colors.grey,
                ),
                child: Text('${S.of(context).buyKeyword} (${package.price.toStringAsFixed(2)} TL)'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadUserData() async {
    try {
      // 1. Aktif Firebase kullanıcısını kontrol et
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // Kullanıcı oturumu yoksa login sayfasına yönlendir
        Navigator.pushReplacementNamed(context, '/');
        return;
      }

      // 2. Firestore'dan güncel kullanıcı verisini al
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        // 3. State'i güncelle
        setState(() {
          _userData = UserModel.fromJson(userDoc.data()!);
        });

        // 4. SharedPreferences'ı güncelle
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(userDoc.data()));
      }
    } catch (e) {
      print("Error loading user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).userDataLoadError)),
      );
    }
  }

  Future<void> _loadProfileImage() async {
    try {
      if (_userData?.id == null) return;
      
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userData!.id)
          .get();

      if (userDoc.exists) {
        final imageUrl = userDoc.data()?['profileImageUrl'];
        if (mounted) {
          setState(() {
            _userData = _userData?.copyWith(profileImageUrl: imageUrl);
          });
        }
      }
    } catch (e) {
      print("Error loading profile image: $e");
    }
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    context.read<ThemeProvider>().setTheme(isDarkMode);
  }

  Future<void> _saveThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
    context.read<ThemeProvider>().toggleTheme();
  }

  Future<void> _showImageSourceSheet() {
    return showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text(S.of(context).chooseFromGalleryButton),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  _saveImage(pickedFile.path);
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text(S.of(context).cameraButton),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  _saveImage(pickedFile.path);
                }
              },
            ),
            if (_userData?.profileImageUrl != null)  // Fotoğraf varsa kaldırma seçeneğini göster
              ListTile(
                leading: Icon(Icons.delete_forever, color: Colors.red),
                title: Text(S.of(context).removePhotoButton, style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteProfileImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteProfileImage() async {
    try {
      await _profileImageService.deleteProfileImage();

      if (_userData?.id != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userData!.id)
            .update({'profileImageUrl': null});

        setState(() {
          _userData = _userData?.copyWith(profileImageUrl: null);
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil fotoğrafı kaldırıldı')),
        );
      }
    } catch (e) {
      print("Error deleting profile image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotoğraf kaldırılamadı')),
      );
    }
  }

  Future<void> _saveImage(String path) async {
    try {
      final imageUrl = await _profileImageService.uploadProfileImage(File(path));
      if (imageUrl != null) {
        if (_userData?.id != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_userData!.id)
              .update({'profileImageUrl': imageUrl});

          setState(() {
            _userData = _userData?.copyWith(profileImageUrl: imageUrl);
          });
          
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profil fotoğrafı güncellendi')),
          );
        }
      }
    } catch (e) {
      print("Error saving profile image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotoğraf güncellenemedi')),
      );
    }
  }

  // Add this helper method
  bool get _isEmailVerified {
    final user = FirebaseAuth.instance.currentUser;
    return user?.emailVerified ?? false;
  }

  // UI Building methods
  PreferredSizeWidget _buildAppBar() {
    String getTitle() {
      switch (_selectedIndex) {
        case 0:
          return S.of(context).mainMenuTitle;
        case 1:
          return S.of(context).chatsTitle;
        case 2:
          return S.of(context).packagesTitle;
        default:
          return 'DoctorX';
      }
    }
    String getInfo() {
      switch (_selectedIndex) {
        case 0:
          return   // Başlıklar büyük harf
              S.of(context).mainMenuDesc; // Açıklamalar küçük harf
        case 1:
          return   // Başlıklar büyük harf
              S.of(context).chatsDesc; // Açıklamalar küçük harf
        case 2:
          return   // Başlıklar büyük harf
              S.of(context).packagesDesc; // Açıklamalar küçük harf 
        default:
          return 'DOCTORX UYGULAMASI';  // Başlık büyük harf
      }
    }
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    return AppBar(
      backgroundColor: isDarkMode 
          ? Colors.grey[900]  // Koyu tema için siyah
          : Colors.white,  // Açık tema için yeşil
      iconTheme: IconThemeData(
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      titleTextStyle: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      title: Text(getTitle()),
      leading: IconButton(
        iconSize: 30.0,
        icon: Icon(Icons.info_outline),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  getTitle().toUpperCase(),  // Başlığı büyük harf yap
                  style: TextStyle(
                    fontWeight: FontWeight.bold,  // Başlığı kalın yap
                  ),
                ),
                content: SingleChildScrollView(
                  child: Text(
                    getInfo(),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                // ...existing dialog code...
              );
            },
          );
        },
      ),
      actions: <Widget>[
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final headerBackground = isDarkMode 
      ? [Colors.indigo[900]!, Colors.blue[900]!]
      : [Colors.blue[700]!, Colors.purple[500]!];
    
    return Drawer(
      child: Container(
        width: double.infinity, // Tam genişlik
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode 
              ? [Colors.grey[900]!, Colors.grey[800]!]
              : [Colors.white, Colors.grey[100]!],
          ),
        ),
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity, // Header'ı tam genişlikte yap
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: headerBackground,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: SafeArea(
                minimum: EdgeInsets.all(16), // İçeriğe minimum padding ekle
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _showProfileDialog();
                        },
                        child: ProfileImage(
                          imageUrl: _userData?.profileImageUrl,
                          radius: 40,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_userData?.firstName ?? ''} ${_userData?.lastName ?? ''}' == ' ' ? 'Kullanıcı' : '${_userData?.firstName ?? ''} ${_userData?.lastName ?? ''}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_isEmailVerified) ...[
                          SizedBox(width: 8),
                          Icon(
                            Icons.verified,
                            color: Colors.green,
                            size: 24,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _userData?.email ?? 'kullanici@email.com',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_userData?.accountType == 'parent' && _userData?.linkedAccounts != null)
              AccountSwitcher(
                currentUser: _userData!,
                onAccountChanged: (selectedAccount) async {
                  try {
                    final selectedUserDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(selectedAccount.id)
                      .get();
              
                    if (selectedUserDoc.exists) {
                      final selectedUserData = UserModel.fromJson(selectedUserDoc.data()!);
                      
                      // Update SharedPreferences
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('user_data', jsonEncode(selectedUserData.toJson()));
                      
                      // Önce servisleri güncelle
                      setState(() {
                        _userData = selectedUserData;
                        _appointmentService = AppointmentService(selectedUserData.id ?? '');
                        _appointmentsStream = _appointmentService?.getAppointments();
                      });
                      
                      // Close drawer and show success message
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${S.of(context).welcomeMessage} ${selectedUserData.firstName}')),
                      );
                      
                      // Refresh UI components
                      await _loadInitialData(); // Tüm verileri yeniden yükle
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(S.of(context).errorSwitchingAccount)),
                      );
                    }
                  } catch (e) {
                    print('Error switching account: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${S.of(context).errorSwitchingAccount}: $e')),
                    );
                  }
                },
              ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.vaccines),
                    title: Text(S.of(context).diabetes),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DiabetesPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.article),
                    title: Text(S.of(context).documents),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DocumentsPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.medical_services),
                    title: Text(S.of(context).reports),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ReportsPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text(S.of(context).appointments),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AppointmentsPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.account_balance_wallet),
                    title: Text(S.of(context).wallet),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WalletPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.info, size: 24),
                    title: Text(S.of(context).aboutUsTitle),
                    onTap: () {
                      Navigator.pop(context);  // Önce Drawer'ı kapat
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              S.of(context).aboutUsTitle.toUpperCase(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(S.of(context).producersTitle, style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Hüseyin Karateke\nEsma Koca\nBeyza Ak\nArda Mert Dedeoğlu\nReyyan Eskicioğlu'),
                                SizedBox(height: 16),
                                Text(S.of(context).timeOfRelease, style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(S.of(context).timeOfReleaseValue),
                                SizedBox(height: 16),
                                Text(S.of(context).goal, style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(S.of(context).goalDesc),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(S.of(context).close),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  Divider(),
                  SwitchListTile(
                    title: Text(isDarkMode ? S.of(context).darkMode : S.of(context).lightMode),
                    value: isDarkMode,
                    onChanged: (bool value) {
                      _saveThemeMode(value);
                    },
                    secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(height: 30.0),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color.fromARGB(255, 214, 250, 12),
              width: 4.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: GestureDetector(
            onTap: () => _showProfileDialog(), // Sadece profil dialogunu aç
            child: ProfileImage(
              imageUrl: _userData?.profileImageUrl,
              radius: 100,
            ),
          ),
        ),
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${S.of(context).welcomeMainMenu} ${_userData?.firstName ?? ''}',
              textDirection: TextDirection.ltr,
              style: TextStyle(
                fontSize: 20.0,
                color: const Color.fromARGB(255, 241, 40, 4),
                fontWeight: FontWeight.bold
              ),
            ),
            if (_isEmailVerified) ...[
              SizedBox(width: 8),
              Icon(
                Icons.verified,
                color: Colors.green,
                size: 24,
              ),
            ],
          ],
        ),
        SizedBox(height: 20.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: TextField(
            controller: _searchController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              helperText: S.of(context).searchHelper,
              prefixIcon: Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _showSearchResults = false;
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(),
              labelText: S.of(context).searchLabel,
            ),
            onChanged: (value) {
              setState(() {
                _showSearchResults = value.isNotEmpty;
              });
            },
          ),
        ),
      ],
    );
  }

  Future<void> _sendVerificationEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  S.of(context).emailVerificationSent)),
        );
      } else if (user!.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).emailAlreadyVerified)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  S.of(context).AccountFindError)),
        );
      }
    } catch (e) {
      print("Error sending verification email: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${S.of(context).emailVerificationTechnicalError} ${e.toString()}')),
      );
    }
  }

  void _showProfileDialog() {
    final newEmailController = TextEditingController(text: _userData?.email);
    final newPasswordController = TextEditingController();
    final titleController = TextEditingController(text: _userData?.doctorTitle);
    final specializationController = TextEditingController(text: _userData?.specialization);
    final licenseController = TextEditingController(text: _userData?.licenseNumber);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).profileDialogTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profil fotoğrafı kısmı
              Center(
                child: Stack(
                  children: [
                    ProfileImage(
                      imageUrl: _userData?.profileImageUrl,
                      radius: 50,
                      onTap: () {
                        Navigator.pop(context);
                        _showImageSourceSheet();
                      },
                      badge: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              
              // Kullanıcı bilgileri
              Text('${S.of(context).firstName}: ${_userData?.firstName}'),
              Text('${S.of(context).lastName}: ${_userData?.lastName}'),
              Text('${S.of(context).emailLabel}: ${_userData?.email}'),
              
              // Hesap türü
              SizedBox(height: 16),
              Text(
                '${S.of(context).accountType} ${_userData?.role == UserRole.doctor 
                  ? S.of(context).doctorAccount 
                  : _userData?.accountType == 'parent' 
                    ? S.of(context).parentAccount 
                    : S.of(context).normalAccount}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              // Doktor bilgileri veya hesap yükseltme butonu
              if (_userData?.role == UserRole.doctor) ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: S.of(context).doctorTitle,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: specializationController,
                        decoration: InputDecoration(
                          labelText: S.of(context).specialization,
                          hintText: S.of(context).specializationHintText,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: licenseController,
                        decoration: InputDecoration(
                          labelText: S.of(context).licenseNumber,
                          hintText: S.of(context).licenseNumberHintText,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          // Doktor bilgilerini güncelle
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            final updatedUserModel = UserModel(
                              id: user.uid,
                              role: UserRole.doctor,
                              firstName: _userData!.firstName,
                              lastName: _userData!.lastName,
                              email: _userData?.email ?? '',
                              accountType: 'doctor',
                              doctorTitle: titleController.text,
                              specialization: specializationController.text,
                              licenseNumber: licenseController.text,
                            );

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .update({
                                  'doctorTitle': titleController.text,
                                  'specialization': specializationController.text,
                                  'licenseNumber': licenseController.text,
                                });

                            setState(() {
                              _userData = updatedUserModel;
                            });

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(S.of(context).passwordUpdateSuccess)),
                            );
                          }
                        },
                        child: Text(S.of(context).updateDoctorInfo),
                      ),
                    ],
                  ),
                ),
              ] else if (_userData?.accountType == 'parent') ...[
                // Ebeveyn hesabı için çocuk ekleme butonu
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddChildDialog(context);
                    },
                    child: Text(S.of(context).addChildAccount),
                  ),
                ),
              ] else ...[
                // Normal hesap için yükseltme butonu
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AccountTypeDialog(
                          onTypeSelected: (accountType) async {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              final updatedUserModel = UserModel(
                                id: user.uid,
                                role: _userData!.role,
                                firstName: _userData!.firstName,
                                lastName: _userData!.lastName,
                                email: _userData?.email ?? '',
                                accountType: accountType,
                                linkedAccounts: [],
                              );

                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .update({'accountType': accountType});

                              setState(() {
                                _userData = updatedUserModel;
                              });
                            }
                          },
                        ),
                      );
                    },
                    child: Text(S.of(context).upgradeToParent),
                  ),
                ),
              ],
              
              // Yeni e-posta ve şifre alanları
              SizedBox(height: 20),
              TextField(
                controller: newEmailController,
                decoration: InputDecoration(
                  labelText: S.of(context).newEmailLabel,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: S.of(context).newPassword,
                  border: OutlineInputBorder(),
                ),
              ),

              // Doktor hesabı ekleme butonu
              if (_userData?.role != UserRole.doctor) ...[
                Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDoctorAccountCreationDialog();
                    },
                    child: Text(S.of(context).addDoctorAccount),
                  ),
                ),
              ],
              
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (newEmailController.text.isNotEmpty || 
                  newPasswordController.text.isNotEmpty) {
                final prefs = await SharedPreferences.getInstance();
                if (newEmailController.text.isNotEmpty) {
                  final updatedUser = UserModel(
                    id: _userData!.id,
                    role: _userData!.role,
                    firstName: _userData!.firstName,
                    lastName: _userData!.lastName,
                    email: newEmailController.text,
                  );
                  await prefs.setString('user_data', jsonEncode(updatedUser.toJson()));
                }
                if (newPasswordController.text.isNotEmpty) {
                  try {
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await user.updatePassword(newPasswordController.text);
                      await prefs.setString('user_password', newPasswordController.text);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(S.of(context).passwordUpdateSuccess)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                S.of(context).AccountFindError)),
                      );
                    }
                  } catch (e) {
                    print("Error updating password: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              '${S.of(context).passwordUpdateError} ${e.toString()}')),
                    );
                  }
                }
                _loadUserData();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(S.of(context).passwordUpdateSuccess)),
                );
              }
            },
            child: Text('Güncelle'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              // Only remove login status, keep user data
              await prefs.remove('is_logged_in');
              // Don't remove user_data or user_password
              Navigator.pushReplacementNamed(context, '/');
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Çıkış Yap'),
          ),
          if (!_isEmailVerified)
            TextButton(
              onPressed: _sendVerificationEmail,
              child: Text(S.of(context).emailVerificitaionButton),
            ),
        ],
      ),
    );
  }

  // Çocuk ekleme dialog'unu ekle
  void _showAddChildDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).childAccountTitle),
        content: Text(S.of(context).childAccountConnectionQuestion),
        actions: [
          TextButton(
            child: Text(S.of(context).noButton),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(S.of(context).yesButton),
            onPressed: () {
              Navigator.pop(context);

              _showChildDetailsDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSection() {
    if (_news == null) return Container(); // Veriler yüklenene kadar boş container göster
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).newsContainer,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _news!.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: _buildNewsCard(_news![index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(NewsModel news) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/newsDetail',
              arguments: news,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    news.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        news.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard() {
    if (_appointmentsStream == null) {
      return Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<List<AppointmentModel>>(
      stream: _appointmentsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final upcomingAppointments = snapshot.data!
            .where((apt) => apt.dateTime.isAfter(DateTime.now()))
            .toList();
        upcomingAppointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        
        return SizedBox(
          height: 300, // Gerekirse bu değeri ayarlayın
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık bölümü
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.event_available, color: Colors.blue, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        S.of(context).upcomingAppointments,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentsPage(),
                        ),
                      ),
                      tooltip: 'Tüm Randevular',
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Randevular listesi veya boş görünüm
              Expanded(
                child: upcomingAppointments.isEmpty
                    ? _buildEmptyAppointmentsView()
                    : ListView.builder(
                        itemCount: upcomingAppointments.length,
                        itemBuilder: (context, index) {
                          final apt = upcomingAppointments[index];
                          return _buildAppointmentItem(apt);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyAppointmentsView() {
    final isDoctor = _userData?.role == UserRole.doctor;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              S.of(context).noUpcomingAppointments,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            if (!isDoctor) ...[  // Sadece hasta için randevu alma butonu göster
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(S.of(context).quickAppointment),
                onPressed: () {
                  _pageController.animateToPage(
                    2,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentItem(AppointmentModel apt) {
    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${apt.dateTime.day}', // Gerçek gün değeri
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            _getMonthAbbreviation(apt.dateTime.month),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      title: Text(
        '${apt.doctorType} ${S.of(context).appointmentKeyword}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('${apt.doctorName} - ${apt.date} ${apt.time}'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _navigateToAppointments(context, highlightedAppointment: apt),
    );
  }

  String _getMonthAbbreviation(int month) {
    switch (month) {
      case 1:
        return S.of(context).january;
      case 2:
        return S.of(context).february;
      case 3:
        return S.of(context).march;
      case 4:
        return S.of(context).april;
      case 5:
        return S.of(context).may;
      case 6:
        return S.of(context).june;
      case 7:
        return S.of(context).july;
      case 8:
        return S.of(context).august;
      case 9:
        return S.of(context).september;
      case 10:
        return S.of(context).october;
      case 11:
        return S.of(context).november;
      case 12:
        return S.of(context).december;
      default:
        return '';
    }
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildProfileSection(),
          if (_showSearchResults)
            Container(
              constraints: BoxConstraints(
                maxHeight: 300, // Maksimum yükseklik sınırı
              ),
              margin: EdgeInsets.symmetric(horizontal: 30.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: _buildSearchResults(_getFilteredSearchItems(_searchController.text)),
            ),
          _buildAppointmentCard(),
          _buildNewsSection(),
        ],
      ),
    );
  }

  Widget _buildChatSection() {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).quickAccessTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_sweep),
                onPressed: () {
                  setState(() {
                    _messages.clear();
                  });
                },
                tooltip: 'Sohbeti Temizle',
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ],
          ),
        ),
        
        // Quick Action Buttons
        Container(
          padding: EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickActionButton(
                icon: Icons.calendar_today,
                label: _userData?.role == UserRole.doctor 
                    ? S.of(context).viewPatients 
                    : S.of(context).quickAppointment,
                onTap: () {
                  if (_userData?.role == UserRole.doctor) {
                    // Doktor için hasta listesi sayfasına git
                    _pageController.animateToPage(
                      2, // Hastalar sekmesi
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    setState(() => _selectedIndex = 2);
                  } else {
                    // Normal kullanıcı için randevu sayfasına git
                    _pageController.animateToPage(
                      2, // Paketler sekmesi
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    setState(() => _selectedIndex = 2);
                  }
                },
                color: Colors.blue,
              ),
              _buildQuickActionButton(
                icon: Icons.vaccines,
                label: S.of(context).diabetes,
                onTap: () {}, // Boş bırak, üstteki logic kullanılacak
                color: Colors.green,
              ),
              _buildQuickActionButton(
                icon: Icons.account_balance_wallet,
                label: S.of(context).wallet,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WalletPage()),
                ),
                color: Colors.purple,
              ),
              _buildQuickActionButton(
                icon: Icons.history,
                label: S.of(context).quickAppointmentsList,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppointmentsPage()),
                ),
                color: Colors.orange,
              ),
            ],
          ),
        ),
        
        Divider(),
        
        // Existing chat messages
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: _messages.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                // AI'nin ilk mesajı
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: isDarkMode ? Colors.blue[900] : Colors.blue[100],
                      child: Icon(Icons.medical_information, size: 20, color: isDarkMode ? Colors.white : Colors.blue),
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.only(right: 80.0, bottom: 12.0),
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          S.of(context).aiFirstMessage,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              
              final message = _messages[index - 1];
              return Row(
                mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end, // Mesaj ile avatar'ı alt hizaya getir
                children: [
                  if (!message.isUser) ...[
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: isDarkMode ? Colors.blue[900] : Colors.blue[100],
                      child: Icon(Icons.medical_information, size: 20, color: isDarkMode ? Colors.white : Colors.blue),
                    ),
                    SizedBox(width: 8),
                  ],
                  Flexible( // Expanded yerine Flexible kullan
                    child: Container(
                      margin: EdgeInsets.only(
                        left: message.isUser ? 80.0 : 0,
                        right: message.isUser ? 0 : 80.0,
                        bottom: 12.0,
                      ),
                      padding: EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: message.isUser 
                          ? (isDarkMode ? Colors.blue[900] : Colors.blue[100])
                          : (isDarkMode ? Colors.grey[800] : Colors.grey[300]),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  if (message.isUser) ...[
                    SizedBox(width: 8),
                    ProfileImage(
                      imageUrl: _userData?.profileImageUrl,
                      radius: 16,
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        
        // Message input field at bottom
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            boxShadow: [
              BoxShadow(
                offset: Offset(0, -2),
                blurRadius: 2.0,
                color: isDarkMode ? Colors.black54 : Colors.black12,
              ),
            ],
          ),
          child: TextField(
            controller: _messageController,
            onSubmitted: _handleSubmitted,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            decoration: InputDecoration(
              hintText: S.of(context).chatsHintText,
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              filled: true,
              fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.all(16.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (label == S.of(context).quickAppointment) {
            _pageController.animateToPage(
              2, // Paketler sekmesi
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            setState(() => _selectedIndex = 2);
          } else if (label == S.of(context).diabetes) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DiabetesPage()),
            );
          } else {
            onTap();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.43,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageCard(PackageItem package) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(
          package.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(package.description),
            if (package.title != S.of(context).donation)
              Text(
                '${package.price.toStringAsFixed(2)} TL',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          if (package.title == S.of(context).donation) {
            _showDonationDialog();
          } else {
            // Email verification check
            final user = FirebaseAuth.instance.currentUser;
            if (user == null || !user.emailVerified) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.of(context).notVerifiedEmailMessage)),
              );
              return;
            }
            
            // Show appointment selection dialog
            _showPackageDetails(package); // Remove extra parameters
          }
        },
      ),
    );
  }

  void _showDonationDialog() {
    final donationController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).donationAmount),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: donationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: S.of(context).donationAmountLabel,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text(
              S.of(context).donationReward,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () async {
              if (donationController.text.isNotEmpty) {
                final amount = double.tryParse(donationController.text);
                if (amount != null && amount > 0) {
                  // Bağış sonrası bakiye ekleme
                  final prefs = await SharedPreferences.getInstance();
                  final walletStr = prefs.getString('wallet_data');
                  final wallet = walletStr != null 
                      ? WalletModel.fromJson(jsonDecode(walletStr))
                      : WalletModel();
                  
                  // Bağış miktarının %50'si kadar bakiye ekle
                  wallet.pendingBalance += amount * 0.5;
                  wallet.pendingReleaseDate = DateTime.now().add(Duration(days: 7));
                  
                  await prefs.setString('wallet_data', jsonEncode(wallet.toJson()));
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${S.of(context).donationThanks} ₺${(amount * 0.5).toStringAsFixed(2)} ${S.of(context).donationPendingTime}',
                      ),
                      duration: Duration(seconds: 5),
                    ),
                  );
                }
              }
            },
            child: Text(S.of(context).donationConfirm),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesSection() {
    if (_packages == null) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (_packages!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              S.of(context).noPackagesAvailable,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: _packages!.length,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      itemBuilder: (context, index) {
        return _buildPackageCard(_packages![index]);
      },
    );
  }

  Widget _buildSearchResults(List<SearchItem> items) {
    // SearchItems henüz oluşturulmadıysa
    if (_searchItems == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            S.of(context).searchEmpty,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(), // Kaydırma davranışını düzenle
      padding: const EdgeInsets.all(8.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 0, // Gölgeyi kaldır
          margin: EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(item.icon, color: Theme.of(context).primaryColor),
            ),
            title: Text(item.title),
            subtitle: item.description != null ? Text(item.description!) : null,
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              setState(() {
                _showSearchResults = false;
                _searchController.clear();
              });
              item.onTap();
            },
          ),
        );
      },
    );
  }

  final PageController _pageController = PageController(); // Yeni controller ekle

  void disposePageController() {
    _pageController.dispose(); // Controller'ı temizle
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final isDoctor = _userData?.role == UserRole.doctor; // Add this line

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: isDarkMode ? Colors.white : Colors.black,
          displayColor: isDarkMode ? Colors.white : Colors.black,
        ),
        cardColor: isDarkMode ? Colors.grey[800] : Colors.white,
      ),
      child: Scaffold(
        appBar: _buildAppBar(),
        endDrawer: _buildDrawer(),
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _selectedIndex = index),
            children: [
              _buildMainContent(),
              _buildChatSection(),
              isDoctor ? PatientListSection() : _buildPackagesSection(), // Change this line
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.grey),
              label: S.of(context).mainMenuTitle,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat, color: Colors.blue),
              label: S.of(context).chatsTitle,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                isDoctor ? Icons.people : Icons.emoji_emotions,
                color: Colors.green
              ),
              label: isDoctor ? S.of(context).patients : S.of(context).packagesTitle,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: (index) {
            setState(() => _selectedIndex = index);
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ),
    );
  }

  // Add this method at the class level
  void _navigateToAppointments(BuildContext context, {AppointmentModel? highlightedAppointment}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentsPage(
          initialTab: 0,
          highlightedAppointment: highlightedAppointment,
        ),
      ),
    );
  }

  void _showPackagePaymentDialog(
    PackageItem package, 
    DateTime selectedDateTime,
    [HospitalModel? hospital, // Make parameters optional
    DoctorModel? doctor]
  ) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(S.of(context).paymentTitle),
          content: FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              
              final prefs = snapshot.data!;
              final walletStr = prefs.getString('wallet_data');
              final wallet = walletStr != null 
                  ? WalletModel.fromJson(jsonDecode(walletStr))
                  : WalletModel();
              
              final availableBalance = wallet.availableBalance;
              final price = package.price; // Null check ekle
              final canPayWithWallet = availableBalance >= price;
              final remainingAmount = price - availableBalance;

              return SingleChildScrollView( // Scroll özelliği ekle
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Butonları genişlet
                  children: [
                    Text(S.of(context).appointmentPaymentTitle),
                    SizedBox(height: 8),
                    Text('${S.of(context).appointmentPaymentDate} ${selectedDateTime.day}/${selectedDateTime.month}/${selectedDateTime.year}'),
                    Text('${S.of(context).appointmentPaymentTime} ${selectedDateTime.hour}:${selectedDateTime.minute == 0 ? '00' : selectedDateTime.minute}'),
                    Text('${S.of(context).appointmentPaymentPackage} ${package.title}'),
                    Divider(),
                    Text('${S.of(context).appointmentPaymentAmount} ₺${price.toStringAsFixed(2)}'),
                    Text('${S.of(context).appointmentPaymentWallet} ₺${availableBalance.toStringAsFixed(2)}'),
                    SizedBox(height: 16),
                    if (canPayWithWallet)
                      ElevatedButton(
                        onPressed: () async {
                          wallet.availableBalance -= price;
                          await prefs.setString('wallet_data', jsonEncode(wallet.toJson()));
                          
                          final hospitalService = HospitalService(context);
                          // Get hospitals asynchronously
                          final hospitals = await hospitalService.getHospitals();
                          _createAppointment(package, selectedDateTime, hospital ?? hospitals[0], doctor ?? hospitals[0].departments[0].doctors[0]);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.all(16),
                        ),
                        child: Text(S.of(context).paymentWithWallet),
                      )
                    else ...[
                      Text(
                        '${S.of(context).notEnoughWallet} ₺${remainingAmount.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(height: 8),
                      if (availableBalance > 0)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showRegularPaymentDialog(package, selectedDateTime, remainingAmount);
                          },
                          style: ElevatedButton.styleFrom(padding: EdgeInsets.all(16)),
                          child: Text('${S.of(context).walletPlusCardPayment} (₺${remainingAmount.toStringAsFixed(2)})'),
                        ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showRegularPaymentDialog(package, selectedDateTime, price);
                        },
                        style: ElevatedButton.styleFrom(padding: EdgeInsets.all(16)),
                        child: Text(S.of(context).payWithCard),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showRegularPaymentDialog(PackageItem package, DateTime selectedDateTime, double amount, [HospitalModel? hospital, DoctorModel? doctor]) {
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).payWithCardTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${S.of(context).cardPaymentAmount} ₺${amount.toStringAsFixed(2)}'),
              SizedBox(height: 16),
              TextField(
                controller: cardNumberController,
                decoration: InputDecoration(
                  labelText: S.of(context).cardNumber,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: expiryController,
                      decoration: InputDecoration(
                        labelText: S.of(context).cardEndDate,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              // Kart bilgilerini kontrol et (basit validasyon)
              if (cardNumberController.text.length >= 16 &&
                  expiryController.text.length >= 4 &&
                  cvvController.text.length >= 3) {
                final hospitalService = HospitalService(context);
                final hospitals = await hospitalService.getHospitals();
                _createAppointment(package, selectedDateTime, hospital ?? hospitals[0], doctor ?? hospitals[0].departments[0].doctors[0]);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(S.of(context).invalidCardMessage)),
                );
              }
            },
            child: Text(S.of(context).confirmPayment),
          ),
        ],
      ),
    );
  }

  void _createAppointment(PackageItem package, DateTime selectedDateTime, HospitalModel hospital, DoctorModel doctor) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newAppointment = AppointmentModel(
      doctorType: package.title,
      doctorName: '${doctor.title} ${doctor.name}',
      hospital: hospital.name,
      date: '${selectedDateTime.day}/${selectedDateTime.month}/${selectedDateTime.year}',
      time: '${selectedDateTime.hour}:${selectedDateTime.minute == 0 ? '00' : selectedDateTime.minute}',
      userId: user.uid,
      dateTime: selectedDateTime,
    );

    try {
      await _appointmentService?.addAppointment(newAppointment);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).appointmentSuccess)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).appointmentFailure)),
      );
    }
  }

  void _showChildDetailsDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final surnameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).childInformation),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: S.of(context).firstName),
                validator: (value) =>
                    value?.isEmpty ?? true ? S.of(context).requiredField : null,
              ),
              TextFormField(
                controller: surnameController,
                decoration: InputDecoration(labelText: S.of(context).lastName),
                validator: (value) =>
                    value?.isEmpty ?? true ? S.of(context).requiredField : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: S.of(context).emailLabel),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return S.of(context).requiredField;
                  }
                  if (!value!.contains('@')) {
                    return S.of(context).invalidEmailMessage;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text(S.of(context).cancel),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(S.of(context).addKeyword),
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                final familyService = FamilyService();
                final childAccount = await familyService.findChildAccount(emailController.text);
                
                if (childAccount != null) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final success = await familyService.linkChildAccount(
                      user.uid, 
                      childAccount.id!
                    );
                    
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(S.of(context).childAccountConnectionSuccess)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(S.of(context).childAccountConnectionFailure)),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.of(context).childAccountNonExistent)),
                  );
                }
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDoctorAccountCreationDialog() {
    final titleController = TextEditingController();
    final specializationController = TextEditingController();
    final licenseController = TextEditingController();
    HospitalModel? selectedHospital;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).addDoctorAccount),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: S.of(context).doctorTitle,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: specializationController,
                  decoration: InputDecoration(
                    labelText: S.of(context).specialization,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: licenseController,
                  decoration: InputDecoration(
                    labelText: S.of(context).licenseNumber,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                HospitalSelector(
                  showDoctors: false,
                  onSelectionComplete: (hospital, _) {
                    setState(() => selectedHospital = hospital);
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  specializationController.text.isNotEmpty &&
                  licenseController.text.isNotEmpty &&
                  selectedHospital != null &&
                  _userData != null) {
                
                try {
                  final newDoctorAccount = await _authService.createDoctorAccount(
                    _userData!,
                    doctorTitle: titleController.text,
                    specialization: specializationController.text,
                    licenseNumber: licenseController.text,
                    hospitalId: selectedHospital!.id,
                    context: context
                  );

                  if (newDoctorAccount != null) {
                    // Başarılı olduğunda dialog'u kapat
                    Navigator.pop(context);
                    
                    // Kullanıcıya bilgi ver
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(S.of(context).doctorAccountCreated)),
                    );
                    
                    // Başarılı oluşturmadan sonra verileri yenile
                    await _loadInitialData();
                  }
                } catch (e) {
                  // Hata durumunda kullanıcıya bilgi ver
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${S.of(context).doctorAccountCreationError}: ${e.toString()}'),
                      duration: Duration(seconds: 5),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(S.of(context).requiredAll)),
                );
              }
            },
            child: Text(S.of(context).createDoctorAccount),
          ),
        ],
      ),
    );
  }
}
