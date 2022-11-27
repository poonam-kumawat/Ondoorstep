import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ondoorstep/Datahandler/appData.dart';
import 'package:ondoorstep/routes.dart';
import 'package:ondoorstep/dashboard/dashboard.dart';
import 'package:ondoorstep/Login/login.dart';
import 'package:ondoorstep/Login/otp.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        initialRoute: 'dashboard',
        debugShowCheckedModeBanner: false,
        routes: {
          'dashboard': (context) => Dashboard(),
        },
      ),
    );
  }
}
