import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:mmanager/core/xcontroller.dart';
import 'package:mmanager/main.dart';
import 'package:mmanager/screens/intro_screen.dart';
import 'package:mmanager/screens/register_screen.dart';
import 'package:mmanager/utils/colors.dart';
import 'package:mmanager/utils/custom_style.dart';
import 'package:mmanager/utils/strings.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final XController x = XController.to;

    return Container(
      width: Get.width,
      height: Get.height,
      color: Color(0xfff5f6fa),
      child: SafeArea(
        bottom: false,
        top: false,
        child: Scaffold(
          backgroundColor: Color(0xfff5f6fa),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(FeatherIcons.chevronLeft,
                  size: 32, color: Colors.black54),
              onPressed: () {
                Get.back();
              },
            ),
            elevation: 0.25,
            backgroundColor: Color(0xfff5f6fa),
            title: Text(
              "LOGIN",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: Container(
            width: Get.width,
            height: Get.height,
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: Get.width,
                        padding: EdgeInsets.only(right: 10),
                        child: Text("${x.dateNowApps.value}",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 11)),
                      ),
                      signInWidget(x),
                      SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ),
      ),
    );
  }

  final toggleVisibility = true.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  signInWidget(final XController x) {
    return Column(
      children: [
        Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: Dimensions.heightSize * 2,
                  left: Dimensions.marginSize,
                  right: Dimensions.marginSize),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Email",
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(
                    height: Dimensions.heightSize * 0.5,
                  ),
                  TextFormField(
                    //style: CustomStyle.textStyle,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return Strings.pleaseFillOutTheField;
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Input Email",
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      labelStyle: CustomStyle.textStyle,
                      filled: true,
                      fillColor: lightColor,
                      hintStyle: CustomStyle.textStyle,
                      focusedBorder: CustomStyle.focusBorder,
                      enabledBorder: CustomStyle.focusErrorBorder,
                      focusedErrorBorder: CustomStyle.focusErrorBorder,
                      errorBorder: CustomStyle.focusErrorBorder,
                      prefixIcon: Icon(FeatherIcons.mail),
                    ),
                  ),
                  SizedBox(
                    height: Dimensions.heightSize,
                  ),
                  Text(
                    "Password",
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(
                    height: Dimensions.heightSize * 0.5,
                  ),
                  Obx(
                    () => TextFormField(
                      style: CustomStyle.textStyle,
                      controller: passwordController,
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return Strings.pleaseFillOutTheField;
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: Strings.typePassword,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        labelStyle: CustomStyle.textStyle,
                        focusedBorder: CustomStyle.focusBorder,
                        enabledBorder: CustomStyle.focusErrorBorder,
                        focusedErrorBorder: CustomStyle.focusErrorBorder,
                        errorBorder: CustomStyle.focusErrorBorder,
                        filled: true,
                        fillColor: lightColor,
                        hintStyle: CustomStyle.textStyle,
                        prefixIcon: Icon(FeatherIcons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            toggleVisibility.value = !toggleVisibility.value;
                          },
                          icon: toggleVisibility.value
                              ? Icon(
                                  Icons.visibility_off,
                                  color: Colors.black,
                                )
                              : Icon(
                                  Icons.visibility,
                                  color: Colors.black,
                                ),
                        ),
                      ),
                      obscureText: toggleVisibility.value,
                    ),
                  ),
                  SizedBox(height: Dimensions.heightSize),
                ],
              ),
            )),
        Container(
          margin: EdgeInsets.symmetric(
              horizontal: Dimensions.marginSize, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox.shrink(),
              GestureDetector(
                child: Text(
                  Strings.forgotPassword,
                  style: CustomStyle.textStyle,
                ),
                onTap: () {
                  //MyDialog.forgotPassword(context);
                  EasyLoading.showToast("Forgot password...");
                },
              ),
            ],
          ),
        ),
        SizedBox(height: Dimensions.heightSize * 2),
        Padding(
          padding: const EdgeInsets.only(
              left: Dimensions.marginSize, right: Dimensions.marginSize),
          child: GestureDetector(
            child: Container(
              height: 50.0,
              width: Get.width,
              decoration: BoxDecoration(
                  color: CustomColor.primaryColor,
                  borderRadius:
                      BorderRadius.all(Radius.circular(Dimensions.radius))),
              child: Center(
                child: Text(
                  Strings.signInAccount.toUpperCase(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: Dimensions.largeTextSize,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            onTap: () async {
              String em = emailController.text;
              String ps = passwordController.text;
              if (em.length < 3) {
                EasyLoading.showToast("Email invalid...");
                return;
              }

              if (ps.length < 3) {
                EasyLoading.showToast("Password invalid...");
                return;
              }

              EasyLoading.show(status: 'Loading...');
              await Future.delayed(Duration(milliseconds: 1200), () async {
                await x.pushLogin(em.trim(), ps.trim());
                EasyLoading.dismiss();

                Future.delayed(Duration(milliseconds: 900), () async {
                  dynamic member = x.userLogin;
                  //print(member);
                  if (member['id_install'] != '' &&
                      member['is_member'] == '1' &&
                      member['is_login'] == '1') {
                    x.getHome();
                    Get.back();
                    EasyLoading.showSuccess(
                        'Login successful...\nWelcome back ${member['fullname']}');
                  }
                });
              });
            },
          ),
        ),
        SizedBox(height: Dimensions.heightSize * 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Strings.ifYouHaveNoAccount,
              style: CustomStyle.textStyle,
            ),
            GestureDetector(
              child: Text(
                Strings.signUp.toUpperCase(),
                style: TextStyle(
                    color: CustomColor.primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              onTap: () {
                //register
                Get.back();
                Get.to(RegisterScreen());
              },
            )
          ],
        )
      ],
    );
  }
}
