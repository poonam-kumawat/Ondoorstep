import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ondoorstep/maps/requestAssistance.dart';
import 'package:provider/provider.dart';

import '../datahanlder/appData.dart';
import 'Models/address.dart';
import 'Models/directionsDetails.dart';
import 'configmaps.dart';

class AssistantMethods {
  static Future<String> searchCoordinateAddress(
      Position position, context) async {
    String placeAddress = "";
    String st1, st2, st3, st4;
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
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
      userPickupAddress.longitude = position.longitude;
      userPickupAddress.latitude = position.latitude;
      userPickupAddress.placeName = placeAddress;
      Provider.of<AppData>(context, listen: false)
          .updatePickupAddress(userPickupAddress);
    }
    return placeAddress;
  }

  static Future<DirectionsDetails?> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";
    var res = await RequestAssistant.getRequest(directionUrl);
    if (res == "failed") {
      return null;
    }
    print(res);

    DirectionsDetails directionsDetails = DirectionsDetails(
        distanceText: '',
        durationText: '',
        distanceValue: 0,
        durationValue: 0,
        encodedPoints: '');
    directionsDetails.encodedPoints =
        res["routes"][0]["overview_polyline"]["points"];
    directionsDetails.distanceText =
        res["routes"][0]["legs"][0]["distance"]["text"];
    directionsDetails.distanceValue =
        res["routes"][0]["legs"][0]["distance"]["value"];
    directionsDetails.durationText =
        res["routes"][0]["legs"][0]["duration"]["text"];
    directionsDetails.durationValue =
        res["routes"][0]["legs"][0]["duration"]["value"];
    return directionsDetails;
  }

  static int calculateFares(DirectionsDetails directionsDetails) {
    //in terms USD

    double timeTraveledFare = (directionsDetails.durationValue / 60) * 0.20;
    double distanceTraveledFare =
        (directionsDetails.distanceValue / 1000) * 0.20;
    double totalFareAmount = timeTraveledFare + distanceTraveledFare;

    //Local currency
    //1$ = 160 INR
    double totalLocalAmount = (totalFareAmount * 160) / 6;

    return totalLocalAmount.truncate();
  }
}
