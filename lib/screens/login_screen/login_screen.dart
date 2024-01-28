import 'dart:math';

import 'package:city_cab/resources/routes/routes_name.dart';
import 'package:city_cab/utils/utils.dart';
import 'package:city_cab/view_model/controller/login_view_model/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  LoginViewModel loginViewModel=Get.put(LoginViewModel());
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
                "Login as Rider",
                style: TextStyle(fontSize: 24, fontFamily: "Brand Bold"),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    TextFormField(
                      controller: loginViewModel.emailController.value,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 10)),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(
                      height: 1,
                    ),
                    TextFormField(
                      controller: loginViewModel.passwordController.value,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 10)),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        textStyle: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        loginViewModel.login(context);
                      },
                      child: Container(
                        height: 50,
                        child: const Center(
                          child: Text(
                            "Login",
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
                  Get.toNamed(RoutesName.registrationScreen);
                },
                child: const Text("Don't have an account? Register Here."),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
