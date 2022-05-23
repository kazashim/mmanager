import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mmanager/apps/home_page.dart';
import 'package:mmanager/core/xcontroller.dart';
import 'package:mmanager/main.dart';
import 'package:mmanager/utils/strings.dart';

class IntroScreen extends StatelessWidget {
  final bool? isBack;
  IntroScreen({this.isBack});

  final int totalPages = IntroItems.loadOnboardItem().length;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: Get.height,
      color: mainColor,
      child: SafeArea(
        top: true,
        bottom: false,
        child: Scaffold(
          backgroundColor: Color(0xfff9f9f9),
          body: PageView.builder(
              itemCount: totalPages,
              itemBuilder: (context, index) {
                IntroItem oi = IntroItems.loadOnboardItem()[index];
                return Container(
                  width: Get.width,
                  height: Get.height,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: Dimensions.heightSize * 4,
                            bottom: Dimensions.heightSize * 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: Get.width,
                              height: 200,
                              child: Image.asset(
                                oi.image!,
                                fit: BoxFit.fitHeight,
                                width: Get.width,
                                height: 200,
                              ),
                            ),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: Dimensions.marginSize * 2.5,
                                      right: Dimensions.marginSize * 2.5),
                                  child: Text(
                                    oi.title!,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            Dimensions.extraLargeTextSize * 1.5,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: Dimensions.marginSize * 2,
                                      right: Dimensions.marginSize * 2),
                                  child: Text(
                                    oi.subTitle!,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            Dimensions.extraLargeTextSize),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: Get.width,
                              child: Align(
                                alignment: Alignment.center,
                                child: index != (totalPages - 1)
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(left: 40.0),
                                        child: Container(
                                          width: 100.0,
                                          height: 12.0,
                                          child: ListView.builder(
                                            itemCount: totalPages,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, i) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: Container(
                                                  width: index == i ? 30 : 20.0,
                                                  decoration: BoxDecoration(
                                                      color: index == i
                                                          ? mainColor
                                                          : lightColor,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5.0))),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      )
                                    : GestureDetector(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                            height: 50,
                                            width: 200,
                                            decoration: BoxDecoration(
                                                color: mainColor,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(
                                                        Dimensions.radius *
                                                            0.5))),
                                            child: Center(
                                              child: Text(
                                                (this.isBack != null &&
                                                        this.isBack!)
                                                    ? "CLOSE"
                                                    : Strings.getStarted
                                                        .toUpperCase(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: Dimensions
                                                        .largeTextSize,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          if (this.isBack != null &&
                                              this.isBack!) {
                                            Get.back();
                                          } else {
                                            XController.to.setFirstLoad(false);
                                            Get.offAll(HomePage());
                                          }
                                        },
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      /*Positioned(
                    bottom: -20,
                    right: 10,
                    child: Image.asset(oi.subImage!),
                  )*/
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }
}

class IntroItem {
  final String? title;
  final String? subTitle;
  final String? image;
  final String? subImage;

  const IntroItem({this.title, this.subTitle, this.image, this.subImage});
}

class IntroItems {
  static List<IntroItem> loadOnboardItem() {
    const fi = <IntroItem>[
      IntroItem(
        title: Strings.title1,
        subTitle: Strings.subTitle1,
        image: 'assets/finance2.png',
        subImage: 'assets/appstore100.png',
      ),
      IntroItem(
        title: Strings.title2,
        subTitle: Strings.subTitle2,
        image: 'assets/graph2.png',
        subImage: 'assets/appstore100.png',
      ),
      IntroItem(
        title: Strings.title3,
        subTitle: Strings.subTitle3,
        image: 'assets/overview2.png',
        subImage: 'assets/appstore100.png',
      ),
    ];
    return fi;
  }
}

class Dimensions {
  static double defaultTextSize = 14.00;
  static double smallTextSize = 12.00;
  static double extraSmallTextSize = 10.00;
  static double largeTextSize = 16.00;
  static double extraLargeTextSize = 20.00;

  static const double defaultPaddingSize = 30.00;
  static const double marginSize = 20.00;
  static const double heightSize = 12.00;
  static const double widthSize = 10.00;
  static const double radius = 10.00;
  static const double buttonHeight = 60.00;

  static double latitude = 38.9647;
  static double longitude = 35.2233;
}
