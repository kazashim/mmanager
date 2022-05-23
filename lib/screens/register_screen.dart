import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:mmanager/core/xcontroller.dart';
import 'package:mmanager/main.dart';
import 'package:mmanager/screens/intro_screen.dart';
import 'package:mmanager/screens/login_screen.dart';
import 'package:mmanager/utils/colors.dart';
import 'package:mmanager/utils/custom_style.dart';
import 'package:mmanager/utils/strings.dart';

class RegisterScreen extends StatelessWidget {
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
            // Here we take the value from the MyRegisterScreen object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(
              Strings.signUp.toUpperCase(),
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
                      signUpWidget(x),
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
  final retoggleVisibility = true.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController repasswordController = TextEditingController();

  signUpWidget(final XController x) {
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
                    "Fullname",
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(
                    height: Dimensions.heightSize * 0.5,
                  ),
                  TextFormField(
                    style: CustomStyle.textStyle,
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return Strings.pleaseFillOutTheField;
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Input Fullname",
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
                      prefixIcon: Icon(FeatherIcons.user),
                    ),
                  ),
                  SizedBox(
                    height: Dimensions.heightSize,
                  ),
                  Text(
                    "Email",
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(
                    height: Dimensions.heightSize * 0.5,
                  ),
                  TextFormField(
                    style: CustomStyle.textStyle,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return Strings.pleaseFillOutTheField;
                      } else if (!XController.isValidEmail(value)) {
                        return "Email invalid!";
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
                  SizedBox(
                    height: Dimensions.heightSize,
                  ),
                  Text(
                    "Re-Password",
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(
                    height: Dimensions.heightSize * 0.5,
                  ),
                  Obx(
                    () => TextFormField(
                      style: CustomStyle.textStyle,
                      controller: repasswordController,
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return Strings.pleaseFillOutTheField;
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: Strings.typeRePassword,
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
                            retoggleVisibility.value =
                                !retoggleVisibility.value;
                          },
                          icon: retoggleVisibility.value
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
                      obscureText: retoggleVisibility.value,
                    ),
                  ),
                  SizedBox(height: Dimensions.heightSize),
                ],
              ),
            )),
        SizedBox(height: Dimensions.heightSize),
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
                  Strings.createAccount.toUpperCase(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: Dimensions.largeTextSize,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            onTap: () async {
              String nm = nameController.text;
              String re = repasswordController.text;
              String em = emailController.text;
              String ps = passwordController.text;

              if (nm.length < 3) {
                EasyLoading.showToast("Fullname invalid...");
                return;
              }

              if (em.length < 3 || !XController.isValidEmail(em)) {
                EasyLoading.showToast("Email invalid...");
                return;
              }

              if (ps.length < 3) {
                EasyLoading.showToast("Password invalid...");
                return;
              }

              if (re.length < 3) {
                EasyLoading.showToast("Re-Password invalid...");
                return;
              }

              if (re != ps) {
                EasyLoading.showToast("Password & Re-Password invalid...");
                return;
              }

              EasyLoading.show(status: 'Loading...');
              await Future.delayed(Duration(milliseconds: 1200), () async {
                await x.pushRegister(nm.trim(), em.trim(), ps.trim());
                EasyLoading.dismiss();

                Future.delayed(Duration(milliseconds: 900), () async {
                  dynamic member = x.userLogin;
                  if (member['id_install'] != '' &&
                      member['is_member'] == '1' &&
                      member['is_login'] == '1') {
                    x.getHome();
                    Get.back();
                    EasyLoading.showSuccess(
                        'Process successful...\nWelcome ${member['fullname']}');
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
              Strings.ifYouHaveAccount,
              style: CustomStyle.textStyle,
            ),
            GestureDetector(
              child: Text(
                Strings.signIn.toUpperCase(),
                style: TextStyle(
                    color: CustomColor.primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              onTap: () {
                //signup
                Get.back();
                Get.to(LoginScreen());
              },
            )
          ],
        )
      ],
    );
  }
}
