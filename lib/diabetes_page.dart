import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class DiabetesPage extends StatefulWidget {
  const DiabetesPage({super.key});

  @override
  _DiabetesPageState createState() => _DiabetesPageState();
}

class _DiabetesPageState extends State<DiabetesPage> {
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

  @override
  void initState() {
    super.initState();
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
  void dispose() {
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
    return '${hours}s ${minutes}dk';
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
        isChecked ? 'Aferin, sağlıklı olmaya bir adım daha!' : 'Eyvah, sakın bir daha unutma!',
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
        title: Text('Doz Onayı'),
        content: Text('$doseType dozunu aldığınızdan emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Hayır'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
            ),
            child: Text('Evet'),
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
              'İnsülin Doz',
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
                    child: Text('Sabah Dozu (11:00)'),
                  ),
                  if (isMorningValid && !_morningInsulin)
                    SizedBox(
                      width: 100, // Sabit genişlik
                      child: Text(
                        '${_getRemainingTime(morningDoseTime)} kaldı',
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
                  final confirmed = await _showConfirmationDialog('Sabah');
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
                    child: Text('Akşam Dozu (20:00)'),
                  ),
                  if (isEveningValid && !_eveningInsulin)
                    SizedBox(
                      width: 100, // Sabit genişlik
                      child: Text(
                        '${_getRemainingTime(eveningDoseTime)} kaldı',
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
                  final confirmed = await _showConfirmationDialog('Akşam');
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    return Scaffold(
      appBar: AppBar(
        title: Text('Diyabet'),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Glikoz Ölçer
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Glikoz Seviyesi',
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
                      _glucoseLevel > 140 ? 'Glikoz seviyesi azaltılmalı!' :
                      _glucoseLevel < 70 ? 'Glikoz tüketimini arttır!' :
                      'İşte böyle devam et!',
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

            // Karbonhidrat Takibi
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Karbonhidratlar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _consumedCarbs / _dailyTargetCarbs,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _consumedCarbs > _dailyTargetCarbs ? Colors.red : Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$_consumedCarbs / $_dailyTargetCarbs g'),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if (_consumedCarbs > 0) _consumedCarbs -= 10;
                                });
                                _saveDiabetesData();
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  _consumedCarbs += 10;
                                });
                                _saveDiabetesData();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // İnsülin Takibi
            _buildInsulinCard(),
          ],
        ),
      ),
    );
  }
}
