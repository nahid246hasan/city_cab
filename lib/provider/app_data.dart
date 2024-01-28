import 'package:city_cab/models/address.dart';
import 'package:flutter/cupertino.dart';

class AppData extends ChangeNotifier{
  Address pickUpLocation=Address("", "", "", 0.0, 0.0);
  Address dropOffLocation=Address("", "", "", 0.0, 0.0);

  void updatePickupLocationAddress(Address pickupAddress){
    pickUpLocation=pickupAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Address dropOffAddress){
    dropOffLocation=dropOffAddress;
    notifyListeners();
  }
}