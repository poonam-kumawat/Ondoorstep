import 'package:flutter/material.dart';
import 'package:ondoorstep/services/auth.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                hintText: 'Enter Phone Number',
              ),
              validator: (value){
                if(value!.isEmpty){
                  return 'Please enter phone number';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () async{
                if(_formKey.currentState!.validate()){
                  // ignore: avoid_print
                  AuthService().signInMobile(_phoneController.text, context);
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
