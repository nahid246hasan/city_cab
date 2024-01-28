import 'package:city_cab/models/all_users.dart';
import 'package:firebase_auth/firebase_auth.dart';

String mapKey="AIzaSyBxvP_Bz59gcf6mO7l4I-5b5FZsLxX7Vjc";
String autoCompleteUrl="https://maps.googleapis.com/maps/api/place/autocomplete/json";
User? firebaseUser;
Users? usersCurrentInfo;