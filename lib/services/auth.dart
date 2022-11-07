import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final userStream = FirebaseAuth.instance.authStateChanges();
  final user = FirebaseAuth.instance.currentUser;

  Future<void> signInMobile(String mobile, BuildContext context) async {
    print('called here');
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
          Navigator.of(context).pushNamed('/otp', arguments: verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Time out');
        },
      );
    } catch (e) {
      print(e);
    }
  }
}
