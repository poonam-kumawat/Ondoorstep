import 'package:flutter/material.dart';
import 'package:ondoorstep/dashboard/book_transport.dart';
import 'package:ondoorstep/datahanlder/appData.dart';
import 'package:ondoorstep/maps/Models/address.dart';
import 'package:provider/provider.dart';

import '../maps/DividerWidget.dart';
import '../maps/Models/placePrediction.dart';
import '../maps/configmaps.dart';
import '../maps/requestAssistance.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickupTextEditingController = TextEditingController();
  TextEditingController dropoffTextEditingController = TextEditingController();
  List<PlacePrediction> placePredictionList = [];
  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).pickupLocation?.placeName ?? "";
    pickupTextEditingController.text = placeAddress;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            height: 215.0,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 235, 236, 238),
                  blurRadius: 6.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                ),
              ],
            ),
            child: Padding(
                padding: const EdgeInsets.only(
                    left: 25.0, top: 20.0, right: 25.0, bottom: 20.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 40.0,
                    ),
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.arrow_back),
                        ),
                        const Center(
                          child: Text(
                            'Set Drop Off',
                            style: TextStyle(
                                fontSize: 18.0, fontFamily: 'Brand-Bold'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/pickicon.png',
                          height: 16.0,
                          width: 16.0,
                        ),
                        const SizedBox(
                          width: 18.0,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 231, 232, 236),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: TextField(
                                controller: pickupTextEditingController,
                                decoration: const InputDecoration(
                                  hintText: 'Pickup Location',
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 11.0, top: 8.0, bottom: 8.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/desticon.png',
                          height: 16.0,
                          width: 16.0,
                        ),
                        const SizedBox(
                          width: 18.0,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 231, 232, 236),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: TextField(
                                onChanged: (val) {
                                  findPlace(val);
                                },
                                controller: dropoffTextEditingController,
                                decoration: const InputDecoration(
                                  hintText: 'Where to?',
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 11.0, top: 8.0, bottom: 8.0),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
          ),
          //tile for predictions
          const SizedBox(
            height: 10.0,
          ),
          (placePredictionList.isNotEmpty)
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(0.0),
                    itemBuilder: (context, index) {
                      return PredictionTile(
                        placePrediction: placePredictionList[index],
                        key: Key(placePredictionList[index].place_id),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const DividerWidget(),
                    itemCount: placePredictionList.length,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autoCompleteUrl =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=123456&components=country:in';
      var res = await RequestAssistant.getRequest(autoCompleteUrl);
      if (res == "failed") {
        return;
      }

      if (res["status"] == "OK") {
        var predictions = res["predictions"];
        var placesList = (predictions as List)
            .map((e) => PlacePrediction.fromJson(e))
            .toList();
        setState(() {
          placePredictionList = placesList;
        });
      }
    }
  }
}

// ignore: must_be_immutable
class PredictionTile extends StatelessWidget {
  final PlacePrediction placePrediction;

  late BuildContext context;

  PredictionTile({required Key key, required this.placePrediction})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TextButton(
      //padding: const EdgeInsets.all(0.0),
      onPressed: () {
        _getPlaceAddressDetails(placePrediction.place_id, context);
      },
      child: Column(
        children: [
          const SizedBox(
            width: 10.0,
          ),
          Row(children: [
            const Icon(Icons.add_location),
            const SizedBox(
              width: 14.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 8.0,
                  ),
                  Text(
                    placePrediction.main_text,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(
                    height: 2.0,
                  ),
                  Text(
                    placePrediction.secondary_text,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(
            width: 10.0,
          ),
        ],
      ),
    );
  }

  void _getPlaceAddressDetails(String placeId, BuildContext context) async { 
    String placeId = placePrediction.place_id;
    String placeDetailsUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey';
    var res = await RequestAssistant.getRequest(placeDetailsUrl);
    // ignore: use_build_context_synchronously
    if (res == "failed") {
      return;
    }
    if (res['status'] == 'OK') {
      Address address = Address(
        latitude: 0.0,
        longitude: 0.0,
        placeFormattedAddress: '',
        placeId: '',
        placeName: '',
      );
      address.placeName = res['result']['name'];
      address.placeId = placeId;
      address.latitude = res['result']['geometry']['location']['lat'];
      address.longitude = res['result']['geometry']['location']['lng'];
      // ignore: use_build_context_synchronously
      Provider.of<AppData>(context, listen: false)
          .updateDropOffAddress(address);
    }
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const BookVehicle()));
  }
}
