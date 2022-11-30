import 'package:ondoorstep/auth/login.dart';
import 'package:ondoorstep/auth/otp.dart';
import 'package:ondoorstep/dashboard/dashboard.dart';

import 'package:ondoorstep/home/home.dart';
import 'package:ondoorstep/payment/order.dart';
import 'package:ondoorstep/profile/create_profile.dart';

var appRoutes = {
  '/': (context) => const HomeScreen(),
  '/login': (context) => const LoginScreen(),
  '/otp': (context) => const OtpScreen(
        verificationId: '',
      ),
  '/register': (context) => const CreateProfile(),
  '/dashboard': (context) => const Dashboard(),
  '/orders': (context) => const Orders(),
};
