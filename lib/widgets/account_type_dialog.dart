import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doctorx/services/family_service.dart';
import 'package:doctorx/generated/l10n.dart';

class AccountTypeDialog extends StatelessWidget {
  final Function(String) onTypeSelected;

  const AccountTypeDialog({super.key, required this.onTypeSelected});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).chooseAccountType),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.woman),
            title: Text(S.of(context).mother),
            onTap: () {
              Navigator.pop(context);
              onTypeSelected(S.of(context).parent);
              _showAddChildDialog(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.man),
            title: Text(S.of(context).father),
            onTap: () {
              Navigator.pop(context);
              onTypeSelected(S.of(context).parent);
              _showAddChildDialog(context);
            },
          ),
        ],
      ),
    );
  }

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
}
