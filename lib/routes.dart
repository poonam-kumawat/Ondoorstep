import 'package:ondoorstep/auth/login.dart';
import 'package:ondoorstep/auth/otp.dart';
import 'package:ondoorstep/home/home.dart';

var appRoutes = {
  '/': (context) => const HomeScreen(),
  '/login': (context) => const LoginScreen(),
  '/otp': (context) => const OtpScreen(verificationId: '',),
};