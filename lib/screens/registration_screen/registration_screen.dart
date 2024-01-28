import 'package:city_cab/main.dart';
import 'package:city_cab/resources/routes/routes_name.dart';
import 'package:city_cab/view_model/controller/registration_view_model/registration_view_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class RegistrationScreen extends StatelessWidget {
  RegistrationScreen({super.key});

  final registrationViewModel = Get.put(RegistrationViewModel());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 45,
              ),
              const Image(
                image: AssetImage("assets/images/logo.png"),
                width: 390,
                height: 250,
                alignment: Alignment.center,
              ),
              const SizedBox(
                height: 15.0,
              ),
              const Text(
                "Register as Rider",
                style: TextStyle(fontSize: 24, fontFamily: "Brand Bold"),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 1,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: registrationViewModel.nameController.value,
                      decoration: const InputDecoration(
                          labelText: "Name",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10)),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    TextFormField(
                      controller: registrationViewModel.emailController.value,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10)),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    TextFormField(
                      controller: registrationViewModel.phoneController.value,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                          labelText: "Phone",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10)),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    TextFormField(
                      controller:
                          registrationViewModel.passwordController.value,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10)),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.yellow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        textStyle: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        registrationViewModel.registration(context);
                        // if(registrationViewModel.nameController.value.text.length<4){
                        //   displayToast("Must be atleast 3 Charecters", context);
                        // }
                        // else if(!registrationViewModel.emailController.value.text.contains('@')){
                        //   displayToast("Email address is not valid", context);
                        // }
                        // else if(registrationViewModel.phoneController.value.text.isEmpty){
                        //   displayToast("Phone number is required", context);
                        // }
                        // else if(registrationViewModel.passwordController.value.text.length<6){
                        //   displayToast("Password must be at least 6 charecter", context);
                        // }
                        // else{
                        //   registerNewUser(context);
                        // }
                      },
                      child: Container(
                        height: 50,
                        child: const Center(
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "Brand Bold",
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.toNamed(RoutesName.loginScreen);
                },
                child: const Text("Already have an account? Login Here."),
              ),
            ],
          ),
        ),
      ),
    );
  }
  //
  // final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  //
  // registerNewUser(BuildContext context) async {
  //   var firebaseUser =
  //       (await firebaseAuth.createUserWithEmailAndPassword(
  //           email: registrationViewModel.emailController.value.text,
  //           password: registrationViewModel.passwordController.value.text).catchError((error, stackTrace){
  //             displayToast("Error: $error", context);
  //       })).user;
  //   if(firebaseUser!=null){//user created
  //
  //     Map userDataMap={
  //       "name":registrationViewModel.nameController.value.text,
  //       "email": registrationViewModel.emailController.value.text,
  //       "phone": registrationViewModel.phoneController.value.text,
  //       "password": registrationViewModel.passwordController.value.text
  //     };
  //
  //     userRef.child(firebaseUser.uid).set(userDataMap);
  //
  //     displayToast("Successfully registered", context);
  //     Get.back();
  //     //save User into realtime database
  //   }
  //   else{
  //     displayToast('User has not been created', context);
  //     //error-occured - display error message
  //   }
  // }
  // displayToast(String msg,BuildContext buildContext){
  //   Fluttertoast.showToast(msg: msg);
  // }
}
