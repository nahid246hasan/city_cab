import 'package:firebase_database/firebase_database.dart';

class Users {
  String? id;
  String? phone;
  String? name;
  String? email;

  Users({required this.id, required this.phone, required this.name, required this.email});

  // Factory method to create a Users instance from a DocumentSnapshot
  Users.fromSnapshot(DataSnapshot snapshot) {
    Map<dynamic, dynamic> data = snapshot.value as Map;
    id=snapshot.key;
    name=data["name"];
    email=data["email"];
    phone=data["phone"];
  }
}
