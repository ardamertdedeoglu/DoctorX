import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FamilyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if email exists and is a child account
  Future<UserModel?> findChildAccount(String email) async {
    try {
      final QuerySnapshot result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('accountType', isEqualTo: 'child')
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        return UserModel.fromJson(
            result.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error finding child account: $e');
      return null;
    }
  }

  // Link child account to parent
  Future<bool> linkChildAccount(String parentId, String childId) async {
    try {
      await _firestore.collection('users').doc(parentId).update({
        'linkedAccounts': FieldValue.arrayUnion([childId])
      });
      
      await _firestore.collection('users').doc(childId).update({
        'parentId': parentId
      });
      
      return true;
    } catch (e) {
      print('Error linking accounts: $e');
      return false;
    }
  }

  // Get all linked child accounts
  Future<List<UserModel>> getLinkedAccounts(String parentId) async {
    try {
      final parent = await _firestore.collection('users').doc(parentId).get();
      final linkedAccounts = parent.data()?['linkedAccounts'] as List?;
      
      if (linkedAccounts == null || linkedAccounts.isEmpty) {
        return [];
      }

      final childAccounts = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: linkedAccounts)
          .get();

      return childAccounts.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting linked accounts: $e');
      return [];
    }
  }
}
