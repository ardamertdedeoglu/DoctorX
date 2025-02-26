import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/role_model.dart';
import '../generated/l10n.dart';

class AccountSwitcher extends StatelessWidget {
  final UserModel currentUser;
  final Function(UserModel) onAccountChanged;

  const AccountSwitcher({
    Key? key,
    required this.currentUser,
    required this.onAccountChanged,
  }) : super(key: key);

  Future<List<UserModel>> _getLinkedAccounts() async {
    List<UserModel> accounts = [];
    final firestore = FirebaseFirestore.instance;
    
    // 1. Ana hesabı ekle
    accounts.add(currentUser);

    // 2. LinkedAccounts varsa, bağlı hesapları al
    if (currentUser.linkedAccounts?.isNotEmpty ?? false) {
      for (String accountId in currentUser.linkedAccounts!) {
        final doc = await firestore.collection('users').doc(accountId).get();
        if (doc.exists) {
          final linkedAccount = UserModel.fromJson({...doc.data()!, 'id': doc.id});
          accounts.add(linkedAccount);
        }
      }
    }

    // 3. Eğer bu hesap bir bağlı hesapsa, ana hesabı da al
    if (currentUser.originalAccountId != null) {
      final originalDoc = await firestore
          .collection('users')
          .doc(currentUser.originalAccountId)
          .get();
      
      if (originalDoc.exists) {
        final originalAccount = UserModel.fromJson({...originalDoc.data()!, 'id': originalDoc.id});
        if (!accounts.any((a) => a.id == originalAccount.id)) {
          accounts.add(originalAccount);
        }
      }
    }

    return accounts;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: _getLinkedAccounts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LinearProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox.shrink();
        }

        final accounts = snapshot.data!;
        if (accounts.length <= 1) return SizedBox.shrink();

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                S.of(context).linkedAccounts,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                final isCurrentAccount = account.id == currentUser.id;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: account.role == UserRole.doctor 
                        ? Colors.blue 
                        : Colors.green,
                    child: Icon(
                      account.role == UserRole.doctor 
                          ? Icons.medical_services 
                          : Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    '${account.firstName} ${account.lastName}',
                    style: TextStyle(
                      fontWeight: isCurrentAccount ? FontWeight.bold : null,
                    ),
                  ),
                  subtitle: Text(account.role == UserRole.doctor 
                      ? '${account.doctorTitle ?? ''} (${account.specialization ?? ''})'
                      : account.accountType ?? 'Standard'),
                  trailing: isCurrentAccount 
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () {
                    if (!isCurrentAccount) {
                      onAccountChanged(account);
                    }
                  },
                );
              },
            ),
            Divider(),
          ],
        );
      },
    );
  }
}
