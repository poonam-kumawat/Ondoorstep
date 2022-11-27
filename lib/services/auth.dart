import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ondoorstep/auth/otp.dart';
import 'package:ondoorstep/services/firestore.dart';

class AuthService {
  final userStream = FirebaseAuth.instance.authStateChanges();
  final user = FirebaseAuth.instance.currentUser;

  Future<void> signInMobile(String mobile, BuildContext context) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91$mobile',
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (e.code == 'invalid-phone-number') {
            print('The provided phone number is not valid.');
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return OtpScreen(verificationId: verificationId);
          }));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Time out');
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> signInOtp(
      String otp, String verificationId, BuildContext context) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      final currentUser = FirebaseAuth.instance.currentUser;

      // ignore: use_build_context_synchronously
      if(await FirestoreService().checkUser(currentUser!.uid)){
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }else{
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushNamedAndRemoveUntil('/profile', (route) => false);
      }
    } catch (e) {
      print(e);
    }
  }
}