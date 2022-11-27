import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ondoorstep/dashboard/searchscreen.dart';
import 'package:ondoorstep/datahanlder/appData.dart';
import 'package:ondoorstep/maps/DividerWidget.dart';
import 'package:ondoorstep/maps/Models/address.dart';
import 'package:ondoorstep/maps/Models/directionsDetails.dart';
import 'package:ondoorstep/maps/assistantMethods.dart';
import 'package:ondoorstep/maps/configmaps.dart';
import 'package:ondoorstep/maps/requestAssistance.dart';
import 'package:ondoorstep/services/auth.dart';
import 'package:ondoorstep/services/firestore.dart';
import 'package:ondoorstep/services/models.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  late AppUser currentUser;
  late LocationPermission permission;
  late String name;
  DirectionsDetails tripDirectionDetails = DirectionsDetails(
      distanceText: '',
      distanceValue: 0,
      durationValue: 0,
      durationText: '',
      encodedPoints: '');
  Set<Polyline> polylineSet = {};
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  double rideDetailContainer = 0;
  double searchContainerHeight = 300.0;

  Position currentPosition = const Position(
      longitude: 0,
      latitude: 0,
      timestamp: null,
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);

  late GoogleMapController newGoogleMapController;
  final Completer<GoogleMapController> _controllerGooglemap = Completer();

  bool drawerOpen = true;
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  late String _mapStyle;
  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/google.txt').then((string) {
      _mapStyle = string;
    });
    _locationPermission();
  }

  double bottomPaddingOfMap = 0;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          currentUser = snapshot.data as AppUser;
          name = currentUser.name;
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
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedSize(
                    // ignore: deprecated_member_use
                    vsync: this,
                    curve: Curves.bounceIn,
                    duration: const Duration(milliseconds: 160),
                    child: Container(
                      height: searchContainerHeight,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18.0),
                            topRight: Radius.circular(18.0)),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _heightSizedBox(6.9),
                            RichText(
                                text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Hi there, ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Brand-Bold',
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: name ?? '',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontFamily: 'Brand-Bold',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.lightBlueAccent,
                                  ),
                                ),
                              ],
                            )),
                            _heightSizedBox(2.0),
                            RichText(
                                text: const TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      'Where do you want to transport your goods ?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Brand-Bold',
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            )),
                            _heightSizedBox(20),
                            GestureDetector(
                              onTap: () async {
                                var res = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SearchScreen()));
                                if (res == "obtainDirection") {}
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 236, 237, 240),
                                      blurRadius: 6.0,
                                      spreadRadius: 0.5,
                                      offset: Offset(0.7, 0.7),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.search,
                                        color: Color.fromARGB(255, 58, 81, 122),
                                      ),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      Text("Search Drop Off"),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            _heightSizedBox(20),
                            Row(
                              children: [
                                const Icon(
                                  Icons.home,
                                  size: 30,
                                  color: Color.fromARGB(255, 58, 81, 122),
                                ),
                                const SizedBox(
                                  width: 12.0,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Provider.of<AppData>(context)
                                                  .pickupLocation !=
                                              null
                                          ? Provider.of<AppData>(context)
                                              .pickupLocation
                                              .placeName
                                          : "Add Home",
                                      style: const TextStyle(
                                          fontSize: 14.0,
                                          fontFamily: 'Brand-Bold'),
                                    ),
                                    _heightSizedBox(4),
                                    const Text(
                                      "Your residential address",
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            const DividerWidget(),
                            _heightSizedBox(14),
                            Row(
                              children: [
                                const Icon(
                                  Icons.work,
                                  size: 26,
                                  color: Color.fromARGB(255, 58, 81, 122),
                                ),
                                _widthSizedBox(12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Add Work",
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          fontFamily: 'Brand-Bold'),
                                    ),
                                    _heightSizedBox(4),
                                    const Text(
                                      "Your office address",
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ],
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
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const Center(child: Text('No data'));
        }
      }),
      future: FirestoreService().getUser(AuthService().user!.uid),
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

  Future<void> _locationPermission() async {
    if (await Permission.location.isGranted) {
      _getLiveLocation();
    } else {
      await Permission.location.request();
    }
  }

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
    String address = await AssistantMethods.searchCoordinateAddress(
        currentPosition, context);
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
      placeAddress = st1 + " , " + st2 + " , " + st3 + " , " + st4;
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

  void _locatePosition() {
    LatLng latLngPosition =
        LatLng(currentPosition.latitude, currentPosition.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);
    _controllerGooglemap.future.then((value) {
      value.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    });
  }
}
