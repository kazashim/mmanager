import 'package:flutter/material.dart';

import 'package:get/get.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:mmanager/core/xcontroller.dart';
import 'package:mmanager/main.dart';
import 'package:mmanager/widgets/monthly_detail.dart';
import 'package:mmanager/widgets/three_months_detail.dart';
import 'package:mmanager/widgets/weekly_detail.dart';

class ExpenseScreen extends StatelessWidget {
  final indexSelected = 0.obs;

  ExpenseScreen() {
    final XController x = XController.to;
    x.setThisMonthOnly(true);
    x.setFirstThreeMonthDetail();
    x.setThisWeek(true);
  }

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
          backgroundColor: backgroundColor,
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
            backgroundColor: backgroundColor,
            // Here we take the value from the MyExpenseScreen object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text("Expense",
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w800)),
          ),
          body: Container(
            width: Get.width,
            height: Get.height,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  overviewReport(),
                  Obx(() => createWidgetList(x, indexSelected.value)),
                  SizedBox(height: 80),
                ],
              ),
            ),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ),
      ),
    );
  }

  Widget createWidgetList(final XController x, final int index) {
    switch (index) {
      case 0:
        return WeeklyDetailWidget(item: {
          "expense": "1",
          "date": x.itemWeek.value.first!.microsecondsSinceEpoch
        });
      case 1:
        return MonthlyDetailWidget(item: {
          "expense": "1",
          "month": x.itemMonth.value.first!.millisecondsSinceEpoch
        });
      case 2:
        return ThreeMonthsDetailWidget(item: {
          "expense": "1",
          "date": x.itemThreeMonth.value.first!.millisecondsSinceEpoch
        });
      default:
        return WeeklyDetailWidget(item: null);
    }
  }

  final EdgeInsets edgeInsets =
      EdgeInsets.symmetric(horizontal: 20, vertical: 15);

  final List<String> overviews = [
    "Weekly",
    "Monthly",
    "3 Months",
    //"6 Months",
    //"Yearly"
  ];

  Widget overviewReport() {
    return Container(
      width: Get.width,
      height: 50,
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.only(top: 10, left: 20, right: 20),
      //margin: edgeInsets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              alignment: Alignment.center,
              child: ListView.builder(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Obx(
                    () => InkWell(
                      onTap: () {
                        indexSelected.value = index;
                      },
                      child: Container(
                        //height: 55,
                        //width: 55,
                        margin:
                            EdgeInsets.only(right: Get.width / 27, bottom: 5),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        decoration: BoxDecoration(
                          boxShadow: [
                            if (index == indexSelected.value)
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                //spreadRadius: 0,
                                blurRadius: 5,
                                offset: Offset(0.5, 1.5),
                                // changes position of shadow
                              ),
                          ],
                          borderRadius: BorderRadius.circular(10),
                          color: index == indexSelected.value
                              ? Colors.white
                              : lightColor,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (index == indexSelected.value)
                              CircleAvatar(
                                backgroundColor: mainColor,
                                radius: 3,
                              ),
                            if (index == indexSelected.value)
                              SizedBox(width: 5),
                            Text(
                              "${overviews[index]}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize:
                                      index == indexSelected.value ? 15 : 14,
                                  fontWeight: index == indexSelected.value
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: index == indexSelected.value
                                      ? Colors.black
                                      : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                itemCount: overviews.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
