import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mmanager/main.dart';
import 'package:mmanager/screens/intro_screen.dart';
import 'package:mmanager/screens/login_screen.dart';
import 'package:mmanager/screens/register_screen.dart';
import 'package:mmanager/utils/strings.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Get.height,
        width: Get.width,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
              mainColor,
              mainColor,
              mainColor,
              softMainColor,
            ])),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/appstore165.png',
              fit: BoxFit.cover,
              height: 95,
              width: 95,
            ),
            SizedBox(height: Dimensions.heightSize),
            Padding(
              padding: const EdgeInsets.only(
                  left: Dimensions.marginSize * 2,
                  right: Dimensions.marginSize * 2),
              child: Text(
                Strings.appName,
                style: TextStyle(
                    fontSize: Dimensions.largeTextSize * 1.5,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: Dimensions.heightSize * 6,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: Dimensions.marginSize * 2,
                  right: Dimensions.marginSize * 2),
              child: GestureDetector(
                child: Container(
                  height: Dimensions.buttonHeight,
                  width: Get.width,
                  decoration: BoxDecoration(
                      color: lightColor,
                      borderRadius: BorderRadius.circular(Dimensions.radius)),
                  child: Center(
                    child: Text(
                      Strings.signIn.toUpperCase(),
                      style: TextStyle(
                          fontSize: Dimensions.extraLargeTextSize,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                onTap: () {
                  Get.back();
                  Get.to(LoginScreen());
                },
              ),
            ),
            SizedBox(
              height: Dimensions.heightSize,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: Dimensions.marginSize * 2,
                  right: Dimensions.marginSize * 2),
              child: GestureDetector(
                child: Container(
                  height: Dimensions.buttonHeight,
                  width: Get.width,
                  decoration: BoxDecoration(
                      color: lightColor,
                      borderRadius: BorderRadius.circular(Dimensions.radius)),
                  child: Center(
                    child: Text(
                      Strings.signUp.toUpperCase(),
                      style: TextStyle(
                          fontSize: Dimensions.extraLargeTextSize,
                          color: mainColor,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                onTap: () {
                  Get.back();
                  Get.to(RegisterScreen());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
