// ignore_for_file: unnecessary_new

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ondoorstep/dashboard/searchScreen.dart';
import 'package:ondoorstep/maps/DividerWidget.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ondoorstep/maps/Models/directionsDetails.dart';
import 'package:provider/provider.dart';

import '../Datahandler/appData.dart';
import '../maps/assistantMethods.dart';

class Dashboard extends StatefulWidget {
  var context;

  Dashboard({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DashboardState();
  }
}

class DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  DirectionsDetails tripDirectionDetails = DirectionsDetails(
      distanceText: '',
      distanceValue: 0,
      durationValue: 0,
      durationText: '',
      encodedPoints: '');
  //polyline
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  double rideDetailContainer = 0;
  double searchContainerHeight = 300.0;

  bool drawerOpen = true;

  resetApp() {
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 300.0;
      rideDetailContainer = 0;
      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
    });

    locatePostion();
  }

  void displayRiderDetailsContainer() async {
    await getPlaceDirection();
    setState(() {
      searchContainerHeight = 0;
      rideDetailContainer = 240;
      bottomPaddingOfMap = 230;
      drawerOpen = false;
    });
  }

  Position currentPosition = const Position(
      longitude: 0,
      latitude: 0,
      timestamp: null,
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);

  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0;

  void locatePostion() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng latLngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        new CameraPosition(target: latLngPosition, zoom: 14);
    GoogleMapController googleMapController = await _controllerGooglemap.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address =
        // ignore: use_build_context_synchronously
        await AssistantMethods.searchCoordinateAddress(position, context);
    print("This is your address :: $address");
  }

  late GoogleMapController newGoogleMapController;
  final Completer<GoogleMapController> _controllerGooglemap = Completer();

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
          myLocationButtonEnabled: true,
          initialCameraPosition: _kGooglePlex,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: false,
          polylines: polylineSet,
          markers: markersSet,
          circles: circlesSet,
          onMapCreated: (GoogleMapController controller) {
            _controllerGooglemap.complete(controller);
            newGoogleMapController = controller;
            newGoogleMapController.setMapStyle(_mapStyle);
            setState(() {
              bottomPaddingOfMap = 300.0;
            });
            locatePostion();
          },
        ),
        //HamburgerButton(),
        Positioned(
          top: 38.0,
          left: 22.0,
          child: GestureDetector(
            onTap: () {
              if (drawerOpen) {
                // ignore: prefer_typing_uninitialized_variables
                var scaffoldKey;
                scaffoldKey.currentState!.openDrawer();
              } else {
                resetApp();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: const [
                    BoxShadow(
                        color: Color.fromARGB(255, 232, 230, 235),
                        blurRadius: 6.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7))
                  ]),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20.0,
                child: Icon(
                  (drawerOpen) ? Icons.menu : Icons.close,
                  color: const Color.fromARGB(255, 53, 64, 99),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          left: 0.0,
          right: 0.0,
          bottom: 0.0,
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
                    horizontal: 24.0, vertical: 18.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 6.9,
                      ),
                      const Text(
                        "Hi there,",
                        style: TextStyle(fontSize: 10.0),
                      ),
                      const Text(
                        "Where to,",
                        style:
                            TextStyle(fontSize: 20.0, fontFamily: 'Brand-Bold'),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      GestureDetector(
                        onTap: () async {
                          var res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SearchScreen()));
                          if (res == "obtainDirection") {
                            displayRiderDetailsContainer();
                          }
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
                      const SizedBox(
                        height: 24.0,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.home,
                            color: Color.fromARGB(255, 58, 81, 122),
                          ),
                          const SizedBox(
                            width: 12.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Provider.of<AppData>(context).pickupLocation !=
                                        null
                                    ? Provider.of<AppData>(context)
                                        .pickupLocation!
                                        .placeName
                                    : "Add Home",
                                style: const TextStyle(
                                    fontSize: 12.0, fontFamily: 'Brand-Bold'),
                              ),
                              const SizedBox(
                                height: 4.0,
                              ),
                              const Text(
                                "Your residential address",
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.black54),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const DividerWidget(),
                      const SizedBox(
                        height: 16.0,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.work,
                            color: Color.fromARGB(255, 58, 81, 122),
                          ),
                          const SizedBox(
                            width: 12.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Add Work",
                                style: TextStyle(
                                    fontSize: 18.0, fontFamily: 'Brand-Bold'),
                              ),
                              SizedBox(
                                height: 4.0,
                              ),
                              Text(
                                "Your office address",
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.black54),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ]),
              ),
            ),
          ),
        ),
        Positioned(
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
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Image.asset(
                              "assets/truck.png",
                              height: 70.0,
                              width: 80.0,
                            ),
                            const SizedBox(
                              width: 16.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Truck",
                                  style: TextStyle(
                                      fontSize: 18.0, fontFamily: "Brand-Bold"),
                                ),
                                Text(
                                  // ignore: unnecessary_null_comparison
                                  "${(tripDirectionDetails != null) ? tripDirectionDetails.distanceText
                                      // ignore: unnecessary_null_comparison
                                      : ""} - ${(tripDirectionDetails != null) ? tripDirectionDetails.durationText : ""}",
                                  style: const TextStyle(
                                      fontSize: 12.0,
                                      color: Color.fromARGB(255, 74, 111, 158)),
                                ),
                              ],
                            ),
                            Expanded(
                                child: Container(
                              child: Text(
                                ((tripDirectionDetails.durationText != null)
                                    ? '\$${AssistantMethods.calculateFares(tripDirectionDetails)}'
                                    : ''),
                                style: const TextStyle(
                                    fontFamily: 'Brand-Bold',
                                    fontSize: 12.0,
                                    color: Color.fromARGB(255, 74, 111, 158)),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 58, 81, 122),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(17.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          print("Requesting a truck");
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22.0),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(255, 241, 243, 245),
                blurRadius: 6.0,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7),
              ),
            ],
          ),
          height: 250.0,
          child: Column(children: const [
            SizedBox(
              height: 12.0,
            ),
          ]),
        ),
      ],
    ));
  }

  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickupLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropoffLocation;
    var pickUpLatLng = LatLng(initialPos!.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos!.latitude, finalPos.longitude);
    showDialog(
        context: context,
        builder: (BuildContext context) => const AlertDialog(
              title: Text("OnDoorStep"),
              content: Text("Pickup Location"),
            ));
    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);
    setState(() {
      tripDirectionDetails = details!;
    });
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    print("This is encoded points :: ");
    print(details!.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints);

    pLineCoordinates.clear();
    if (decodedPolyLinePointsResult.isNotEmpty) {
      for (var pointLatLng in decodedPolyLinePointsResult) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }
    polylineSet.clear();
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

    setState(() {
      markersSet.add(pickupLocMarker);
      markersSet.add(dropOffLocMarker);
    });

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
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
    });
  }
}
