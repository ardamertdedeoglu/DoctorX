import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doctorx/services/family_service.dart';

class AccountTypeDialog extends StatelessWidget {
  final Function(String) onTypeSelected;

  const AccountTypeDialog({Key? key, required this.onTypeSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Hesap Türü Seçin'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.woman),
            title: Text('Anne'),
            onTap: () {
              Navigator.pop(context);
              onTypeSelected('parent');
              _showAddChildDialog(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.man),
            title: Text('Baba'),
            onTap: () {
              Navigator.pop(context);
              onTypeSelected('parent');
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
            child: Text('İptal'),
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
