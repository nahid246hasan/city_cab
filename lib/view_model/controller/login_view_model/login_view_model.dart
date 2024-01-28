import 'package:city_cab/resources/components/progress_dialogue.dart';
import 'package:city_cab/resources/routes/routes_name.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../main.dart';
import '../../../utils/utils.dart';

class LoginViewModel extends GetxController {
  final emailController = TextEditingController().obs;
  final passwordController = TextEditingController().obs;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<void> login(BuildContext context) async {
    if (!emailController.value.text.contains('@')) {
      Utils.toastMessage("Email address is not valid");
      return;
    } else if (passwordController.value.text.length < 6) {
      Utils.toastMessage("Password must be at least 6 charecter");
      return;
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgreessDialogue(
            msg: 'Authenticating, Please wait....',
          );
        });
    var firebaseUser = (await firebaseAuth
            .signInWithEmailAndPassword(
                email: emailController.value.text,
                password: passwordController.value.text)
            .catchError(
      (error, stackTrace) {
        Get.back();
        Utils.toastMessage("Error: $error");
      },
    ))
        .user;
    if (firebaseUser != null) {
      userRef.child(firebaseUser.uid).once().then((DatabaseEvent snap) {
        if (snap != null) {
          Get.toNamed(RoutesName.mainScreen);
          Utils.toastMessage("Successfully logedin");
        } else {
          Get.back();
          firebaseAuth.signOut();
          Utils.toastMessage("No record founded for this user");
        }
      }).onError((error, stackTrace) {
        Utils.toastMessage("Error: $error");
      });
      //save User into realtime database
    } else {
      Utils.toastMessage('Error occurred, Cannot be signed in');
      //error-occured - display error message
    }
  }
}
