// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:ondoorstep/services/auth.dart';
import 'package:ondoorstep/services/firestore.dart';
import 'package:ondoorstep/services/models.dart';

class FetchProfile extends StatefulWidget {
  const FetchProfile({Key? key}) : super(key: key);

  @override
  _FetchProfileState createState() => _FetchProfileState();
}

class _FetchProfileState extends State<FetchProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      margin: const EdgeInsets.only(left: 25, right: 25),
      alignment: Alignment.center,
      child: FutureBuilder(
          future: FirestoreService().getUser(AuthService().user!.uid),
          builder: ((context, snapshot) {
            if (snapshot.hasData) {
              AppUser user = snapshot.data as AppUser;
              return SafeArea(
                  child: Column(
                children: [
                  //for circle avtar image
                  _getHeader(),
                  const SizedBox(
                    height: 10,
                  ),
                  _profileName(user.name),
                  const SizedBox(
                    height: 5,
                  ),
                  _heading("Personal Details"),
                  const SizedBox(
                    height: 6,
                  ),
                  _detailsCard(user),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ));
            } else {
              return const Text('loading');
            }
          })),
    ));
  }

  Widget _getHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            margin: new EdgeInsets.only(top: 100.0),
            height: 100,
            width: 100,
            decoration: const BoxDecoration(
              //borderRadius: BorderRadius.all(Radius.circular(10.0)),
              shape: BoxShape.circle,
              image: DecorationImage(
                  fit: BoxFit.fill, image: AssetImage("assets/people.png")),
              // color: Colors.orange[100],
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileName(String name) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.80, //80% of width,
      margin: new EdgeInsets.only(bottom: 50),
      child: Center(
        child: Text(
          name,
          style: const TextStyle(color: Colors.black, fontSize: 24),
        ),
      ),
    );
  }

  Widget _heading(String heading) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.80, //80% of width,
      child: Text(
        heading,
        style: const TextStyle(fontSize: 20, fontFamily: 'Brand-bold'),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _detailsCard(AppUser user) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        child: Column(
          children: [
            //row for each deatails
            ListTile(
              leading: const Icon(
                Icons.account_circle,
                color: Color.fromARGB(255, 72, 76, 126),
              ),
              title: Text(user.name),
            ),
            Divider(
              height: 10,
              color: Colors.black87,
            ),
            ListTile(
              leading: const Icon(Icons.email,
                  color: Color.fromARGB(255, 72, 76, 126)),
              title: Text(user.email),
            ),

            Divider(
              height: 10,
              color: Colors.black87,
            ),
            ListTile(
              leading: const Icon(Icons.call,
                  color: Color.fromARGB(255, 72, 76, 126)),
              title: Text(user.phoneNumber),
            ),
          ],
        ),
      ),
    );
  }
}
