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
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
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
  String? _imagePath;
  final picker = ImagePicker();
  final _searchController = TextEditingController();
  bool _showSearchResults = false;

  // Tüm aranabilir öğeleri bir kez oluştur
  // Nullable olarak tanımla
  List<SearchItem>? _searchItems;

  final Map<List<String>, String> _aiResponses = {
    ['merhaba', 'selam', 'hello', 'hi', 'mrb', 'slm']: 'Merhaba! Size nasıl yardımcı olabilirim?',
    ['nasilsin', 'nasılsın', 'naber', 'nbr', 'ne haber']: 'İyiyim, teşekkür ederim. Size nasıl yardımcı olabilirim?',
    ['randevu', 'randavu', 'randevu almak', 'randevu al']: 'Randevu almak için lütfen paketler sekmesinden bir hizmet seçiniz.',
    ['doktor', 'doctor', 'dr', 'hekim']: 'Size uygun bir doktor bulmak için lütfen şikayetinizi belirtiniz.',
    ['fiyat', 'fiyatlar', 'ucret', 'ücret', 'price']: 'Fiyatlarımızı paketler sekmesinde görebilirsiniz.',
    ['tesekkur', 'teşekkür', 'tesekkurler', 'teşekkürler', 'thanks', 'ty']: 'Rica ederim! Başka bir konuda yardımcı olabilir miyim?',
  };

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

  final List<ChatMessage> _messages = [];
  
  final TextEditingController _messageController = TextEditingController();


  List<PackageItem>? _packages;
  List<NewsModel>? _news;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Her başlangıçta Firebase'den taze veri al
    _loadProfileImage();
    _loadThemeMode();
    _initializeFirebase();
    _authService.checkEmailVerification().then((isVerified) {
      if (isVerified) {
        _startEmailVerificationCheck();
      }
    });
    _userService.syncUserData();
  }

  void _initializeData(BuildContext context) {
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

    _news = [
      NewsModel(
        title: '${S.of(context).newsTitle} 1',
        description: S.of(context).newsDesc1,
        content: S.of(context).newsContentPlaceholder,
        imageUrl: 'https://picsum.photos/200',
      ),
      NewsModel(
        title: '${S.of(context).newsTitle} 2',
        description: S.of(context).newsDesc2,
        content: S.of(context).newsContentPlaceholder,
        imageUrl: 'https://picsum.photos/201',
      ),
      NewsModel(
        title: '${S.of(context).newsTitle} 3',
        description: S.of(context).newsDesc3,
        content: S.of(context).newsContentPlaceholder,
        imageUrl: 'https://picsum.photos/202',
      ),
      NewsModel(
        title: '${S.of(context).newsTitle} 4',
        description: S.of(context).newsDesc4,
        content: S.of(context).newsContentPlaceholder,
        imageUrl: 'https://picsum.photos/203',
      ),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // BuildContext hazır olduğunda listeleri initialize et
    _initializeData(context);
    // Paketler hazır olduktan sonra arama öğelerini initialize et
    if (_packages != null) {
      _initializeSearchItems();
    }
  }

  // News data

  // Randevular listesi güncellemesi
  late Stream<List<AppointmentModel>> _appointmentsStream;
  late AppointmentService _appointmentService;

  // Yaklaşan randevuları filtrele
  final List<AppointmentModel> _appointments = [];
  List<AppointmentModel> get _upcomingAppointments {
    return _appointments
      .where((apt) => apt.isWithinTwoWeeks())
      .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  final ProfileImageService _profileImageService = ProfileImageService();
  final AuthService _authService = AuthService();

  // UserService ekle
  final UserService _userService = UserService();

  void _startEmailVerificationCheck() {
    _authService.startEmailVerificationCheck((isVerified) {
      if (isVerified) {
        setState(() {}); // UI'ı yenile
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).emailVerificationSuccess)),
        );
      }
    });
  }

  @override
  void dispose() {
    _authService.stopEmailVerificationCheck();
    super.dispose();
  }

  void _initializeFirebase() {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    _appointmentService = AppointmentService(user.uid);
    _appointmentsStream = _appointmentService.getAppointments();
  }
}

  void _initializeSearchItems() {
    if (_packages == null) return;
    
    _searchItems = [
      // Diyabet bölümü
      SearchItem(
        title: 'Diyabet Takibi',
        category: 'Sağlık',
        description: 'Diyabet değerlerinizi takip edin',
        icon: Icons.vaccines,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DiabetesPage()),
        ),
      ),
      // Dokümanlar
      SearchItem(
        title: 'Sağlık Dokümanları',
        category: 'Dokümanlar',
        description: 'Sağlık ile ilgili bilgilendirici dokümanlar',
        icon: Icons.article,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DocumentsPage()),
        ),
      ),
      // Raporlar
      SearchItem(
        title: 'Tıbbi Raporlar',
        category: 'Raporlar',
        description: 'Tüm tıbbi raporlarınız',
        icon: Icons.medical_services,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReportsPage()),
        ),
      ),
      // Paketler için öğeler
      ..._packages!.map((package) => SearchItem(
        title: package.title,
        category: 'Paketler',
        description: package.description,
        icon: Icons.medical_information,
        onTap: () => _showPackageDetails(package),
      )),
      // Randevular için arama öğesi ekle
      SearchItem(
        title: 'Randevularım',
        category: 'Randevular',
        description: 'Tüm geçmiş ve gelecek randevularınızı görüntüleyin',
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
        title: 'Sağlık Asistanı',
        category: 'Sohbet',
        description: 'Yapay zeka asistanımız ile sağlık konularında sohbet edin',
        icon: Icons.chat,
        onTap: () {
          setState(() => _selectedIndex = 1); // Sohbetler sekmesine geç
          _searchController.clear();
          _showSearchResults = false;
        },
      ),
      
      // AI yanıtları için arama öğeleri
      ..._aiResponses.entries.map((entry) => SearchItem(
        title: entry.value,
        category: 'Sık Sorulan Sorular',
        description: 'Örnek: ${entry.key.first}',
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
                '\nFiyat: ${package.price.toStringAsFixed(2)} TL',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 16),
              if (package.title != 'Bağış') ...[
                Divider(),
                // Hospital and doctor selection
                Text(
                  'Hastane ve Doktor Seçimi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                HospitalSelector(
                  onSelectionComplete: (hospital, doctor) {
                    setState(() {
                      selectedHospital = hospital;
                      selectedDoctor = doctor;
                      selectedDateTime = null; // Reset datetime when doctor changes
                    });
                  },
                ),
                if (selectedHospital != null && selectedDoctor != null) ...[
                  SizedBox(height: 16),
                  Divider(),
                  Text(
                    'Randevu Tarihi ve Saati',
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
            child: Text('Kapat'),
          ),
          if (package.title != 'Bağış')
            TextButton(
              onPressed: (selectedDateTime == null || 
                         selectedHospital == null || 
                         selectedDoctor == null) 
                  ? null 
                  : () {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null || !user.emailVerified) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lütfen e-posta adresinizi doğrulayın')),
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
              child: Text('Satın Al (${package.price.toStringAsFixed(2)} TL)'),
            ),
        ],
      ),
    ),
  );
}

  // Data loading methods
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
      SnackBar(content: Text('Kullanıcı verileri yüklenirken bir hata oluştu.')),
    );
  }
}

  Future<void> _loadProfileImage() async {
    try {
      final imageUrl = await _profileImageService.getProfileImageUrl();
      if (imageUrl != null) {
        setState(() {
          _imagePath = imageUrl; // Add _imageUrl as class property
        });
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
              title: Text('Galeriden Seç'),
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
              title: Text('Fotoğraf Çek'),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  _saveImage(pickedFile.path);
                }
              },
            ),
            if (_imagePath != null) // Sadece fotoğraf varsa göster
              ListTile(
                leading: Icon(Icons.delete_forever, color: Colors.red),
                title: Text('Fotoğrafı Kaldır', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  await _deleteProfileImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteProfileImage() async {
    await _profileImageService.deleteProfileImage();
    setState(() {
      _imagePath = null;
    });
  }

  Future<void> _saveImage(String path) async {
    final file = File(path);
    final url = await _profileImageService.uploadProfileImage(file);
    if (url != null) {
      // UserModel'i güncelle
      final updatedUser = UserModel(
        id: _userData?.id,
        firstName: _userData?.firstName,
        lastName: _userData?.lastName,
        email: _userData?.email ?? '',
        accountType: _userData?.accountType,
        linkedAccounts: _userData?.linkedAccounts,
        profileImageUrl: url,
      );

      // Verileri senkronize et
      await _userService.updateUserData(updatedUser);
      
      setState(() {
        _userData = updatedUser;
      });
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
              S.of(context).mainMenuDesc;
        case 1:
          return   // Başlıklar büyük harf
              'Bu bölümde:\n'
              '• Yapay zeka asistanımızla sohbet edebilirsiniz.\n'
              '• Sağlık konularında sorularınızı sorabilirsiniz.\n'
              '• Randevu ve hizmetler hakkında bilgi alabilirsiniz.';
        case 2:
          return   // Başlıklar büyük harf
              'Bu bölümde:\n'
              '• Sağlık hizmet paketlerimizi inceleyebilirsiniz.\n'
              '• Online randevu alabilirsiniz.\n'
              '• Bağış yapabilirsiniz.\n'
              '• Paket satın alabilirsiniz.';
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
            if (_userData?.accountType == 'parent')
              AccountSwitcher(
                currentUser: _userData!,
                onAccountChanged: (selectedAccount) async {
                  // Seçilen hesaba geçiş yap
                  setState(() {
                    _userData = selectedAccount;
                  });
                  // Kullanıcı tercihlerini güncelle
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('user_data', jsonEncode(selectedAccount.toJson()));
                  Navigator.pop(context); // Drawer'ı kapat
                },
              ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.vaccines),
                    title: Text('Diyabet'),
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
                    title: Text('Dokümanlar'),
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
                    title: Text('Raporlar'),
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
                    title: Text('Randevular'),
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
                    title: Text('Cüzdanım'),
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
                    title: Text('Hakkımızda'),
                    onTap: () {
                      Navigator.pop(context);  // Önce Drawer'ı kapat
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              'HAKKIMIZDA',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Yapımcılar:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Hüseyin Karateke\nEsma Koca\nBeyza Ak\nArda Mert Dedeoğlu\nReyyan Eskicioğlu'),
                                SizedBox(height: 16),
                                Text('Yapım Tarihi:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Şubat 2025'),
                                SizedBox(height: 16),
                                Text('Amaç:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Bu uygulama, her türlü sağlık hizmetini kullanıcıların istediği zaman ve istediği yerden ulaşabileceği bir seviyeye getirmek için tasarlanmıştır.'),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Kapat'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  Divider(),
                  SwitchListTile(
                    title: Text(isDarkMode ? 'Koyu Tema' : 'Açık Tema'),
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
                  'Doğrulama e-postası gönderildi. Lütfen e-postanızı kontrol edin.')),
        );
      } else if (user!.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('E-posta zaten doğrulanmış.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.')),
        );
      }
    } catch (e) {
      print("Error sending verification email: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Doğrulama e-postası gönderilirken bir hata oluştu: ${e.toString()}')),
      );
    }
  }

void _showProfileDialog() {
  final newEmailController = TextEditingController(text: _userData?.email);
  final newPasswordController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Profil Bilgileri'),
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
            Text('Ad: ${_userData?.firstName}'),
            Text('Soyad: ${_userData?.lastName}'),
            Text('E-posta: ${_userData?.email}'),
            
            // Hesap türü ve yükseltme butonu
            SizedBox(height: 16),
            Text(
              'Hesap Türü: ${_userData?.accountType == 'parent' ? 'Ebeveyn' : 'Normal Hesap'}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (_userData?.accountType == 'parent')
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddChildDialog(context);
                  },
                  child: Text('Çocuk Hesabı Ekle'),
                ),
              )
            else
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
                              firstName: _userData?.firstName,
                              lastName: _userData?.lastName,
                              email: _userData?.email ?? '',
                              accountType: accountType,
                              linkedAccounts: [],
                            );

                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .set(updatedUserModel.toJson());

                            setState(() {
                              _userData = updatedUserModel;
                            });

                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString(
                              'user_data', 
                              jsonEncode(updatedUserModel.toJson())
                            );
                          }
                        },
                      ),
                    );
                  },
                  child: Text('Ebeveyn Hesabına Yükselt'),
                ),
              ),
            
            // Yeni e-posta ve şifre alanları
            SizedBox(height: 20),
            TextField(
              controller: newEmailController,
              decoration: InputDecoration(
                labelText: 'Yeni E-posta',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Yeni Şifre',
                border: OutlineInputBorder(),
              ),
            ),
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
                  firstName: _userData?.firstName,
                  lastName: _userData?.lastName,
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
                      SnackBar(content: Text('Şifre başarıyla güncellendi')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.')),
                    );
                  }
                } catch (e) {
                  print("Error updating password: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Şifre güncellenirken bir hata oluştu: ${e.toString()}')),
                  );
                }
              }
              _loadUserData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Bilgiler güncellendi')),
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
            child: Text('E-postayı Doğrula'),
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
      title: Text('Çocuk Hesabı'),
      content: Text('Çocuklarınızın hesabını eklemek ister misiniz?'),
      actions: [
        TextButton(
          child: Text('Hayır'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text('Evet'),
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
                      news.description,
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
  return StreamBuilder<List<AppointmentModel>>(
    stream: _appointmentsStream,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(child: Text('Bir hata oluştu'));
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }
      
      final appointments = snapshot.data ?? [];
      final upcomingAppointments = appointments
          .where((apt) => apt.isWithinTwoWeeks())
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
  return Padding(
    padding: const EdgeInsets.all(24),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Yaklaşan randevunuz bulunmamaktadır',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Randevu Al'),
            onPressed: () {
              _pageController.animateToPage(
                2,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
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
        label: S.of(context).quickAppointment,
        onTap: () {}, // Boş bırak, üstteki logic kullanılacak
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
    if (_packages == null) return Container(); // Veriler yüklenene kadar boş container göster
    
    return ListView.builder(
      itemCount: _packages!.length,
      itemBuilder: (context, index) => _buildPackageCard(_packages![index]),
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
            'Aranan içerik bulunamadı',
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
              _buildPackagesSection(),
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
              icon: Icon(Icons.emoji_emotions, color: Colors.green),
              label: S.of(context).packagesTitle,
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
        title: Text('Ödeme Seçenekleri'),
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
            Text('Randevu Detayları:'),
            SizedBox(height: 8),
            Text('Tarih: ${selectedDateTime.day}/${selectedDateTime.month}/${selectedDateTime.year}'),
            Text('Saat: ${selectedDateTime.hour}:${selectedDateTime.minute == 0 ? '00' : selectedDateTime.minute}'),
            Text('Paket: ${package.title}'),
            Divider(),
            Text('Paket Tutarı: ₺${price.toStringAsFixed(2)}'),
            Text('Cüzdan Bakiyeniz: ₺${availableBalance.toStringAsFixed(2)}'),
            SizedBox(height: 16),
            if (canPayWithWallet)
              ElevatedButton(
                onPressed: () async {
                  wallet.availableBalance -= price;
                  await prefs.setString('wallet_data', jsonEncode(wallet.toJson()));
                  
                  _createAppointment(package, selectedDateTime, hospital ?? HospitalService.hospitals[0], doctor ?? HospitalService.hospitals[0].departments[0].doctors[0]);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.all(16),
                ),
                child: Text('Cüzdan Bakiyesi ile Öde'),
              )
            else ...[
              Text(
                'Yetersiz bakiye. Kalan tutar: ₺${remainingAmount.toStringAsFixed(2)}',
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
                  child: Text('Cüzdan + Kart ile Öde (₺${remainingAmount.toStringAsFixed(2)})'),
                ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showRegularPaymentDialog(package, selectedDateTime, price);
                },
                style: ElevatedButton.styleFrom(padding: EdgeInsets.all(16)),
                child: Text('Kredi/Banka Kartı ile Öde'),
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
      title: Text('Kart ile Ödeme'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ödenecek Tutar: ₺${amount.toStringAsFixed(2)}'),
            SizedBox(height: 16),
            TextField(
              controller: cardNumberController,
              decoration: InputDecoration(
                labelText: 'Kart Numarası',
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
                      labelText: 'AA/YY',
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
          _createAppointment(package, selectedDateTime, hospital ?? HospitalService.hospitals[0], doctor ?? HospitalService.hospitals[0].departments[0].doctors[0]);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lütfen geçerli kart bilgileri girin')),
              );
            }
          },
          child: Text('Ödemeyi Tamamla'),
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
    await _appointmentService.addAppointment(newAppointment);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Randevunuz başarıyla oluşturuldu')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Randevu oluşturulurken bir hata oluştu')),
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
        title: Text('Çocuk Bilgileri'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Ad'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Bu alan zorunludur' : null,
              ),
              TextFormField(
                controller: surnameController,
                decoration: InputDecoration(labelText: 'Soyad'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Bu alan zorunludur' : null,
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'E-posta'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Bu alan zorunludur';
                  }
                  if (!value!.contains('@')) {
                    return 'Geçerli bir e-posta adresi girin';
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
            child: Text('Ekle'),
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
                        SnackBar(content: Text('Çocuk hesabı başarıyla bağlandı')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Hesap bağlama başarısız oldu')),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Belirtilen e-posta ile çocuk hesabı bulunamadı')),
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


}

