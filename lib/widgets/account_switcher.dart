import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/family_service.dart';

class AccountSwitcher extends StatelessWidget {
  final UserModel currentUser;
  final Function(UserModel) onAccountChanged;

  const AccountSwitcher({
    Key? key,
    required this.currentUser,
    required this.onAccountChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(Icons.family_restroom),
      title: Text('Hesap Değiştir'),
      children: [
        FutureBuilder<List<UserModel>>(
          future: FamilyService().getLinkedAccounts(currentUser.id!),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ListTile(
                title: Text('Bir hata oluştu'),
                subtitle: Text('Bağlı hesaplar yüklenemedi'),
              );
            }

            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final linkedAccounts = snapshot.data!;
            if (linkedAccounts.isEmpty) {
              return ListTile(
                title: Text('Bağlı hesap bulunamadı'),
              );
            }

            return Column(
              children: linkedAccounts.map((account) {
                final isActive = account.id == currentUser.id;
                return ListTile(
                  leading: Icon(
                    Icons.person,
                    color: isActive ? Colors.blue : null,
                  ),
                  title: Text(
                    '${account.firstName} ${account.lastName}',
                    style: TextStyle(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? Colors.blue : null,
                    ),
                  ),
                  subtitle: Text(account.email),
                  onTap: () => onAccountChanged(account),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
