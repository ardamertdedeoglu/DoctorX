import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/user_model.dart';
import '../models/role_model.dart';
import '../generated/l10n.dart';
import '../services/auth_service.dart';
import '../services/hospital_service.dart';

class AccountSwitcher extends StatefulWidget {
  final UserModel currentUser;
  final Function(UserModel) onAccountChanged;
  
  const AccountSwitcher({
    Key? key,
    required this.currentUser,
    required this.onAccountChanged,
  }) : super(key: key);

  @override
  _AccountSwitcherState createState() => _AccountSwitcherState();
}

class _AccountSwitcherState extends State<AccountSwitcher> {
  late List<UserModel> _linkedAccounts = [];
  bool _isLoading = true;
  bool _hasError = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadLinkedAccounts();
  }

  Future<void> _loadLinkedAccounts() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      // Önce ana hesabı bul
      final mainAccountId = widget.currentUser.originalAccountId ?? widget.currentUser.id!;
      
      // Ana hesabın dokümanını al
      final mainDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(mainAccountId)
          .get();

      if (!mounted) return;

      if (mainDoc.exists) {
        List<String> linkedAccountIds = [mainAccountId]; // Ana hesabı direkt ekle
        
        // Bağlı hesapların ID'lerini ekle
        if (mainDoc.data()!.containsKey('linkedAccounts')) {
          linkedAccountIds.addAll(List<String>.from(mainDoc.data()!['linkedAccounts'] ?? []));
        }
        
        // Tekrarlanan ID'leri temizle
        linkedAccountIds = linkedAccountIds.toSet().toList();
        
        // Tüm hesapların bilgilerini getir
        final accounts = await Future.wait(
          linkedAccountIds.map((id) async {
            final doc = await FirebaseFirestore.instance
                .collection('users')
                .doc(id)
                .get();
            
            if (doc.exists) {
              final data = doc.data()!;
              data['id'] = doc.id;
              return UserModel.fromJson(data);
            }
            return null;
          }),
        );

        if (!mounted) return;
        
        setState(() {
          _linkedAccounts = accounts.whereType<UserModel>().toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _linkedAccounts = [widget.currentUser];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading linked accounts: $e');
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
        _linkedAccounts = [widget.currentUser]; // En azından mevcut hesabı göster
      });
    }
  }

  Future<void> _removeLinkedAccount(UserModel accountToRemove) async {
    if (accountToRemove.id == widget.currentUser.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).cannotRemoveCurrentAccount))
      );
      return;
    }

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).removeAccount),
        content: Text(S.of(context).removeAccountConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              S.of(context).removeAccount,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Get the main account (which contains linkedAccounts list)
        String mainAccountId = widget.currentUser.originalAccountId ?? widget.currentUser.id!;
        
        // Update the linkedAccounts field in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(mainAccountId)
            .update({
              'linkedAccounts': FieldValue.arrayRemove([accountToRemove.id])
            });
        
        // Refresh the linked accounts list
        _loadLinkedAccounts();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).accountRemoved))
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).accountRemoveError}: $e'))
        );
      }
    }
  }

  Future<void> _switchAccount(UserModel account) async {
    try {
      // Save the selected account to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(account.toJson()));
      
      // Notify parent about account change
      widget.onAccountChanged(account);
      
      // Close drawer
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${S.of(context).errorSwitchingAccount}: $e'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _isLoading 
        ? Container(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          )
        : _hasError
        ? Center(
            child: TextButton.icon(
              icon: Icon(Icons.refresh),
              label: Text(S.of(context).tryAgain),
              onPressed: _loadLinkedAccounts,
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  S.of(context).accountSwitcher,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Divider(),
              ..._linkedAccounts.map((account) => _buildAccountTile(account)),
            ],
          ),
    );
  }

  Widget _buildAccountTile(UserModel account) {
    final bool isCurrentAccount = account.id == widget.currentUser.id;
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getAvatarColor(account.role),
        child: Icon(
          _getAvatarIcon(account.role),
          color: Colors.white,
        ),
      ),
      title: Text(
        '${account.firstName} ${account.lastName}',
        style: TextStyle(
          fontWeight: isCurrentAccount ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(_getAccountSubtitle(account)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCurrentAccount)
            Icon(Icons.check_circle, color: Colors.green, size: 20)
          else
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _removeLinkedAccount(account),
            ),
        ],
      ),
      tileColor: isCurrentAccount ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      onTap: isCurrentAccount ? null : () => _switchAccount(account),
    );
  }

  Color _getAvatarColor(UserRole role) {
    switch (role) {
      case UserRole.doctor:
        return Colors.blue;
      case UserRole.patient:
        return Colors.teal;
    }
  }

  IconData _getAvatarIcon(UserRole role) {
    switch (role) {
      case UserRole.doctor:
        return Icons.medical_services;
      case UserRole.patient:
        return Icons.person;
      }
  }

  String _getAccountSubtitle(UserModel account) {
    if (account.role == UserRole.doctor) {
      return '${account.doctorTitle ?? ""} - ${account.specialization ?? ""}';
    }
    return account.accountType ?? S.of(context).normalAccount;
  }
}
