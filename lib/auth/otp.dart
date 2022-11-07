import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget{
  const OtpScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>{
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('OTP'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                hintText: 'Enter OTP',
              ),
              validator: (value){
                if(value!.isEmpty){
                  return 'Please enter OTP';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () async{
                if(_formKey.currentState!.validate()){
                  // ignore: avoid_print
                  print(_codeController.text);
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