import 'dart:async';
import 'dart:math';

import 'package:city_cab/configMaps.dart';
import 'package:city_cab/models/address.dart';
import 'package:city_cab/models/all_users.dart';
import 'package:city_cab/models/direction_details.dart';
import 'package:city_cab/provider/app_data.dart';
import 'package:city_cab/resources/assistant/request_assistant.dart';
import 'package:city_cab/resources/routes/routes_name.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AssistantMethods {
  Future<String> searchCoordinateAddress(
      Position position, BuildContext context) async {
    String placeAddress = "";
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String st1, st2, st3, st4;

    var response = await RequestAssistant.getRequest(url);

    if (response != "failed") {
      //placeAddress=response["results"][0]["formatted_address"];
      st1 = response["results"][0]["address_components"][3]["long_name"];
      st2 = response["results"][0]["address_components"][4]["long_name"];
      st3 = response["results"][0]["address_components"][5]["long_name"];
      st4 = response["results"][0]["address_components"][6]["long_name"];
      placeAddress = st1 + ", " + st2 + ", " + st3 + ", " + st4;

      Address address =
          Address("", placeAddress, "", position.latitude, position.longitude);
      Provider.of<AppData>(context, listen: false)
          .updatePickupLocationAddress(address);
    }

    return placeAddress;
  }

  static Future<DirectionDetails?> obtainDirectionsDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl =
        "https://maps.googleapis.com/maps/api/directions/json?destination=${finalPosition.latitude},${finalPosition.longitude}&origin=${initialPosition.latitude},${initialPosition.longitude}&key=$mapKey";

    var res = await RequestAssistant.getRequest(directionUrl);

    if (res == "failed") {
      return null;
    }
    DirectionDetails directionDetails = DirectionDetails();
    directionDetails.encodedPoints =
        res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText =
        res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue =
        res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText =
        res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue =
        res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  static int calculateFares(DirectionDetails directionDetails, int opt) {
    double timeTraveledFare = (directionDetails.durationValue! / 60) * 0.20;
    double distanceTraveledFare =
        (directionDetails.distanceValue! / 1000) * 0.20;

    double totalFare = timeTraveledFare + distanceTraveledFare;

    //local currency in bdt usd 1$=109tk
    double totalLocalAmount = totalFare * 109;
    if(opt==2){
      totalLocalAmount=totalLocalAmount*0.70;
    }

    return totalLocalAmount.truncate();
  }

  static void getCurrentOnlineUserInfo() async {
    firebaseUser = await FirebaseAuth.instance.currentUser;
    String? userId = firebaseUser?.uid;

    //print(userId);
    DatabaseReference reference =
        FirebaseDatabase.instance.ref().child("users").child(userId!);
    //print(reference);
    reference.get().then(
      (DataSnapshot dataSnapshot) {
        print(dataSnapshot.value);
        if (dataSnapshot.value != null) {
          usersCurrentInfo = Users.fromSnapshot(dataSnapshot);
          print(usersCurrentInfo?.phone);
        }
      },
    );
    // reference.once().then((DataSnapshot dataSnapshot){
    //   if(dataSnapshot.value!=null){
    //     print("*****************************************************************************************");
    //     print(dataSnapshot.value);
    //     usersCurrentInfo=Users.fromSnapshot(dataSnapshot);
    //   }
    // });
  }
  static double createRandomNumber(int num){
    var random=Random();
    int radNumber=random.nextInt(num);
    return radNumber.toDouble();
  }
}
