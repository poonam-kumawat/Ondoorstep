import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ondoorstep/maps/configmaps.dart';
import 'package:ondoorstep/maps/requestAssistance.dart';
import 'package:ondoorstep/services/firestore.dart';

class Orders extends StatefulWidget {
  const Orders({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _OrdersState createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong'),
          );
        } else if (snapshot.hasData) {
          return Scaffold(
            body: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Card(
                    child: ListTile(
                        title: Text(snapshot.data![index]['status']),
                        subtitle: FutureBuilder(
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(snapshot.data.toString());
                            } else {
                              return const Text('loading');
                            }
                          },
                          future: _getAddress(snapshot.data![index]['dropoff']),
                        )));
              },
            ),
          );
        } else {
          return const Center(
            child: Text('No data'),
          );
        }
      }),
      future: FirestoreService().getOrders(),
    );
  }

  Future<String> _getAddress(GeoPoint location) async {
    String placeAddress = "";
    String st1, st2, st3, st4;
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$mapKey";
    var response = await RequestAssistant.getRequest(url);
    if (response != "failed") {
      //placeAddress = response["results"][0]["formatted_address"];
      st1 = response["results"][0]["address_components"][2]["long_name"];
      st2 = response["results"][0]["address_components"][3]["long_name"];
      st3 = response["results"][0]["address_components"][4]["long_name"];
      st4 = response["results"][0]["address_components"][5]["long_name"];
      placeAddress = "$st1 , $st2 , $st3 , $st4";
      return placeAddress;
    } else {
      return 'failed';
    }
  }
}
