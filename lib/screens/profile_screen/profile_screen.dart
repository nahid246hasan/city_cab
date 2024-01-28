import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../resources/assets/image_assets.dart';
import '../../resources/routes/routes_name.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Image(
              image: AssetImage(ImageAssets.userIcon),
              height: 160,
              width: 160,
            ),
            const SizedBox(height: 10),
            const Text(
              "Nahid Hasan",
              style: TextStyle(
                  fontSize: 50,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Signatra'),
            ),
            const SizedBox(
              height: 20,
              width: 200,
              child: Divider(
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 40),
            InfoCard(
              text: "01738806985",
              icon: Icons.phone,
              onPressed: ()async{
                print("this is your phone number");
              },
            ),

            InfoCard(
              text: "nahid@gmail.com",
              icon: Icons.email,
              onPressed: ()async{
                print("this is your email");
              },
            ),
            GestureDetector(
              onTap: (){
                FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(context, RoutesName.loginScreen, (route) => false);
              },
              child: const Card(
                color: Colors.red,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 110),
                child: ListTile(
                  trailing: Icon(
                    Icons.follow_the_signs_outlined,
                    color: Colors.white,
                  ),
                  title: Text(
                    "Sign Out",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Brand-Bold',
                    ),
                  ),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String text;
  final IconData icon;

  Function onPressed;

  InfoCard(
      {super.key,
        required this.text,
        required this.icon,
        required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.black87,
          ),
          title: Text(
            text,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontFamily: 'Brand-Bold',
            ),
          ),
        ),
      ),
    );
  }
}
