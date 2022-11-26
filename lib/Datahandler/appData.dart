import 'package:flutter/cupertino.dart';
import 'package:ondoorstep/maps/Models/address.dart';
import 'package:flutter/cupertino.dart';

class AppData extends ChangeNotifier {
  Address? pickupLocation, dropoffLocation;
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
