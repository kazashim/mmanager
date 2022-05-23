import 'dart:async';

import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:get/get.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:mmanager/core/xcontroller.dart';
import 'package:mmanager/main.dart';
import 'package:mmanager/model/model_constant.dart';
import 'package:mmanager/pages/feedback_page.dart';
import 'package:mmanager/pages/profile_page.dart';
import 'package:mmanager/screens/account_screen.dart';
import 'package:mmanager/screens/add_income_screen.dart';
import 'package:mmanager/screens/add_new_screen.dart';
import 'package:mmanager/screens/intro_screen.dart';
import 'package:mmanager/widgets/amount_income.dart';
import 'package:mmanager/widgets/customtoggleswitch.dart';
import 'package:mmanager/widgets/monthly.dart';
import 'package:mmanager/widgets/three_months.dart';
import 'package:mmanager/widgets/weekly.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ItemModel {
  String title;
  IconData icon;
  ItemModel(this.title, this.icon);
}

class HomePage extends StatelessWidget {
  final indexTab = 0.obs;
  final showFirst = false.obs;

  HomePage() {
    refresh();
    statusCurrency.value = XController.to.defCurrency.value == 'IDR';
  }

  Future<void> refreshAsync() async {
    final XController x = XController.to;
    x.getHome();
    return refreshMain();
  }

  Future<void> refreshMain() async {
    final XController x = XController.to;
    final firstWeek = x.itemWeek.value.first!.millisecondsSinceEpoch;
    final endWeek = x.itemWeek.value.last!.millisecondsSinceEpoch;
    String? paramDate =
        " AND $columnCreated>=$firstWeek AND $columnCreated<=$endWeek ";
    if (indexTab.value == 2) {
      paramDate = x.getStringParamThreeMonth(0);
    }

    int indexVal = indexMain.value - 1;
    x.getSummaryIncomeExpense(
        categ: indexVal,
        paramDate: paramDate,
        isMonth: indexTab.value == 1 ? true : false,
        paramMonth: indexTab.value == 1 ? "${x.itemMonth.value.month}" : null);

    return refresh();
  }

  Future<void> refresh() async {
    //print("on refresh....");

    showFirst.value = true;
    Future.delayed(Duration(milliseconds: 2700), () async {
      //print("categ: ${indexMain.value} indexTab selected: ${indexTab.value}");
      showFirst.value = false;
      if (indexMain.value > 0) {
        XController.to.showFirst.value = true;
        final XController x = XController.to;

        final firstWeek = x.itemWeek.value.first!.millisecondsSinceEpoch;
        final endWeek = x.itemWeek.value.last!.millisecondsSinceEpoch;
        String? paramDate =
            " AND $columnCreated>=$firstWeek AND $columnCreated<=$endWeek ";
        if (indexTab.value == 2) {
          paramDate = x.getStringParamThreeMonth(-1);
        }

        int indexVal = indexMain.value - 1;

        await x.getSummaryIncomeByCateg(
            categ: indexVal,
            paramDate: paramDate,
            isMonth: indexTab.value == 1 ? true : false,
            paramMonth:
                indexTab.value == 1 ? "${x.itemMonth.value.month}" : null);

        showFirst.value = false;
      } else {
        showFirst.value = false;
      }
    });

    await Future.delayed(Duration(seconds: 1));
    return Future.value(true);
  }

  onClickItemToRefresh() async {
    //await Future.delayed(Duration(seconds: 3));
    //if (indexMain.value == 0)
    refreshMain();
    //else
    //  refresh();
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final XController x = XController.to;

    return WillPopScope(
      onWillPop: () => onBackPress(),
      child: Container(
        width: Get.width,
        height: Get.height,
        color: backgroundColor,
        child: SafeArea(
          bottom: false,
          top: false,
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: backgroundColor,
            appBar: AppBar(
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.menu, color: Colors.black87),
                onPressed: () {
                  //Get.to(ManagerListPage());
                  if (scaffoldKey.currentState!.isDrawerOpen) {
                    scaffoldKey.currentState!.openEndDrawer();
                  } else {
                    scaffoldKey.currentState!.openDrawer();
                  }
                },
              ),
              actions: [
                Obx(
                  () => createIconTopProfile(x, x.userLogin),
                )
              ],
              elevation: 0.25,
              backgroundColor: backgroundColor,
              // Here we take the value from the MyHomePage object that was created by
              // the App.build method, and use it to set our appbar title.
              title: Text(XController.APP_NAME,
                  style: TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.w800)),
            ),
            drawer: Obx(
              () => createDrawer(x, x.userLogin),
            ),
            body: Container(
              width: Get.width,
              height: Get.height,
              child: RefreshIndicator(
                onRefresh: refreshAsync,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //top container
                      mainSaving(x),

                      overviewReport(x),

                      Obx(
                        () => createWidgetList(indexTab.value, indexMain.value),
                      ),

                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: mainColor,
              onPressed: () async {
                //print("indexMain.value : ${indexMain.value}");
                x.setDatenowAppOnly();
                final callback = await Get.to(AddNewScreen());
                if (callback != null) {
                  onClickItemToRefresh();
                }
              },
              tooltip: 'Increment',
              child: Icon(Icons.add, size: 32),
            ), // This trailing comma makes auto-formatting nicer for build methods.
          ),
        ),
      ),
    );
  }

  createIconTopProfile(final XController x, final dynamic member) {
    return IconButton(
      icon: ClipRRect(
        borderRadius: BorderRadius.circular(60.0),
        child: member['is_member'] == '1' &&
                member['is_login'] == '1' &&
                member['photo'] != null &&
                member['photo'] != ''
            ? Image.network(
                member['photo'],
                height: 30,
                width: 30,
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/icondef.png',
              ),
      ),
      onPressed: () {
        actionToAccount(x, x.userLogin);
      },
    );
  }

  actionToAccount(final XController x, final dynamic user) {
    //print("actionToAccount");
    //print(user);
    if (user != null &&
        user['id_install'] != null &&
        user['is_member'] == '1' &&
        user['is_login'] == '1') {
      Get.to(ProfilePage());
    } else {
      showModalAccountScreen(x);
    }
  }

  Widget createDrawer(final XController x, final dynamic member) {
    //print("rebuild createDrawer... ");
    return Drawer(
      child: Container(
        color: backgroundColor,
        child: ListView(
          //portant: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: profileWidget(x, member),
              decoration: BoxDecoration(
                color: mainColor,
              ),
            ),
            ListTile(
              leading: Icon(
                FeatherIcons.dollarSign,
                color: Colors.black87,
              ),
              title: Text(
                "Currency",
                //style: CustomStyle.listStyle,
              ),
              onTap: () {
                Get.back();
                dialogSetCurrency(x);
              },
              trailing: Icon(FeatherIcons.chevronRight),
            ),
            Divider(),
            ListTile(
              leading: Icon(
                FeatherIcons.x,
                color: Colors.black87,
              ),
              title: Text(
                "Clear Database",
                //style: CustomStyle.listStyle,
              ),
              trailing: Icon(FeatherIcons.chevronRight),
              onTap: () {
                Get.back();
                confirmClearDatabase(x);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(
                FeatherIcons.sun,
                color: Colors.black87,
              ),
              title: Text(
                "Tutorial",
                //style: CustomStyle.listStyle,
              ),
              trailing: Icon(FeatherIcons.chevronRight),
              onTap: () {
                Get.back();
                Get.to(IntroScreen(isBack: true));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(
                FeatherIcons.share2,
                color: Colors.black87,
              ),
              title: Text(
                "Share",
                // style: CustomStyle.listStyle,
              ),
              trailing: Icon(FeatherIcons.chevronRight),
              onTap: () {
                Get.back();
                XController.shareContent(null);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(
                FeatherIcons.rss,
                color: Colors.black87,
              ),
              title: Text(
                "Feedback",
              ),
              onTap: () {
                Get.back();
                Get.to(FeedbackPage());
              },
              trailing: Icon(FeatherIcons.chevronRight),
            ),
            Divider(),
            ListTile(
              leading: Icon(
                FeatherIcons.uploadCloud,
                color: Colors.black87,
              ),
              title: Text(
                "Synchronize",
                // style: CustomStyle.listStyle,
              ),
              trailing: Icon(FeatherIcons.chevronRight),
              onTap: () {
                Get.back();
                EasyLoading.showToast("Synchronize...");
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(
                FeatherIcons.checkCircle,
                color: Colors.black87,
              ),
              title: Text(
                "v.${XController.APP_VERSION}",
                // style: CustomStyle.listStyle,
              ),
              trailing: Icon(FeatherIcons.chevronRight),
              onTap: () {
                Get.back();
                /*Get.to(InAppWebviewPage(
                    GetPlatform.isAndroid
                        ? "https://play.google.com/store/apps/developer?id=Erhacorpdotcom"
                        : "https://apps.apple.com/us/developer/rully-hasibuan/id1147962441",
                    "Erhacorpdotcom"));*/
              },
            ),
          ],
        ),
      ),
    );
  }

  static showModalAccountScreen(final XController x) {
    showCupertinoModalBottomSheet(
      expand: true,
      context: Get.context!,
      backgroundColor: Colors.transparent,
      barrierColor: backgroundColor,
      builder: (context) => Container(
        color: Colors.white,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 0,
              ),
              child: Container(child: AccountScreen()),
            ),
            Positioned(
              left: 5,
              top: 5,
              child: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(FeatherIcons.chevronDown,
                    size: 30, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  profileWidget(final XController x, final dynamic member) {
    //dynamic member = x.userLogin;
    //https://www.kindpng.com/picc/m/495-4952535_create-digital-profile-icon-blue-user-profile-icon.png
    return InkWell(
      onTap: () {
        Get.back();
        actionToAccount(x, member);
      },
      child: Padding(
        padding: const EdgeInsets.only(
          top: 5 * 3,
        ),
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(60.0),
            child: member['is_member'] == '1' &&
                    member['is_login'] == '1' &&
                    member['photo'] != null &&
                    member['photo'] != ''
                ? Image.network(
                    member['photo'],
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/icondef.png',
                  ),
          ),
          title: Text(
            "${(member['is_member'] == '1' && member['is_login'] == '1' && member['fullname'] != '') ? member['fullname'] : 'Hallo User'}",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.1),
          ),
          subtitle: Text(
            "${(member['is_member'] == '1' && member['is_login'] == '1' && member['email'] != '') ? member['email'] : XController.APP_NAME}",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  final statusCurrency = true.obs;
  dialogSetCurrency(final XController x) async {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
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
                  "Set Currency",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => Container(
                        width: Get.width / 4.5,
                        child: CustomToggleSwitch(
                          activeText: "IDR",
                          inactiveText: "USD",
                          inactiveColor: Colors.red[300],
                          activeTextColor: Colors.white,
                          inactiveTextColor: Colors.white,
                          activeColor: Colors.green[300],
                          value: statusCurrency.value,
                          onChanged: (value) {
                            print("VALUE : $value");
                            statusCurrency.value = value;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        width: (Get.width / 3.5),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
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
                        Get.back();

                        String currency = statusCurrency.value ? "ZMK" : "USD";
                        await x.setDefCurrency(currency);
                        EasyLoading.showToast("Updating currency..");
                        await Future.delayed(Duration(milliseconds: 1200));
                        refreshMain();
                      },
                      child: Container(
                        width: (Get.width / 3.5),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: mainColor,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          'Update',
                          style: TextStyle(
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

  final double maxTime = 5499;
  final timerLoading = 5499.obs;
  confirmClearDatabase(final XController x) async {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            height: 250.0,
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Obx(
                  () => timerLoading.value > 0 && timerLoading.value < maxTime
                      ? Text(
                          "Please wait...\nResetting Database...\n",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87),
                        )
                      : Text(
                          "Clear Database confirmation\nAre you sure to reset?\n",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87),
                        ),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Obx(
                  () => timerLoading.value > 0 && timerLoading.value < maxTime
                      ? Container(
                          margin: EdgeInsets.only(bottom: 20),
                          alignment: Alignment.center,
                          child: LinearPercentIndicator(
                            alignment: MainAxisAlignment.center,
                            width: 200.0,
                            lineHeight: 20.0,
                            percent: (timerLoading.value * 2) / 10000,
                            center: Text(
                              "${(timerLoading.value * 2) / 100}%",
                              style: new TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic),
                            ),
                            //trailing: Icon(Icons.close),
                            linearStrokeCap: LinearStrokeCap.butt,
                            backgroundColor: Colors.grey,
                            progressColor: mainColor,
                          ),
                        )
                      : SizedBox.shrink(),
                ),
                Obx(
                  () => timerLoading.value > 0 && timerLoading.value < maxTime
                      ? SizedBox.shrink()
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                Get.back();
                              },
                              child: Container(
                                width: (Get.width / 3.5),
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
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
                                //Get.back();
                                //await managerProvider.truncate(managerProvider.db!);
                                //EasyLoading.showToast("Clear database done...");
                                timerLoading.value = 1;
                                Timer.periodic(Duration(milliseconds: 1000),
                                    (timer) async {
                                  timerLoading.value = timerLoading.value + 999;
                                  if (timerLoading.value >= maxTime) {
                                    timer.cancel();

                                    await managerProvider
                                        .truncate(managerProvider.db!);
                                    EasyLoading.showToast(
                                        "Clear database done...");
                                    Get.back();

                                    await Future.delayed(
                                        Duration(milliseconds: 1200));
                                    refreshMain();
                                  }
                                });
                              },
                              child: Container(
                                width: (Get.width / 3.5),
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: mainColor,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Text(
                                  'Reset',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static confirmLogout(final XController x) async {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            height: 150.0,
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Are you sure to Logout?\n",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        width: (Get.width / 3.5),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
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
                        Get.back();
                        EasyLoading.showToast("Loading...");
                        await Future.delayed(Duration(milliseconds: 1200),
                            () async {
                          EasyLoading.dismiss();
                          await x.pushLogout();

                          Future.delayed(Duration(milliseconds: 1200), () {
                            EasyLoading.showToast("Logout success...");
                            Get.back();
                          });
                        });
                      },
                      child: Container(
                        width: (Get.width / 3.5),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: mainColor,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget createWidgetList(final int index, final int mainIndex) {
    //print("createWidgetList isShow $show");
    //
    int indexVal = mainIndex - 1;

    //print("createWidgetList indexVal $indexVal");

    switch (index) {
      case 0:
        return WeeklyWidget(
          item: {"categ": indexVal},
          callback: () {
            onClickItemToRefresh();
          },
        );
      case 1:
        return MonthlyWidget(
          item: {"categ": indexVal},
          callback: () {
            onClickItemToRefresh();
          },
        );
      case 2:
        //x.setFirstThreeMonth();
        //x.getStringParamThreeMonth(-1);

        return ThreeMonthsWidget(
          item: {"categ": indexVal},
          callback: () {
            onClickItemToRefresh();
          },
        );
      default:
        return WeeklyWidget(
          item: {"categ": indexVal},
          callback: () {
            onClickItemToRefresh();
          },
        );
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

  Widget overviewReport(final XController x) {
    return Container(
      width: Get.width,
      height: 80,
      padding: EdgeInsets.only(top: 10, left: 20, right: 20),
      //margin: edgeInsets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("Overview report",
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 15),
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
                        print("onclick row horizontal... index: $index");
                        indexTab.value = index;
                        showFirst.value = true;

                        if (index > 0) {
                          refresh();
                        }

                        if (index == 2) {
                          x.setFirstThreeMonth();
                        }

                        Future.delayed(Duration(milliseconds: 2500), () {
                          showFirst.value = false;
                        });
                      },
                      child: Container(
                        margin:
                            EdgeInsets.only(right: Get.width / 30, bottom: 5),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        decoration: BoxDecoration(
                          boxShadow: [
                            if (index == indexTab.value)
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                //spreadRadius: 0,
                                blurRadius: 5,
                                offset: Offset(0.5, 1.5),
                                // changes position of shadow
                              ),
                          ],
                          borderRadius: BorderRadius.circular(10),
                          color: index == indexTab.value
                              ? Colors.white
                              : lightColor,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (index == indexTab.value)
                              CircleAvatar(
                                backgroundColor: mainColor,
                                radius: 3,
                              ),
                            if (index == indexTab.value) SizedBox(width: 5),
                            Text(
                              "${overviews[index]}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: index == indexTab.value ? 15 : 14,
                                  fontWeight: index == indexTab.value
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: index == indexTab.value
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

  final TextStyle colorWhiteStyle = TextStyle(color: Colors.white);
  final CustomPopupMenuController _controller = CustomPopupMenuController();
  final indexMain = 2.obs;

  Widget mainSaving(final XController x) {
    List<ItemModel> menuItems = [];
    CATEG_TOTALS.forEach((element) {
      int index = CATEG_TOTALS.indexOf(element);
      var title = 'Main ${element['title']}';
      if (index == 0) {
        title = '${element['title']}';
      }
      menuItems.add(ItemModel('$title', Icons.topic));
    });

    return Container(
      width: Get.width,
      height: 105,
      padding: edgeInsets,
      margin: edgeInsets,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          stops: gradientStops,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: _controller.showMenu,
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Obx(
                    () => indexMain.value == 0
                        ? Text(
                            "${CATEG_TOTALS[indexMain.value]['title']}",
                            style: colorWhiteStyle.copyWith(fontSize: 16),
                          )
                        : Text(
                            "Main ${CATEG_TOTALS[indexMain.value]['title']}",
                            style: colorWhiteStyle.copyWith(fontSize: 16),
                          ),
                  ),
                ),
              ),
              //Icon(FeatherIcons.chevronDown, color: Colors.white),
              CustomPopupMenu(
                child: Container(
                  child: Icon(FeatherIcons.chevronDown, color: Colors.white),
                  padding: EdgeInsets.all(0),
                ),
                menuBuilder: () => ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    color: mainColor,
                    child: IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: menuItems.map((item) {
                          int idx = menuItems.indexOf(item);
                          return Obx(
                            () => GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () async {
                                indexMain.value = idx;
                                await Future.delayed(
                                    Duration(milliseconds: 600), () {
                                  onClickItemToRefresh();
                                });
                                return _controller.hideMenu();
                              },
                              child: Container(
                                height: 40,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                color: indexMain.value == idx
                                    ? lightColor
                                    : Colors.transparent,
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      item.icon,
                                      size: 20,
                                      color: indexMain.value == idx
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(left: 10),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        child: Text(
                                          item.title,
                                          style: TextStyle(
                                            color: indexMain.value == idx
                                                ? Colors.black
                                                : Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                pressType: PressType.singleClick,
                verticalMargin: -10,
                controller: _controller,
              ),
            ],
          ),
          SizedBox(height: 0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: Icon(FeatherIcons.plusCircle,
                      size: 35, color: Colors.white),
                  onPressed: () async {
                    x.setDatenowAppOnly();
                    final callback = await Get.to(AddIncomeScreen());
                    if (callback != null) {
                      onClickItemToRefresh();
                    }
                  }),
              SizedBox.shrink(),
              Obx(
                () =>
                    AmountIncome(type: indexMain.value, show: showFirst.value),
              ),
            ],
          ),
        ],
      ),
    );
  }

  final _channel =
      const MethodChannel('com.erhacorpdotcom.mmanager/app_retain');
  Future<bool> onBackPress() {
    if (GetPlatform.isAndroid) {
      if (Navigator.of(Get.context!).canPop()) {
        return Future.value(true);
      } else {
        _channel.invokeMethod('sendToBackground');
        return Future.value(false);
      }
    } else {
      return Future.value(true);
    }
  }
}
