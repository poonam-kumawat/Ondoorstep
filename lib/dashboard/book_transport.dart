import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ondoorstep/datahanlder/appData.dart';
import 'package:ondoorstep/maps/Models/address.dart';
import 'package:ondoorstep/maps/Models/directionsDetails.dart';
import 'package:ondoorstep/maps/assistantMethods.dart';
import 'package:ondoorstep/maps/configmaps.dart';
import 'package:ondoorstep/maps/requestAssistance.dart';
import 'package:ondoorstep/services/auth.dart';
import 'package:ondoorstep/services/firestore.dart';
import 'package:provider/provider.dart';

class BookVehicle extends StatefulWidget {
  const BookVehicle({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BookVehicleState createState() => _BookVehicleState();
}

class _BookVehicleState extends State<BookVehicle>
    with TickerProviderStateMixin {
  double rideDetailContainer = 300;
  double bottomPaddingOfMap = 0;
  double requestRideContainer = 0;
  late String _mapStyle;
  late GoogleMapController newGoogleMapController;
  final Completer<GoogleMapController> _controllerGooglemap = Completer();
  bool isLookup = false;
  List<LatLng> pLineCoordinates = [];

  Future<void> _getLiveLocation() async {
    currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng latLngPosition =
        LatLng(currentPosition.latitude, currentPosition.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);
    GoogleMapController googleMapController = await _controllerGooglemap.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String placeAddress = "";
    String st1, st2, st3, st4;
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${currentPosition.latitude},${currentPosition.longitude}&key=$mapKey";
    var response = await RequestAssistant.getRequest(url);
    if (response != "failed") {
      //placeAddress = response["results"][0]["formatted_address"];
      st1 = response["results"][0]["address_components"][2]["long_name"];
      st2 = response["results"][0]["address_components"][3]["long_name"];
      st3 = response["results"][0]["address_components"][4]["long_name"];
      st4 = response["results"][0]["address_components"][5]["long_name"];
      placeAddress = "$st1 , $st2 , $st3 , $st4";
      Address userPickupAddress = Address(
          placeFormattedAddress: ' ',
          placeId: '  ',
          placeName: ' ',
          latitude: 0.0,
          longitude: 0.0);
      userPickupAddress.longitude = currentPosition.longitude;
      userPickupAddress.latitude = currentPosition.latitude;
      userPickupAddress.placeName = placeAddress;
      // ignore: use_build_context_synchronously
      Provider.of<AppData>(context, listen: false)
          .updatePickupAddress(userPickupAddress);
    }
  }

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/google.txt').then((string) {
      _mapStyle = string;
    });
    _getLiveLocation();
    _getTripDirection();
  }

  @override
  void dispose() {
    super.dispose();
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Position currentPosition = const Position(
      longitude: 0,
      latitude: 0,
      timestamp: null,
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);
  DirectionsDetails tripDirectionDetails = DirectionsDetails(
      distanceText: '',
      distanceValue: 0,
      durationValue: 0,
      durationText: '',
      encodedPoints: '');
  Set<Polyline> polylineSet = {};
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            initialCameraPosition: _kGooglePlex,
            polylines: polylineSet,
            mapType: MapType.terrain,
            markers: markersSet,
            circles: circlesSet,
            zoomControlsEnabled: false,
            zoomGesturesEnabled: false,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controllerGooglemap.complete(controller);
              newGoogleMapController = controller;
              newGoogleMapController.setMapStyle(_mapStyle);
              setState(() {
                bottomPaddingOfMap = 350.0;
              });
            },
          ),
          Positioned(
              top: 50,
              left: 20,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                    onPressed: () {
                      _resetApp();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close)),
              )),
          Positioned(
            bottom: 320,
            right: 20,
            child: GestureDetector(
              child: const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue,
                child: Icon(Icons.my_location, color: Colors.white),
              ),
              onTap: () {
                _locatePosition();
              },
            ),
          ),
          isLookup
              ? Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: AnimatedSize(
                    vsync: this,
                    curve: Curves.bounceIn,
                    duration: const Duration(milliseconds: 160),
                    child: Container(
                      height: rideDetailContainer,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 236, 237, 240),
                            blurRadius: 16.0,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 17.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Getting Driver for your Pickup",
                                style: TextStyle(fontSize: 30),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  const SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 20,
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          isLookup = false;
                                          polylineSet.clear();
                                          pLineCoordinates.clear();
                                        });
                                      },
                                      icon: const Icon(Icons.close))
                                ],
                              ),
                            ]),
                      ),
                    ),
                  ))
              : Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: AnimatedSize(
                    vsync: this,
                    curve: Curves.bounceIn,
                    duration: const Duration(milliseconds: 160),
                    child: Container(
                      height: rideDetailContainer,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0)),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromARGB(255, 236, 237, 240),
                            blurRadius: 16.0,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 17.0),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              //color: Color.fromARGB(255, 240, 243, 242),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      "assets/truck.png",
                                      height: 70.0,
                                      width: 80.0,
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Truck",
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontFamily: "Brand-Bold"),
                                        ),
                                        _heightSizedBox(4.0),
                                        Text(
                                          // ignore: unnecessary_null_comparison
                                          " ${(tripDirectionDetails != null) ? tripDirectionDetails.distanceText
                                              // ignore: unnecessary_null_comparison
                                              : ""} - ${(tripDirectionDetails != null) ? tripDirectionDetails.durationText : ""}",
                                          style: const TextStyle(
                                              fontSize: 12.0,
                                              color: Color.fromARGB(
                                                  255, 74, 111, 158)),
                                        ),
                                      ],
                                    ),
                                    _widthSizedBox(30),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          // ignore: unnecessary_null_comparison
                                          ((tripDirectionDetails.durationText !=
                                                  null)
                                              ? '\u{20B9}${AssistantMethods.calculateFares(tripDirectionDetails)}'
                                              : ''),
                                          style: const TextStyle(
                                              fontFamily: 'Brand-Bold',
                                              fontSize: 24.0,
                                              color: Color.fromARGB(
                                                  255, 74, 111, 158)),
                                        ),
                                        _heightSizedBox(4.0),
                                        const Text(
                                          // ignore: unnecessary_null_comparison
                                          "\u{20B9}15.0/KM",
                                          style: TextStyle(
                                              fontSize: 14.0,
                                              color: Color.fromARGB(
                                                  255, 74, 111, 158)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                children: const [
                                  Icon(
                                    FontAwesomeIcons.moneyCheck,
                                    size: 18.0,
                                    color: Colors.black54,
                                  ),
                                  SizedBox(
                                    width: 16.0,
                                  ),
                                  Text("Cash"),
                                  SizedBox(
                                    width: 6.0,
                                  ),
                                  Icon(Icons.keyboard_arrow_down,
                                      color: Colors.black54, size: 16.0),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 24.0,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 58, 81, 122),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(17.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        "Request",
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            fontFamily: "Brand-Bold",
                                            color: Colors.white),
                                      ),
                                      Icon(
                                        FontAwesomeIcons.truck,
                                        color: Colors.white,
                                        size: 26.0,
                                      ),
                                    ],
                                  ),
                                ),
                                onPressed: () {
                                  _showPolylines();
                                  _pushToDB();

                                  setState(() {
                                    isLookup = true;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _heightSizedBox(double height) {
    return SizedBox(
      height: height,
    );
  }

  Widget _widthSizedBox(double width) {
    return SizedBox(
      width: width,
    );
  }

  void _locatePosition() {
    LatLng latLngPosition =
        LatLng(currentPosition.latitude, currentPosition.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);
    _controllerGooglemap.future.then((value) {
      value.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    });
  }

  void _getTripDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickupLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropoffLocation;
    var pickUpLatLng = LatLng(initialPos!.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos!.latitude, finalPos.longitude);
    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);
    Marker pickupLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow:
          InfoWindow(title: initialPos.placeName, snippet: "My Location"),
      position: pickUpLatLng,
      markerId: const MarkerId("pickUpId"),
    );

    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: finalPos.placeName, snippet: "DropOff Location"),
      position: dropOffLatLng,
      markerId: const MarkerId("dropOffId"),
    );
    Circle pickUpLocCircle = Circle(
        fillColor: Colors.blueAccent,
        center: pickUpLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.blueAccent,
        circleId: const CircleId("pickUpId"));

    Circle dropOffLocCircle = Circle(
        fillColor: Colors.deepPurple,
        center: dropOffLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.deepPurple,
        circleId: const CircleId("dropOffId"));
    setState(() {
      tripDirectionDetails = details!;
      markersSet.add(pickupLocMarker);
      markersSet.add(dropOffLocMarker);
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
    });
  }

  void _resetApp() {
    setState(() {
      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
    });
  }

  void _showPolylines() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickupLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropoffLocation;
    var pickUpLatLng = LatLng(initialPos!.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos!.latitude, finalPos.longitude);
    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
        polylinePoints.decodePolyline(details!.encodedPoints);
    pLineCoordinates.clear();
    if (decodedPolyLinePointsResult.isNotEmpty) {
      for (var pointLatLng in decodedPolyLinePointsResult) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }
    setState(() {
      Polyline polyline = Polyline(
          color: const Color.fromARGB(255, 58, 81, 122),
          polylineId: const PolylineId("PolylineID"),
          jointType: JointType.round,
          points: pLineCoordinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap);
      polylineSet.add(polyline);
    });
    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }
    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));
  }

  void _pushToDB() {
    Map<String, dynamic> orderData = {
      'otp': Random().nextInt(999999).toString().padLeft(6, '0'),
      'userId': AuthService().user!.uid,
    };
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickupLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropoffLocation;
    GeoPoint pickup = GeoPoint(initialPos!.latitude, initialPos!.longitude);
    GeoPoint dropoff = GeoPoint(finalPos!.latitude, finalPos!.longitude);
    orderData['pickup'] = pickup;
    orderData['dropoff'] = dropoff;
    orderData['status'] = 'waiting';
    orderData['createdAt'] = DateTime.now();
    FirestoreService().createOrder(orderData);
  }
}
