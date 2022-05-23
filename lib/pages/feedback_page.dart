import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:mmanager/core/xcontroller.dart';
import 'package:mmanager/main.dart';

class FeedbackPage extends StatelessWidget {
  final TextEditingController _deController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final XController x = Get.find<XController>();
    var thisRating = 5.0;

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
              "Feedback",
              style:
                  TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 0.25,
          ),
          body: Container(
            height: Get.height,
            width: Get.width,
            color: backgroundColor,
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    child: Text(
                      "Your genius feedback",
                      textAlign: TextAlign.center,
                      style: Get.theme.textTheme.headline6,
                    ),
                  ),
                  Container(
                    child: Text(
                      "Follow on Twitter @MManager2021",
                      textAlign: TextAlign.center,
                      style:
                          Get.theme.textTheme.headline6!.copyWith(fontSize: 14),
                    ),
                  ),
                  Container(
                    child: Text(
                      "Telegram @rullyhasibuan",
                      textAlign: TextAlign.center,
                      style:
                          Get.theme.textTheme.headline6!.copyWith(fontSize: 14),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: RatingBar.builder(
                      initialRating: 5,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        //print(rating);
                        thisRating = rating;
                        print(thisRating);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    child: TextField(
                        controller: _deController,
                        enabled: true,
                        maxLines: 5,
                        maxLength: 150,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          //fontFamily: 'Mukta',
                        ),
                        //keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Describe your feedback',
                          hintStyle: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  print("submitted");
                                  String ds = _deController.text;
                                  if (ds.isEmpty) {
                                    EasyLoading.showError("Comment invalid...");
                                    return;
                                  }
                                  EasyLoading.show(status: "Loading...");
                                  var dataPush = {
                                    "tx": ds,
                                    "id": x.userLogin['id_install'],
                                    "rt": thisRating
                                  };
                                  //print(dataPush);
                                  //return;

                                  await Future.delayed(
                                      Duration(milliseconds: 1200));
                                  await x.pushResponse("feedback/send_feedback",
                                      jsonEncode(dataPush));

                                  await Future.delayed(
                                      Duration(milliseconds: 1200), () {
                                    EasyLoading.showSuccess(
                                        "Thanks you for your comment....");
                                    Get.back();
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Get.theme.buttonColor
                                            .withOpacity(0.2),
                                        blurRadius: 1.0,
                                        offset: Offset(0.0, 6),
                                      )
                                    ],
                                    color:
                                        Get.theme.accentColor.withOpacity(.8),
                                    //Theme.of(context).bottomAppBarColor,
                                    borderRadius: BorderRadius.circular(42),
                                  ),
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.symmetric(horizontal: 15),
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 18),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 2, right: 5),
                                          child: Icon(FeatherIcons.check,
                                              size: 16, color: Colors.white),
                                        ),
                                        Text(
                                          "Submit",
                                          style: Get.theme.textTheme.subtitle2!
                                              .copyWith(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
