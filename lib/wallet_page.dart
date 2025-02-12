import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'wallet_model.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  WalletModel? _wallet;
  
  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    final prefs = await SharedPreferences.getInstance();
    final walletStr = prefs.getString('wallet_data');
    if (walletStr != null) {
      setState(() {
        _wallet = WalletModel.fromJson(jsonDecode(walletStr));
      });
    } else {
      setState(() {
        _wallet = WalletModel();
      });
    }
  }

  Future<void> _addBalance(double amount) async {
    setState(() {
      _wallet?.availableBalance += amount;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wallet_data', jsonEncode(_wallet?.toJson()));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('₺${amount.toStringAsFixed(2)} eklendi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Cüzdanım'),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[700]!, Colors.blue[900]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kullanılabilir Bakiye',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '₺${_wallet?.availableBalance.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_wallet?.pendingBalance != null && _wallet!.pendingBalance > 0) ...[
                        SizedBox(height: 16),
                        Text(
                          'Bekleyen Bakiye: ₺${_wallet?.pendingBalance.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Bakiye Yükle',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  _buildAmountButton(100),
                  _buildAmountButton(200),
                  _buildAmountButton(500),
                  _buildAmountButton(1000),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountButton(double amount) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: () => _addBalance(amount),
      child: Text(
        '₺${amount.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}