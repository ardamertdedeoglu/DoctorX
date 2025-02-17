import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'generated/l10n.dart';
import 'models/food_item.dart';

class DiabetesPage extends StatefulWidget {
  const DiabetesPage({super.key});

  @override
  _DiabetesPageState createState() => _DiabetesPageState();
}

class _DiabetesPageState extends State<DiabetesPage> with SingleTickerProviderStateMixin {
  double _glucoseLevel = 100.0;
  int _consumedCarbs = 0;
  final int _dailyTargetCarbs = 250;
  bool _morningInsulin = false;
  bool _eveningInsulin = false;

  final morningDoseTime = TimeOfDay(hour: 11, minute: 0);
  final eveningDoseTime = TimeOfDay(hour: 20, minute: 0);
  Timer? _timer;

  // Yeni özellik ekleyelim
  String? _lastResetDate;

  // foodItems'ı nullable yap ve boş başlat
  List<FoodItem>? foodItems;

  double _totalCarbs = 0.0;

  late TabController _tabController;

  final int _caloriesPerCarb = 4; // 1g karbonhidrat = 4 kalori

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDiabetesData();
    _checkAndResetDailyDoses(); // initState'e ekleyelim
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
        _checkAndResetDailyDoses(); // Timer'da da kontrol edelim
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // foodItems'ı burada lokalize et
    foodItems = [
      FoodItem(
        name: '${S.of(context).apple} (${S.of(context).oneUnit})', 
        carbAmount: 15.0
      ),
      FoodItem(
        name: '${S.of(context).bread} (${S.of(context).oneSlice})', 
        carbAmount: 12.0
      ),
      FoodItem(
        name: '${S.of(context).rice} (${S.of(context).onePortion})', 
        carbAmount: 45.0
      ),
      FoodItem(
        name: '${S.of(context).pasta} (${S.of(context).onePortion})', 
        carbAmount: 42.0
      ),
      FoodItem(
        name: '${S.of(context).banana} (${S.of(context).oneUnit})', 
        carbAmount: 23.0
      ),
      FoodItem(
        name: '${S.of(context).milk} (${S.of(context).oneGlass})', 
        carbAmount: 12.0
      ),
      FoodItem(
        name: '${S.of(context).yogurt} (${S.of(context).oneBowl})', 
        carbAmount: 10.0
      ),
      FoodItem(
        name: '${S.of(context).potato} (${S.of(context).mediumSize})', 
        carbAmount: 30.0
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // Yeni metod ekleyelim
  Future<void> _checkAndResetDailyDoses() async {
    final today = DateTime.now().toString().split(' ')[0]; // Sadece tarih kısmını al (YYYY-MM-DD)
    
    if (_lastResetDate != today) {
      // Yeni gün başlamış, dozları sıfırla
      setState(() {
        _morningInsulin = false;
        _eveningInsulin = false;
        _lastResetDate = today;
      });
      
      // Değişiklikleri kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('morning_insulin', false);
      await prefs.setBool('evening_insulin', false);
      await prefs.setString('last_reset_date', today);
    }
  }

  Future<void> _loadDiabetesData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _glucoseLevel = prefs.getDouble('glucose_level') ?? 100.0;
      _consumedCarbs = prefs.getInt('consumed_carbs') ?? 0;
      _morningInsulin = prefs.getBool('morning_insulin') ?? false;
      _eveningInsulin = prefs.getBool('evening_insulin') ?? false;
      _lastResetDate = prefs.getString('last_reset_date'); // Son sıfırlama tarihini yükle
    });
  }

  Future<void> _saveDiabetesData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('glucose_level', _glucoseLevel);
    await prefs.setInt('consumed_carbs', _consumedCarbs);
    await prefs.setBool('morning_insulin', _morningInsulin);
    await prefs.setBool('evening_insulin', _eveningInsulin);
    await prefs.setString('last_reset_date', _lastResetDate ?? ''); // Son sıfırlama tarihini kaydet
  }

  String _getRemainingTime(TimeOfDay doseTime) {
    final now = TimeOfDay.now();
    final currentTime = now.hour * 60 + now.minute;
    final targetTime = doseTime.hour * 60 + doseTime.minute;
    
    var diff = targetTime - currentTime;
    if (diff < 0) diff += 24 * 60; // Sonraki güne geç
    
    final hours = diff ~/ 60;
    final minutes = diff % 60;
    return '$hours${S.of(context).hour} $minutes${S.of(context).minutes}';
  }

  bool _isDoseTimeValid(TimeOfDay doseTime) {
    final now = TimeOfDay.now();
    final currentTime = now.hour * 60 + now.minute;
    final targetTime = doseTime.hour * 60 + doseTime.minute;
    return currentTime <= targetTime;
  }

  Widget _buildDoseStatus(bool isChecked, bool isTimeValid) {
    if (!isTimeValid || isChecked) { // isChecked durumunu da kontrol et
      return Text(
        isChecked ? S.of(context).doseConfirmedMessage : S.of(context).doseNotConfirmedMessage,
        style: TextStyle(
          color: isChecked ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }
    return SizedBox.shrink();
  }

  Future<bool> _showConfirmationDialog(String doseType) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).doseConfirm),
        content: Text('${S.of(context).doseConfirmationDesc} $doseType'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(S.of(context).noButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
            ),
            child: Text(S.of(context).yesButton),
          ),
        ],
      ),
    ) ?? false; // Dialog kapatılırsa false dön
  }

  Widget _buildInsulinCard() {
    final isMorningValid = _isDoseTimeValid(morningDoseTime);
    final isEveningValid = _isDoseTimeValid(eveningDoseTime);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).doseTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            CheckboxListTile(
              title: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(S.of(context).morningDose),
                  ),
                  if (isMorningValid && !_morningInsulin)
                    SizedBox(
                      width: 100, // Sabit genişlik
                      child: Text(
                        '${S.of(context).remainingTime} ${_getRemainingTime(morningDoseTime)}',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              value: _morningInsulin,
              enabled: isMorningValid && !_morningInsulin,
              onChanged: isMorningValid ? (value) async {
                if (value == true) {
                  final confirmed = await _showConfirmationDialog(S.of(context).morning);
                  if (confirmed) {
                    setState(() {
                      _morningInsulin = true;
                    });
                    _saveDiabetesData();
                  }
                }
              } : null,
            ),
            if (!isMorningValid || _morningInsulin) // İşaretlendiyse mesajı göster
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: _buildDoseStatus(_morningInsulin, false),
              ),
            CheckboxListTile(
              title: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(S.of(context).eveningDose),
                  ),
                  if (isEveningValid && !_eveningInsulin)
                    SizedBox(
                      width: 100, // Sabit genişlik
                      child: Text(
                        '${S.of(context).remainingTime} ${_getRemainingTime(eveningDoseTime)}',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              value: _eveningInsulin,
              enabled: isEveningValid && !_eveningInsulin, // İşaretlendiyse devre dışı bırak
              onChanged: isEveningValid ? (value) async {
                if (value == true) {
                  final confirmed = await _showConfirmationDialog(S.of(context).evening);
                  if (confirmed) {
                    setState(() {
                      _eveningInsulin = true;
                    });
                    _saveDiabetesData();
                  }
                }
              } : null,
            ),
            if (!isEveningValid || _eveningInsulin) // İşaretlendiyse mesajı göster
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: _buildDoseStatus(_eveningInsulin, false),
              ),
          ],
        ),
      ),
    );
  }

  // Karbonhidrat sekmesi için widget
  Widget _buildCarbsTab() {
    if (foodItems == null) return Container();
    
    // Toplam kalori hesaplama
    final totalCalories = _totalCarbs * _caloriesPerCarb;
    final targetCalories = _dailyTargetCarbs * _caloriesPerCarb;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).carbohydratesTracking,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          S.of(context).consumptionToday,
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          '${_totalCarbs.toStringAsFixed(1)}g',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          S.of(context).calories,
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '${totalCalories.toStringAsFixed(1)} / $targetCalories kcal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: totalCalories > targetCalories ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: totalCalories / targetCalories,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        totalCalories > targetCalories ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              S.of(context).eatQuestion,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Yiyecek listesi
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: foodItems!.length,
              itemBuilder: (context, index) {
                final food = foodItems![index];
                return Card(
                  child: ListTile(
                    title: Text(food.name),
                    subtitle: Text('${food.carbAmount}g ${S.of(context).carbohydrates}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (food.consumedCount > 0)
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${food.consumedCount}x',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () {
                            setState(() {
                              food.consumedCount++;
                              _totalCarbs += food.carbAmount;
                            });
                          },
                        ),
                        if (food.consumedCount > 0)
                          IconButton(
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                if (food.consumedCount > 0) {
                                  food.consumedCount--;
                                  _totalCarbs -= food.carbAmount;
                                }
                              });
                            },
                          ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        food.consumedCount++;
                        _totalCarbs += food.carbAmount;
                      });
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).diabetes),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: S.of(context).insulineTracking),
            Tab(text: S.of(context).carbohydratesTracking),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // İnsülin takibi tab'ı
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Glikoz Ölçer Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).glucoseLevel,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _glucoseLevel,
                                min: 0,
                                max: 200,
                                onChanged: (value) {
                                  setState(() {
                                    _glucoseLevel = value;
                                  });
                                  _saveDiabetesData();
                                },
                              ),
                            ),
                            Text(
                              '${_glucoseLevel.toStringAsFixed(1)} mg/dL',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _glucoseLevel > 140 ? Colors.red : 
                                       _glucoseLevel < 70 ? Colors.orange : 
                                       Colors.green,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          _glucoseLevel > 140 ? S.of(context).tooMuchGlucose :
                          _glucoseLevel < 70 ? S.of(context).tooLowGlucose :
                          S.of(context).normalGlucose,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _glucoseLevel > 140 ? Colors.red :
                                   _glucoseLevel < 70 ? Colors.orange :
                                   Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // İnsülin Takibi Card
                _buildInsulinCard(),
              ],
            ),
          ),
          // Karbonhidrat takibi tab'ı
          _buildCarbsTab(),
        ],
      ),
    );
  }
}
