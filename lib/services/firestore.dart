import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ondoorstep/services/auth.dart';
import 'package:ondoorstep/services/models.dart';

class FirestoreService {
  static FirebaseFirestore firebase = FirebaseFirestore.instance;

  Future<bool> checkUser(String uid) async {
    DocumentSnapshot documentSnapshot =
        await firebase.collection('users').doc(uid).get();
    return documentSnapshot.exists ? true : false;
  }

  Future createUser(Map<String, dynamic> userData) async {
    final user = AuthService().user;
    final uid = user!.uid;
    final phoneNumber = user.phoneNumber;
    userData.addEntries([MapEntry('phoneNumber', phoneNumber)]);
    await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);
  }

  Future<AppUser> getUser(String uid) async {
    var userRef = firebase.collection('users').doc(uid);
    var user = await userRef.get();
    return AppUser.fromJson(user.data() ?? {});
  }

  Future<void> createOrder(Map<String, dynamic> orderData) async {
    var orderRef = firebase.collection('orders').doc();
    var orderId = orderRef.id;
    await orderRef.set(orderData);
    await firebase
        .collection('users')
        .doc(AuthService().user!.uid)
        .collection('orders')
        .doc(orderId)
        .set(orderData);
  }

  Future<void> completeApplication(
      String uid, String name, String Email, String mobile) async {
    await firebase.collection('users').doc(uid).set({
      'name': name,
      'Eamil': Email,
      'mobile': mobile,
    }, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    var ordersRef = firebase.collection('users').doc(AuthService().user!.uid).collection('orders');
    var orderData = await ordersRef.get();
    var orders = orderData.docs.map((e) => e.data()).toList();
    print(orders);
    return orders;
  } 
}
