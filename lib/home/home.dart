import 'package:flutter/material.dart';
import 'package:ondoorstep/auth/login.dart';
import 'package:ondoorstep/dashboard/dashboard.dart';
import 'package:ondoorstep/services/auth.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(builder: ((context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }else if(snapshot.hasError){
        return const Center(
            child: Text('Error'),
          );
      }else if(snapshot.hasData){
        return const Dashboard();
      }else{
        return const LoginScreen();
      }
    }), stream: AuthService().userStream);
  }
}