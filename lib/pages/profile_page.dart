import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:mmanager/apps/home_page.dart';
import 'package:mmanager/core/xcontroller.dart';
import 'package:mmanager/main.dart';
import 'package:mmanager/screens/intro_screen.dart';
import 'package:mmanager/utils/custom_style.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final XController x = XController.to;
    return Container(
      width: Get.width,
      height: Get.height,
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        top: false,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: backgroundColor,
            iconTheme: IconThemeData(color: Colors.black87),
            title: Text(
              'Profile',
              style:
                  TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 0.25,
          ),
          body: SingleChildScrollView(
            child: Container(
              color: backgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: Dimensions.heightSize * 3,
                  ),
                  Obx(
                    () => profileWidget(x.userLogin),
                  ),
                  SizedBox(
                    height: Dimensions.heightSize * 2,
                  ),
                  detailsWidget(x, x.userLogin)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  profileWidget(final dynamic user) {
    //print(member);
    dynamic member = {};
    if (user != null) member = user;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(60.0),
          child: member['photo'] != null && member['photo'] != ''
              ? InkWell(
                  onTap: () {
                    Get.dialog(XController.photoView(member['photo']));
                  },
                  child: Image.network(
                    member['photo'],
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  "assets/icondef.png",
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "${member['fullname'] != '' ? member['fullname'] : 'Hallo User'}",
          style: TextStyle(
              fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        Text(
          "${member['email'] != '' ? member['email'] : XController.APP_NAME}",
          style: CustomStyle.textStyle,
        ),
        SizedBox(
          height: 1 * 0.5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: Get.width / 1.4,
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "${member['phone'] != '' ? member['phone'] : ''}",
                textAlign: TextAlign.center,
                style: CustomStyle.textStyle.copyWith(fontSize: 12),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }

  final TextEditingController nameController = TextEditingController();
  changeName(final XController x, final String nm) {
    nameController.text = nm;
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return Dialog(
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            height: 200.0,
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Update Fullname",
                  style: TextStyle(
                    fontSize: 21.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextField(
                  controller: nameController,
                  keyboardType: TextInputType.name,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Input Fullname',
                    hintStyle: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        width: Get.width / 3.5,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        String name = nameController.text.trim();
                        if (name == '' || name.length < 3) {
                          EasyLoading.showError("Fullname invalid...");
                          return;
                        }

                        Get.back();
                        EasyLoading.showToast("Loading...");
                        await Future.delayed(Duration(milliseconds: 1200),
                            () async {
                          EasyLoading.dismiss();
                          await x.pushUpdateName(name);

                          Future.delayed(Duration(milliseconds: 1200), () {
                            EasyLoading.showToast("Process success...");
                            //Get.back();
                          });
                        });
                      },
                      child: Container(
                        width: Get.width / 3.5,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Get.theme.accentColor,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          'Process',
                          style: TextStyle(
                            //fontFamily: 'Mukta',
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  final TextEditingController passController = TextEditingController();
  final TextEditingController newpassController = TextEditingController();
  final TextEditingController renewpassController = TextEditingController();
  changePassword(final XController x) {
    dynamic member = x.userLogin;
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return Dialog(
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            height: Get.height / 2.2,
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Change Password",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "* strong password required",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                ),
                TextField(
                  controller: passController,
                  obscureText: true,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Old Password',
                    hintStyle: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.heightSize),
                TextField(
                  controller: newpassController,
                  obscureText: true,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'New Password',
                    hintStyle: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.heightSize),
                TextField(
                  controller: renewpassController,
                  obscureText: true,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Retype New Password',
                    hintStyle: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        width: Get.width / 3.5,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        String oldpass = passController.text.trim();
                        String newpass = newpassController.text.trim();
                        String renewpass = renewpassController.text.trim();

                        if (oldpass == '' || oldpass.length < 6) {
                          EasyLoading.showError(
                              "Old Password invalid... min 6 alphanumeric.");
                          return;
                        }

                        if (newpass == '' || newpass.length < 6) {
                          EasyLoading.showError(
                              "New Password invalid... min 6 alphanumeric.");
                          return;
                        }

                        if (renewpass == '' || renewpass.length < 6) {
                          EasyLoading.showError(
                              "Re-New Password invalid... min 6 alphanumeric.");
                          return;
                        }

                        if (renewpass != newpass) {
                          EasyLoading.showError(
                              "New & Re-New Password invalid... not equal.");
                          return;
                        }

                        if (oldpass != member['real_pwd']) {
                          EasyLoading.showError("Old Password is wrong!");
                          return;
                        }

                        Get.back();
                        EasyLoading.showToast("Loading...");
                        await Future.delayed(Duration(milliseconds: 1200),
                            () async {
                          EasyLoading.dismiss();
                          await x.pushUpdatePassword(newpass);

                          Future.delayed(Duration(milliseconds: 1200), () {
                            EasyLoading.showToast("Process success...");
                            //Get.back();
                          });
                        });
                      },
                      child: Container(
                        width: Get.width / 3.5,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Get.theme.accentColor,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          'Process',
                          style: TextStyle(
                            //fontFamily: 'Mukta',
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  detailsWidget(final XController x, final dynamic user) {
    double iconSize = 22;
    double arrowSize = 20;
    double fontSize = 16;

    dynamic member = {};
    if (user != null) member = user;

    EdgeInsets paddingSize =
        const EdgeInsets.only(left: 10 * 1.5, right: 10 * 1.5);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.widthSize * 2),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              changeName(x, member['fullname']);
            },
            child: Container(
              height: 60.0,
              decoration: BoxDecoration(
                  color: lightColor, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: paddingSize,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          FeatherIcons.user,
                          color: Colors.grey,
                          size: iconSize,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Change Fullname",
                          style: TextStyle(
                              fontSize: fontSize, color: Colors.black),
                        )
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios_sharp,
                      color: Colors.grey,
                      size: arrowSize,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          InkWell(
            onTap: () {
              chooseImage();
            },
            child: Container(
              height: 60.0,
              decoration: BoxDecoration(
                  color: lightColor, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: paddingSize,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          FeatherIcons.camera,
                          color: Colors.grey,
                          size: iconSize,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Change Photo",
                          style: TextStyle(
                              fontSize: fontSize, color: Colors.black),
                        )
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios_sharp,
                      color: Colors.grey,
                      size: arrowSize,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          InkWell(
            onTap: () {
              changePassword(x);
            },
            child: Container(
              height: 60.0,
              decoration: BoxDecoration(
                  color: lightColor, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: paddingSize,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          FeatherIcons.lock,
                          color: Colors.grey,
                          size: iconSize,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Change Password",
                          style: TextStyle(
                              fontSize: fontSize, color: Colors.black),
                        )
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios_sharp,
                      color: Colors.grey,
                      size: arrowSize,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          InkWell(
            onTap: () {
              HomePage.confirmLogout(x);
            },
            child: Container(
              height: 60.0,
              decoration: BoxDecoration(
                  color: lightColor, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: paddingSize,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          FeatherIcons.logOut,
                          color: Colors.grey,
                          size: iconSize,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Logout",
                          style: TextStyle(
                              fontSize: fontSize, color: Colors.black),
                        )
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios_sharp,
                      color: Colors.grey,
                      size: arrowSize,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  chooseImage() {
    showMaterialModalBottomSheet(
      context: Get.context!,
      isDismissible: true,
      builder: (context) => SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: Container(
          color: backgroundColor,
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              ListTile(
                onTap: () {
                  Get.back();
                  Future.delayed(Duration(milliseconds: 400), () {
                    pickImageSource(2);
                  });
                },
                title: Text("Camera"),
                leading: Icon(FeatherIcons.camera),
                trailing: Icon(FeatherIcons.chevronRight),
              ),
              Divider(),
              ListTile(
                onTap: () {
                  Get.back();
                  Future.delayed(Duration(milliseconds: 400), () {
                    pickImageSource(1);
                  });
                },
                title: Text("Gallery"),
                leading: Icon(FeatherIcons.image),
                trailing: Icon(FeatherIcons.chevronRight),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // additional photo uploader
  final picker = ImagePicker();
  pickImageSource(int tipe) {
    Future<PickedFile?>? file = picker.getImage(
        source: tipe == 1 ? ImageSource.gallery : ImageSource.camera);
    file.then((PickedFile? pickFile) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (pickFile != null) {
          _cropImage(File(pickFile.path));
        }
      });
    });
  }

  Future<Null> _cropImage(File? imageFile) async {
    File? croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile!.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.white,
            toolbarWidgetColor: Get.theme.accentColor,
            initAspectRatio: CropAspectRatioPreset
                .ratio3x2, //CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Crop Image',
        ));
    if (croppedFile != null) {
      File? tmpFile = croppedFile;
      String? base64Image = base64Encode(tmpFile.readAsBytesSync());
      startUpload(base64Image, tmpFile);
    }
  }

  startUpload(String? base64Image, File? tmpFile) {
    EasyLoading.show(status: 'Loading...');

    if (null == tmpFile) {
      EasyLoading.dismiss();
      EasyLoading.showError('Pick/Find another image');
      return;
    }
    String fileName = tmpFile.path.split('/').last;
    upload(base64Image!, fileName);
  }

  upload(String base64Image, String fileName) async {
    final XController x = XController.to;
    dynamic member = x.userLogin;
    String idUser = member['id_install'] ?? "";

    var dataPush = jsonEncode({
      "filename": fileName,
      "id": idUser,
      "image": base64Image,
    });

    //print(dataPush);
    var link = "upload/upload_photo?id=$idUser";
    //print(link);

    http
        .post(
          Uri.parse(XController.BASE_URL_API + link),
          body: dataPush,
        )
        .timeout(Duration(seconds: 250))
        .then((result) {
      //print(result.body);
      dynamic _result = jsonDecode(result.body);
      //print(_result);

      EasyLoading.dismiss();
      if (_result['code'] == '200') {
        EasyLoading.showSuccess("Process success...");
        Future.delayed(Duration(seconds: 1), () async {
          x.getHome();

          Future.delayed(Duration(seconds: 2), () async {});
        });
      } else {
        EasyLoading.showError("Process failed...");
      }
    }).catchError((error) {
      print(error);

      EasyLoading.dismiss();
    });
  }
}
