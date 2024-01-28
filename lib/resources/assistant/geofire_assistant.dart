import '../../models/nearby_available_drivers.dart';

class GeoFireAssistant{
  static List<NearbyAvailableDrivers> nearbyAvailableDriversList=[];

  static void removeDriverFromList(String key){
    int index=nearbyAvailableDriversList.indexWhere((element) =>element.key==key);
    nearbyAvailableDriversList.removeAt(index);
  }

  static void updateDriverNearbyLocation(NearbyAvailableDrivers nearbyAvailableDrivers){
    int index=nearbyAvailableDriversList.indexWhere((element) =>element.key==nearbyAvailableDrivers.key);
    nearbyAvailableDriversList[index].lat=nearbyAvailableDrivers.lat;
    nearbyAvailableDriversList[index].lng=nearbyAvailableDrivers.lng;
  }
}