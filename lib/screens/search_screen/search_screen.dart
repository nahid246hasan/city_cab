import 'package:city_cab/configMaps.dart';
import 'package:city_cab/models/address.dart';
import 'package:city_cab/models/place_prediction.dart';
import 'package:city_cab/provider/app_data.dart';
import 'package:city_cab/resources/assets/image_assets.dart';
import 'package:city_cab/resources/assistant/request_assistant.dart';
import 'package:city_cab/resources/components/divider.dart';
import 'package:city_cab/resources/components/progress_dialogue.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickupController = TextEditingController();
  TextEditingController drpoOffController = TextEditingController();

  List<PlacePrediction> placePredictionList = [];

  Uuid uuid = Uuid();
  String sessionToken = "";

  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).pickUpLocation.placeName ?? "";
    pickupController.text = placeAddress;

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 250,
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 6,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7),
              )
            ]),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 25, right: 25, bottom: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    Stack(children: [
                      GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Icon(Icons.arrow_back)),
                      const Center(
                        child: Text(
                          "Set Drop Off",
                          style:
                              TextStyle(fontSize: 18, fontFamily: "Brand-Bold"),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Image.asset(
                          ImageAssets.pickicon,
                          height: 16,
                          width: 16,
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(3),
                              child: TextField(
                                controller: pickupController,
                                decoration: InputDecoration(
                                  hintText: "PickUp Lication",
                                  fillColor: Colors.grey[400],
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.only(
                                    left: 11,
                                    top: 8,
                                    bottom: 8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Image.asset(
                          ImageAssets.desticon,
                          height: 16,
                          width: 16,
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(3),
                              child: TextField(
                                onChanged: (val) {
                                  findPlace(val);
                                },
                                controller: drpoOffController,
                                decoration: InputDecoration(
                                  hintText: "Where to?",
                                  fillColor: Colors.grey[400],
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.only(
                                    left: 11,
                                    top: 8,
                                    bottom: 8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          //prediction tile

          (placePredictionList.length > 0)
              ? SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        return PredictionTile(
                            placePrediction: placePredictionList[index]);
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          DividerWidget(),
                      itemCount: placePredictionList.length,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                    ),
                  ),
              )
              : SingleChildScrollView(child: Container()),
        ],
      ),
    );
  }
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String request =
          "$autoCompleteUrl?input=$placeName&key=$mapKey&sessiontoken=$sessionToken";//&components=country:BD";
      var res = await RequestAssistant.getRequest(request);

      if (res == 'failed') {
        return;
      }

      if (res["status"] == "OK") {
        var predictions = res["predictions"];
        var placesList = (predictions as List)
            .map((e) => PlacePrediction.fromJson(e))
            .toList();

        setState(() {
          placePredictionList = placesList;
        });
      }
    }
  }
}

class PredictionTile extends StatelessWidget {
  final PlacePrediction placePrediction;

  const PredictionTile({super.key, required this.placePrediction});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        getPlaceAddressDetails("${placePrediction.placeId}", context);
      },
      child: Container(
        child: Column(
          children: [
            SizedBox(width: 10),
            Row(
              children: [
                const Icon(Icons.add_location),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${placePrediction.mainText}",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 3),
                      Text(
                        "${placePrediction.secondaryText}",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  void getPlaceAddressDetails(String placeId, context) async {
    showDialog(context: context, builder: (BuildContext context)=>ProgreessDialogue(msg: "Setting DropOff, Please wait..."));
    String placeDetailsUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey';
    var res = await RequestAssistant.getRequest(placeDetailsUrl);

    Get.back();
    if (res == "failed") {
      return;
    }
    if (res["status"] == "OK") {
      Address address = Address(
        '',
        res["result"]["name"],
        placeId,
        res["result"]["geometry"]["location"]["lat"],
        res["result"]["geometry"]["location"]["lng"],
      );
      Provider.of<AppData>(context,listen: false).updateDropOffLocationAddress(address);
      print("This is dropoff location :: ");
      print(address.placeName);

      Get.back(result: "obtainDirection");
    }
  }
}
