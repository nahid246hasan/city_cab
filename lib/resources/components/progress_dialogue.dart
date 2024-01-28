import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ProgreessDialogue extends StatelessWidget {
  String msg;

  ProgreessDialogue({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Get.back();
      },
      child: Dialog(
        backgroundColor: Colors.yellow,
        shape: Border.all(
          style: BorderStyle.solid
        ),
        child: Container(
          margin: const EdgeInsets.all(15),
          width: double.infinity,
          height: MediaQuery.of(context).size.height / 4,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 6.0,
                    ),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                    SizedBox(
                      width: 26,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  msg,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10.0,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
