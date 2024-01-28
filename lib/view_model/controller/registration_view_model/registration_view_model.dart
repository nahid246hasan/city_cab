import 'package:city_cab/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../main.dart';
import '../../../resources/components/progress_dialogue.dart';

class RegistrationViewModel extends GetxController {
  final nameController = TextEditingController().obs;
  final emailController = TextEditingController().obs;
  final phoneController = TextEditingController().obs;
  final passwordController = TextEditingController().obs;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;


  Future<void> registration(BuildContext context) async {
    if (nameController.value.text.length < 4) {
      Utils.toastMessage("Must be atleast 3 Charecters");
    } else if (!emailController.value.text
        .contains('@')) {
      Utils.toastMessage("Email address is not valid");
    } else if (phoneController.value.text.isEmpty) {
      Utils.toastMessage("Phone number is required");
    } else if (passwordController.value.text.length < 6) {
      Utils.toastMessage("Password must be at least 6 charecter");
    } else {

      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ProgreessDialogue(
              msg: 'Registering, Please wait....',
            );
          });

      var firebaseUser = (await firebaseAuth
              .createUserWithEmailAndPassword(
                  email: emailController.value.text,
                  password: passwordController.value.text)
              .catchError((error, stackTrace) {
        Get.back();
        Utils.toastMessage("Error: $error");
      }))
          .user;
      if (firebaseUser != null) {
        //user created

        Map userDataMap = {
          "name": nameController.value.text,
          "email": emailController.value.text,
          "phone": phoneController.value.text,
          "password": passwordController.value.text
        };

        userRef.child(firebaseUser.uid).set(userDataMap);

        Utils.toastMessage("Successfully registered");
        Get.back();
        //save User into realtime database
      } else {
        Get.back();
        Utils.toastMessage('User has not been created');
        //error-occured - display error message
      }
    }
  }
}
