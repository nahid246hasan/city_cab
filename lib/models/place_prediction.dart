class PlacePrediction{
  String? secondaryText;
  String? mainText;
  String? placeId;

  PlacePrediction({this.secondaryText, this.mainText, this.placeId});

  PlacePrediction.fromJson(Map<String,dynamic> json){
    secondaryText=json["structured_formatting"]["secondary_text"];
    mainText=json["structured_formatting"]["main_text"];
    placeId=json["place_id"];
  }
}