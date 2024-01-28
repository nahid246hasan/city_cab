import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:city_cab/configMaps.dart';
import 'package:city_cab/models/direction_details.dart';
import 'package:city_cab/models/nearby_available_drivers.dart';
import 'package:city_cab/models/option_model.dart';
import 'package:city_cab/provider/app_data.dart';
import 'package:city_cab/resources/assets/image_assets.dart';
import 'package:city_cab/resources/assistant/assistant_methods.dart';
import 'package:city_cab/resources/assistant/geofire_assistant.dart';
import 'package:city_cab/resources/components/divider.dart';
import 'package:city_cab/resources/components/progress_dialogue.dart';
import 'package:city_cab/resources/routes/routes_name.dart';
import 'package:city_cab/screens/payment_&_rating_screen/payment_&_rating_screen.dart';
import 'package:city_cab/utils/utils.dart';
import 'package:city_cab/view_model/controller/option_list_controller/option_list_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  DirectionDetails? tripDirectionDetails;

  DatabaseReference? rideRiquestRef;

  bool nearByAvailableDriversKeysLoaded = false;

  var nearbyIcon;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AssistantMethods.getCurrentOnlineUserInfo();
  }

  void saveRideRequest() {
    rideRiquestRef =
        FirebaseDatabase.instance.ref().child("Ride Request").push();

    var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;

    Map pickUpLocMap = {
      "latitude": pickUp.latitude.toString(),
      "longitude": pickUp.longitude.toString(),
    };

    Map dropUOffLocMap = {
      "latitude": dropOff.latitude.toString(),
      "longitude": dropOff.longitude.toString(),
    };

    Map rideInfoMap = {
      "driver_id": "waiting",
      "payment_method": "cash",
      "pickup": pickUpLocMap,
      "dropoff": dropUOffLocMap,
      "create_at": DateTime.now().toString(),
      "rider_name": usersCurrentInfo?.name,
      "rider_phone": usersCurrentInfo?.phone,
      "pickup_address": pickUp.placeName,
      "dropoff_address": dropOff.placeName,
    };

    rideRiquestRef?.set(rideInfoMap);
  }

  void cancelRiderReq() {
    rideRiquestRef?.remove();
  }

  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();

  late GoogleMapController googleMapController;

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  double rideDetailsContainerHeight = 0;
  double requestRideContainerHeight = 0;
  double searchContainerHeight = 300;
  bool drawerOpen = true;

  double driverDetailsContainerHeight = 0;
  double afterDriverArrivedDetailsContainerHeight = 0;

  double duringRideContainerHeight = 0;

  void displayRequestRideContainer() {
    setState(() {
      requestRideContainerHeight = 250;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = true;
    });
    saveRideRequest();
  }

  resetApp() {
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 300;
      rideDetailsContainerHeight = 0;
      requestRideContainerHeight = 0;
      bottomPaddingOfMap = 230.0;
      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
    });
    locatePosition();
  }

  void displayRideDetailsContainer() async {
    await getPlaceDirection();

    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 270;
      bottomPaddingOfMap = 230.0;
      drawerOpen = false;
    });
  }

  void driverDetailsContainer() {
    setState(() {
      requestRideContainerHeight = 0;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 270.0;
      driverDetailsContainerHeight = 320;
    });
  }

  void afterDriverArrivedDetailsContainer() {
    setState(() {
      requestRideContainerHeight = 0;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 270.0;
      driverDetailsContainerHeight = 0;
      afterDriverArrivedDetailsContainerHeight = 340;
    });
  }

  void duringRideContainer() {
    setState(() {
      bottomPaddingOfMap = 270.0;
      afterDriverArrivedDetailsContainerHeight = 0;
      duringRideContainerHeight = 320;
    });
  }

  late Position currentPosition;

  double bottomPaddingOfMap = 0;

  void locatePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition = CameraPosition(
      target: latLngPosition,
      zoom: 14,
    );
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(cameraPosition),
    );
    var assistantMethods = Get.put(AssistantMethods());
    var address =
        await assistantMethods.searchCoordinateAddress(position, context);
    if (kDebugMode) {
      print("This is your Address :: $address");
    }
    initGeoFireListener();
  }

  // static const LatLng _kLatLngPlex =
  //     LatLng(37.42796133580664, -122.085749655962);
  // static const LatLng _pLatLngPlex = LatLng(37.43, -122.086);

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14,
  );

  static const colorizeColors = [
    Colors.green,
    Colors.purple,
    Colors.pink,
    Colors.blue,
    Colors.yellow,
    Colors.red,
  ];

  static const colorizeTextStyle = TextStyle(
    fontSize: 55.0,
    fontFamily: 'Signatra',
  );

  OptionListController optionListController = Get.put(OptionListController());

  @override
  Widget build(BuildContext context) {
    createIconMarker();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Main Screen"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: ElevatedButton(
              onPressed: () {
                Utils.toastMessage("It will be added soon...");
                print('Emergency SOS button pressed!');
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                // Set the button color to red for emergency
                padding: EdgeInsets.all(10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: Text(
                'Emergency Call',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
      drawer: Container(
        color: Colors.white,
        width: 255,
        child: Drawer(
          child: ListView(
            children: [
              Container(
                height: 165,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      const Image(
                        image: AssetImage(ImageAssets.userIcon),
                        height: 65,
                        width: 65,
                      ),
                      SizedBox(width: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Nahid Hasan",
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: "Brand-Bold",
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextButton(
                              onPressed: () {
                                Get.toNamed(RoutesName.profileScreen);
                              },
                              child: const Text("Visit Profile"))
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const DividerWidget(),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Get.toNamed(RoutesName.historyScreen);
                },
                child: const ListTile(
                  leading: Icon(Icons.history),
                  title: Text(
                    "History",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const ListTile(
                leading: Icon(Icons.info),
                title: Text(
                  "About",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Get.toNamed(RoutesName.loginScreen);
                },
                child: const ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                  title: Text(
                    "Sign Out",
                    style: TextStyle(fontSize: 15, color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: polylineSet,
            markers: markersSet,
            circles: circlesSet,
            // markers: {
            //   const Marker(
            //     markerId: MarkerId("_currentLocation"),
            //     icon: BitmapDescriptor.defaultMarker,
            //     position: _kLatLngPlex,
            //   ),
            //   const Marker(
            //     markerId: MarkerId("_sourceLocation"),
            //     icon: BitmapDescriptor.defaultMarker,
            //     position: _pLatLngPlex,
            //   ),
            // },
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              googleMapController = controller;
              setState(() {
                bottomPaddingOfMap = 300;
              });
              locatePosition();
            },
          ),
          //HamburgerButton for Drawer
          Positioned(
            top: 38,
            left: 22,
            child: GestureDetector(
              onTap: () {
                (drawerOpen)
                    ? scaffoldKey.currentState?.openDrawer()
                    : resetApp();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    )
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Icon(
                    (drawerOpen) ? Icons.menu : Icons.close,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

          //search Ui
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              curve: Curves.bounceIn,
              duration: const Duration(milliseconds: 160),
              child: Container(
                height: searchContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      const Text(
                        "Hi there,",
                        style: TextStyle(fontSize: 12),
                      ),
                      const Text(
                        "Where to?",
                        style:
                            TextStyle(fontSize: 20, fontFamily: "Brand-Bold"),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          var res = await Get.toNamed(RoutesName.searchScreen);

                          if (res == "obtainDirection") {
                            //await getPlaceDirection();
                            displayRideDetailsContainer();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 6,
                                spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7),
                              )
                            ],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.blueAccent),
                                SizedBox(width: 10),
                                Text("Search Drop Off")
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.home, color: Colors.grey),
                          const SizedBox(width: 12),
                          Column(
                            //mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(Provider.of<AppData>(context)
                                          .pickUpLocation !=
                                      null
                                  ? Provider.of<AppData>(context)
                                      .pickUpLocation
                                      .placeName
                                  : "Add Home"),
                              const SizedBox(height: 4),
                              const Text(
                                "Your living home address",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      const DividerWidget(),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Icon(Icons.work, color: Colors.grey),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Add Work"),
                              SizedBox(height: 4),
                              Text(
                                "Your office address",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          //ride details ui
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.bounceIn,
              duration: const Duration(milliseconds: 160),
              child: Container(
                height: rideDetailsContainerHeight,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 16,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            displayRequestRideContainer();
                          },
                          child: Container(
                            width: double.infinity,
                            color: Colors.tealAccent[100],
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                children: [
                                  const Image(
                                    image: AssetImage(ImageAssets.taxi),
                                    height: 70,
                                    width: 80,
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Car",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: "Brand-Bold"),
                                      ),
                                      Text(
                                        ((tripDirectionDetails != null)
                                            ? "${tripDirectionDetails?.distanceText}"
                                            : ''),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(child: Container()),
                                  Text(
                                    ((tripDirectionDetails != null)
                                        ? "৳${AssistantMethods.calculateFares(tripDirectionDetails!, 1)}"
                                        : ''),
                                    style: const TextStyle(
                                        fontFamily: "Brand-Bold"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: () {
                            displayRequestRideContainer();
                          },
                          child: Container(
                            width: double.infinity,
                            color: Colors.tealAccent[100],
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                children: [
                                  const Image(
                                    image: AssetImage(ImageAssets.taxi),
                                    height: 70,
                                    width: 80,
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Share Car",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: "Brand-Bold"),
                                      ),
                                      Text(
                                        ((tripDirectionDetails != null)
                                            ? "${tripDirectionDetails?.distanceText}"
                                            : ''),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(child: Container()),
                                  Text(
                                    ((tripDirectionDetails != null)
                                        ? "৳${AssistantMethods.calculateFares(tripDirectionDetails!, 2)}"
                                        : ''),
                                    style: const TextStyle(
                                        fontFamily: "Brand-Bold"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 17),
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.moneyCheckAlt,
                                size: 18,
                                color: Colors.black54,
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              Text("Cash"),
                              SizedBox(
                                width: 6,
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.black54,
                                size: 16,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 13),
                        //   child: ElevatedButton(
                        //     onPressed: () {
                        //       displayRequestRideContainer();
                        //       if (kDebugMode) {
                        //         print("Clicked");
                        //       }
                        //     },
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: Colors.blue,
                        //     ),
                        //     child: const Padding(
                        //       padding: EdgeInsets.all(15),
                        //       child: Row(
                        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //         children: [
                        //           Text(
                        //             "Request",
                        //             style: TextStyle(
                        //               fontSize: 20,
                        //               fontWeight: FontWeight.bold,
                        //               color: Colors.white,
                        //             ),
                        //           ),
                        //           Icon(
                        //             FontAwesomeIcons.taxi,
                        //             color: Colors.white,
                        //             size: 26,
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          //ride request or cancel ui
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0.5,
                      blurRadius: 16,
                      color: Colors.black54,
                      offset: Offset(0.7, 0.7),
                    )
                  ]),
              height: requestRideContainerHeight,
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedTextKit(
                        animatedTexts: [
                          ColorizeAnimatedText(
                            'Requesting a Ride...',
                            textStyle: colorizeTextStyle,
                            colors: colorizeColors,
                            textAlign: TextAlign.center,
                          ),
                          ColorizeAnimatedText(
                            'Please wait...',
                            textStyle: colorizeTextStyle,
                            colors: colorizeColors,
                            textAlign: TextAlign.center,
                          ),
                          ColorizeAnimatedText(
                            'Finding a Driver...',
                            textStyle: colorizeTextStyle,
                            colors: colorizeColors,
                            textAlign: TextAlign.center,
                          ),
                        ],
                        isRepeatingAnimation: true,
                        onTap: () {
                          print("Tap Event");
                        },
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            cancelRiderReq();
                            resetApp();
                            driverDetailsContainerHeight = 0;
                          },
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(width: 2, color: Colors.grey),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 26,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            driverDetailsContainer();
                          },
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(width: 2, color: Colors.grey),
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Container(
                    //   width: double.infinity,
                    //   child: const Text(
                    //     "Cancel Ride",
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(fontSize: 12),
                    //   ),
                    // )
                  ],
                ),
              ),
            ),
          ),

          //display assigned driver info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0.5,
                      blurRadius: 16,
                      color: Colors.black54,
                      offset: Offset(0.7, 0.7),
                    )
                  ]),
              height: driverDetailsContainerHeight,
              child: Padding(
                padding: EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Driver is Coming.....",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            afterDriverArrivedDetailsContainer();
                          },
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(26)),
                              border: Border.all(width: 2, color: Colors.grey),
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    const Text(
                      "White - Toyota Corolla",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const Text(
                      "Evan",
                      style: TextStyle(fontSize: 20),
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Container(
                              height: 55,
                              width: 55,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(26)),
                                border:
                                    Border.all(width: 2, color: Colors.grey),
                              ),
                              child: const Icon(
                                Icons.call,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text("Call"),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              height: 55,
                              width: 55,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(26)),
                                border:
                                    Border.all(width: 2, color: Colors.grey),
                              ),
                              child: const Icon(
                                Icons.list,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text("Details"),
                          ],
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                cancelRiderReq();
                                resetApp();
                                driverDetailsContainerHeight = 0;
                              },
                              child: Container(
                                height: 55,
                                width: 55,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(26)),
                                  border:
                                      Border.all(width: 2, color: Colors.grey),
                                ),
                                child: Icon(
                                  Icons.cancel,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Cancel"),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),

          //after driver arrived
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0.5,
                      blurRadius: 16,
                      color: Colors.black54,
                      offset: Offset(0.7, 0.7),
                    )
                  ]),
              height: afterDriverArrivedDetailsContainerHeight,
              child: Padding(
                padding: EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select option for your ride",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                          itemCount: optionListController.option.length,
                          itemBuilder: (BuildContext context, int index) {
                            return OptionDesign(
                              opt: optionListController.option[index].opt,
                              ind: index,
                              isSelected:
                                  optionListController.option[index].isSelected,
                              optionModel: optionListController.option.value,
                            );
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        //vertical: 10,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          style: ButtonStyle(
                            side: MaterialStateProperty.all<BorderSide>(
                                BorderSide(color: Colors.black54, width: 1.0)),
                          ),
                          child: const Text(
                            "Done",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          onPressed: () {
                            duringRideContainer();
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          //during ride
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0.5,
                      blurRadius: 16,
                      color: Colors.black54,
                      offset: Offset(0.7, 0.7),
                    )
                  ]),
              height: duringRideContainerHeight,
              child: Padding(
                padding: EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Safe travel...",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>PaymentAndRatingScreen(tripDirectionDetails)));
                            print('Payment button pressed!');
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.grey,
                            // Set the button color to grey
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10), // Set button padding
                          ),
                          child: const Text(
                            'Arrived & Pay',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors
                                  .white, // Set text color to white for better visibility
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(),
                    ListTile(
                      title: const Text(
                        "Current Fare : ",
                        style: TextStyle(fontFamily: "Brand-Bold"),
                      ),
                      trailing: Text(
                        ((tripDirectionDetails != null)
                            ? "৳${AssistantMethods.calculateFares(tripDirectionDetails!, 1)}"
                            : ''),
                        style: const TextStyle(
                            fontFamily: "Brand-Bold", fontSize: 18),
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        "Discount Fare : ",
                        style: TextStyle(fontFamily: "Brand-Bold"),
                      ),
                      trailing: Text(
                        ((tripDirectionDetails != null) ? "৳00" : ''),
                        style: const TextStyle(
                            fontFamily: "Brand-Bold", fontSize: 18),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      title: const Text(
                        "Total Fare : ",
                        style: TextStyle(fontFamily: "Brand-Bold"),
                      ),
                      trailing: Text(
                        ((tripDirectionDetails != null)
                            ? "৳${AssistantMethods.calculateFares(tripDirectionDetails!, 1)}"
                            : ''),
                        style: const TextStyle(
                            fontFamily: "Brand-Bold", fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          //Emmergency Sos
        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    var initialPosition =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPosition =
        Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatLng =
        LatLng(initialPosition.latitude, initialPosition.longitude);
    var dropOfLatLng = LatLng(finalPosition.latitude, finalPosition.longitude);

    showDialog(
      context: context,
      builder: (BuildContext context) =>
          ProgreessDialogue(msg: "Please wait..."),
    );

    var details = await AssistantMethods.obtainDirectionsDetails(
        pickUpLatLng, dropOfLatLng);

    setState(() {
      tripDirectionDetails = details;
    });

    Get.back();

    if (kDebugMode) {
      print("this is encoded point:: ");
      print(details?.encodedPoints);
    }

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolylinePointsResults =
        polylinePoints.decodePolyline("${details?.encodedPoints}");

    pLineCoordinates.clear();

    if (decodePolylinePointsResults.isNotEmpty) {
      decodePolylinePointsResults.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: Colors.pink,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOfLatLng.latitude &&
        pickUpLatLng.longitude > dropOfLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOfLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOfLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOfLatLng.longitude),
          northeast: LatLng(dropOfLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOfLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOfLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOfLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOfLatLng);
    }

    googleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickupLocationMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      infoWindow:
          InfoWindow(title: initialPosition.placeName, snippet: "My Location"),
      position: pickUpLatLng,
      markerId: const MarkerId("pickUpId"),
    );

    Marker dropOffLocationMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(
          title: finalPosition.placeName, snippet: "DropOff Location"),
      position: dropOfLatLng,
      markerId: const MarkerId("dropOffId"),
    );
    setState(() {
      markersSet.add(pickupLocationMarker);
      markersSet.add(dropOffLocationMarker);
    });

    Circle pickupLocationCircle = Circle(
      fillColor: Colors.yellow,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.yellowAccent,
      circleId: const CircleId("pickUpId"),
    );

    Circle dropOffLocationCircle = Circle(
      fillColor: Colors.red,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.redAccent,
      circleId: const CircleId("dropOffId"),
    );

    setState(() {
      circlesSet.add(pickupLocationCircle);
      circlesSet.add(dropOffLocationCircle);
    });
  }

  void initGeoFireListener() {
    Geofire.initialize("availableDrivers");
    //comment
    Geofire.queryAtLocation(
            currentPosition.latitude,
            currentPosition.longitude,
            /*range of area*/
            15)
        ?.listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers(
                    map['key'], map['latitude'], map['longitude']);
            nearbyAvailableDrivers.key = map['key'];
            nearbyAvailableDrivers.lat = map['latitude'];
            nearbyAvailableDrivers.lng = map['longitude'];
            GeoFireAssistant.nearbyAvailableDriversList
                .add(nearbyAvailableDrivers);
            if (nearByAvailableDriversKeysLoaded == true) {
              updateAvailableDriversOnMap();
            }
            break;

          case Geofire.onKeyExited:
            GeoFireAssistant.removeDriverFromList(map['key']);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers(
                    map['key'], map['latitude'], map['longitude']);
            // nearbyAvailableDrivers.key = map['key'];
            // nearbyAvailableDrivers.lat = map['latitude'];
            // nearbyAvailableDrivers.lng = map['longitude'];
            GeoFireAssistant.updateDriverNearbyLocation(nearbyAvailableDrivers);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            updateAvailableDriversOnMap();
            break;
        }
      }

      setState(() {});
      //comment
    });
  }

  void updateAvailableDriversOnMap() {
    setState(() {
      markersSet.clear();
    });
    Set<Marker> tMarkers = Set<Marker>();
    for (NearbyAvailableDrivers drivers
        in GeoFireAssistant.nearbyAvailableDriversList) {
      LatLng driverAvailablePosition = LatLng(drivers.lat, drivers.lng);
      Marker marker = Marker(
        markerId: MarkerId('driver${drivers.key}'),
        position: driverAvailablePosition,
        icon: nearbyIcon,
        rotation: AssistantMethods.createRandomNumber(360),
      );
      tMarkers.add(marker);
    }
    setState(() {
      markersSet = tMarkers;
    });
  }

  void createIconMarker() {
    print("hi");
    if (nearbyIcon == null) {
      print("hello");
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "assets/images/car_android.png")
          .then((value) {
        nearbyIcon = value;
      });
    }
  }
}

class OptionDesign extends StatefulWidget {
  String opt;
  int ind;
  bool isSelected;
  List<OptionModel> optionModel;

  OptionDesign({
    super.key,
    required this.opt,
    required this.ind,
    required this.isSelected,
    required this.optionModel,
  });

  @override
  State<OptionDesign> createState() => _OptionDesignState();
}

class _OptionDesignState extends State<OptionDesign> {
  OptionListController optionListController = Get.put(OptionListController());

  int count = 0;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[700],
          child: const Icon(
            Icons.person_outline_outlined,
            color: Colors.white,
          ),
        ),
        title: Text(
          widget.opt,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: widget.isSelected
            ? Icon(
                Icons.check_circle,
                color: Colors.green[700],
              )
            : const Icon(
                Icons.check_circle_outline,
                color: Colors.grey,
              ),
        onTap: () {
          setState(() {
            count++;
            if (count % 2 == 1) {
              optionListController
                  .addIntoTheList(widget.optionModel[widget.ind].opt);
              widget.isSelected = true;
            } else {
              optionListController
                  .removeFromTheList(widget.optionModel[widget.ind].opt);
              widget.isSelected = false;
            }
            print(optionListController.selectedOptions);
          });
        });
  }
}
