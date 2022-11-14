import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:ondoorstep/views/splash_screen.dart';
import 'firebase_options.dart';
import 'package:ondoorstep/routes.dart';

import 'package:ondoorstep/Login/login.dart';
import 'package:ondoorstep/Login/otp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'phone',
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: const OnboardingScreen(),
      routes: {
        'phone': (context) => MyPhone(),
        'verify': (context) => MyVerify()
      },
      //routes: appRoutes,
    );
  }
}
