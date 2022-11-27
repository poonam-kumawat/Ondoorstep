import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ondoorstep/services/auth.dart';
class FirestoreService{
  static FirebaseFirestore firebase = FirebaseFirestore.instance;

  Future<bool> checkUser(String uid) async {
    DocumentSnapshot documentSnapshot = await firebase.collection('users').doc(uid).get();
    return documentSnapshot.exists ? true : false;
  }
  
  Future createUser(Map<String, dynamic> userData) async {
    final user = AuthService().user;
    final uid = user!.uid;
    final phoneNumber = user.phoneNumber;
    userData.addEntries([MapEntry('phoneNumber', phoneNumber)]);
    await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);
    
  }
}