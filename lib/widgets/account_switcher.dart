import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/family_service.dart';
import '../generated/l10n.dart';


class AccountSwitcher extends StatelessWidget {
  final UserModel currentUser;
  final Function(UserModel) onAccountChanged;

  const AccountSwitcher({
    super.key,
    required this.currentUser,
    required this.onAccountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(Icons.family_restroom),
      title: Text(S.of(context).accountSwitcher),
      children: [
        FutureBuilder<List<UserModel>>(
          future: FamilyService().getLinkedAccounts(currentUser.id!),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ListTile(
                title: Text(S.of(context).basicErrorMessage),
                subtitle: Text(S.of(context).loadErrorAccountSwitcher),
              );
            }

            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final linkedAccounts = snapshot.data!;
            if (linkedAccounts.isEmpty) {
              return ListTile(
                title: Text(S.of(context).noLinkedAccountsMessage),
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
