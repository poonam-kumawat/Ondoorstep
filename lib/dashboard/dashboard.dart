import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ondoorstep/dashboard/searchScreen.dart';
import 'package:ondoorstep/maps/DividerWidget.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../Datahandler/appData.dart';
import '../maps/assistantMethods.dart';

import '../maps/assistantMethods.dart';

class Dashboard extends StatelessWidget {
  late BuildContext context;

  Dashboard({super.key});

  Completer<GoogleMapController> _controllerGooglemap = Completer();
  //polyline
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  late Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0;

  void locatePostion() async {
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
        await AssistantMethods.searchCoordinateAddress(position, context);
    print("This is your address :: " + address);
  }

  late GoogleMapController newGoogleMapController;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          initialCameraPosition: _kGooglePlex,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          polylines: polylineSet,
          markers: markersSet,
          circles: circlesSet,
          onMapCreated: (GoogleMapController controller) {
            _controllerGooglemap.complete(controller);
            newGoogleMapController = controller;

            locatePostion();
          },
        ),
        //HamburgerButton(),
        Positioned(
          top: 45.0,
          left: 22.0,
          child: GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromARGB(255, 232, 230, 235),
                        blurRadius: 6.0,
                        spreadRadius: 0.5,
                        offset: const Offset(0.7, 0.7))
                  ]),
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20.0,
                child: Icon(
                  Icons.menu,
                  color: Color.fromARGB(255, 53, 64, 99),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          left: 0.0,
          right: 0.0,
          bottom: 0.0,
          child: Container(
            height: 300.0,
            decoration: BoxDecoration(
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 6.9,
                    ),
                    Text(
                      "Hi there,",
                      style: TextStyle(fontSize: 10.0),
                    ),
                    Text(
                      "Where to,",
                      style:
                          TextStyle(fontSize: 20.0, fontFamily: 'Brand-Bold'),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    GestureDetector(
                      onTap: () async {
                        var res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchScreen()));
                        if (res == "obtainDirection") {
                          await getPlaceDirection();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: [
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
                            children: [
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
                    SizedBox(
                      height: 24.0,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.home,
                          color: Color.fromARGB(255, 58, 81, 122),
                        ),
                        SizedBox(
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
                              style: TextStyle(
                                  fontSize: 18.0, fontFamily: 'Brand-Bold'),
                            ),
                            SizedBox(
                              height: 4.0,
                            ),
                            Text(
                              "Your residential address",
                              style: TextStyle(
                                  fontSize: 12.0, color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    DividerWidget(),
                    SizedBox(
                      height: 16.0,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.work,
                          color: Color.fromARGB(255, 58, 81, 122),
                        ),
                        SizedBox(
                          width: 12.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
        builder: (BuildContext context) => AlertDialog(
              title: Text("OnDoorStep"),
              content: Text("Pickup Location"),
            ));
    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);
    Navigator.pop(context);
    print("This is encoded points :: ");
    print(details!.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints);

    pLineCoordinates.clear();
    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
          color: Color.fromARGB(255, 58, 81, 122),
          polylineId: PolylineId("PolylineID"),
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
      markerId: MarkerId("pickUpId"),
    );

    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: finalPos.placeName, snippet: "DropOff Location"),
      position: dropOffLatLng,
      markerId: MarkerId("dropOffId"),
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
        circleId: CircleId("pickUpId"));

    Circle dropOffLocCircle = Circle(
        fillColor: Colors.deepPurple,
        center: dropOffLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.deepPurple,
        circleId: CircleId("dropOffId"));

    setState(() {
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
    });
  }
}

void setState(Null Function() param0) {}
