import 'package:flutter/material.dart';
import 'package:ondoorstep/maps/Models/address.dart';

class AppData extends ChangeNotifier {
  late Address pickupLocation, dropoffLocation;
  void updatePickupAddress(Address pickupAddress) {
    pickupLocation = pickupAddress;
    notifyListeners();
  }

  void updateDropOffAddress(Address dropoffAddress) {
    dropoffLocation = dropoffAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Address address) {}
}
