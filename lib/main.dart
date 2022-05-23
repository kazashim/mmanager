import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mmanager/apps/home_page.dart';
import 'package:mmanager/core/notification_manager.dart';
import 'package:mmanager/core/xcontroller.dart';
import 'package:mmanager/provider/manager_provider.dart';
import 'package:mmanager/screens/intro_screen.dart';
import 'package:tekartik_app_platform/app_platform.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:tekartik_app_flutter_sqflite/sqflite.dart';

late DbManagerProvider managerProvider;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(
      NotificationManager.firebaseMessagingBackgroundHandler);

  await GetStorage.init();
  Get.lazyPut<XController>(() => XController());

  platformInit();
  var packageName = 'com.erhacorpdotcom.sqflite.mmanager';
  var databaseFactory = getDatabaseFactory(packageName: packageName);
  managerProvider = DbManagerProvider(databaseFactory);
  await managerProvider.ready;

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]).then((_) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      //systemNavigationBarColor: purpleLight, //mainColor,
      //Color(0xff42aeee), //Color(0xff1c252a),
      statusBarColor: Colors.transparent,
    ));

    final XController x = XController.to;

    Timer.periodic(Duration(minutes: 18), (_t) {
      x.getHome();
    });

    return runApp(MyApp());
  });
}

const darkMainColor = Color(0xff354b9a);
const softMainColor = Color(0xff3e5ac6);
const mainColor = Color(0xff695bc2); // Color(0xff5673d9);
const lightColor = Color(0xffedf0fc); // Color(0xfff5f6fb)
const backgroundColor = Color(0xfff5f6fa);

const List<Color> colorList = [
  darkMainColor,
  Colors.orange,
  //softMainColor,
  Colors.teal,
  Colors.red,
  Colors.lightBlue,
  mainColor,
  softMainColor,
  Colors.purple,
  Colors.deepOrange,
  Colors.indigo,
  Colors.greenAccent,
  Colors.cyan,
  Colors.indigoAccent,
  softMainColor,
  Colors.yellow,
  Colors.blue,
  Colors.yellowAccent,
  Colors.blueGrey,
  Colors.lightGreen,
  Colors.greenAccent,
];

const MONTHS = [
  {"id": "1", "title": "Jan"},
  {"id": "2", "title": "Feb"},
  {"id": "3", "title": "Mar"},
  {"id": "4", "title": "Apr"},
  {"id": "5", "title": "May"},
  {"id": "6", "title": "Jun"},
  {"id": "7", "title": "Jul"},
  {"id": "8", "title": "Aug"},
  {"id": "9", "title": "Sep"},
  {"id": "10", "title": "Oct"},
  {"id": "11", "title": "Nov"},
  {"id": "12", "title": "Dec"}
];

const THREE_MONTHS = [
  {"id": "Jan", "title": "Jan - Mar"},
  {"id": "Feb", "title": "Jan - Mar"},
  {"id": "Mar", "title": "Jan - Mar"},
  {"id": "Apr", "title": "Apr - Jun"},
  {"id": "May", "title": "Apr - Jun"},
  {"id": "Jun", "title": "Apr - Jun"},
  {"id": "Jul", "title": "Jul - Sep"},
  {"id": "Aug", "title": "Jul - Sep"},
  {"id": "Sep", "title": "Jul - Sep"},
  {"id": "Oct", "title": "Oct - Dec"},
  {"id": "Nov", "title": "Oct - Dec"},
  {"id": "Dec", "title": "Oct - Dec"}
];

const List<dynamic> CATEG_EXPENSES = [
  {"id": "1", "title": "Electronic", "icon": "entertaint01.png"},
  {"id": "2", "title": "Bedroom", "icon": "entertaint01.png"},
  {"id": "3", "title": "Furniture", "icon": "entertaint01.png"},
  {"id": "4", "title": "TV", "icon": "entertaint01.png"},
  {"id": "5", "title": "Gadget", "icon": "entertaint01.png"},
  {"id": "6", "title": "Kitchen", "icon": "entertaint01.png"},
  {"id": "7", "title": "Bathroom", "icon": "entertaint01.png"},
  {"id": "8", "title": "Renovation", "icon": "entertaint01.png"},
  {"id": "9", "title": "FoodBeverage", "icon": "entertaint01.png"},
  {"id": "10", "title": "School", "icon": "entertaint01.png"},
  {"id": "11", "title": "Garden", "icon": "entertaint01.png"},
  {"id": "12", "title": "Light", "icon": "entertaint01.png"},
  {"id": "13", "title": "Sneakers", "icon": "sneaker01.jpeg"},
  {"id": "14", "title": "Cosmetic", "icon": "sneaker01.jpeg"},
  {"id": "15", "title": "Fitness", "icon": "fitness01.jpeg"},
  {"id": "16", "title": "Education", "icon": "education01.png"},
  {"id": "17", "title": "Entertaint", "icon": "entertaint01.png"},
  {"id": "18", "title": "Hobby", "icon": "entertaint01.png"},
  {"id": "19", "title": "Car", "icon": "entertaint01.png"},
  {"id": "20", "title": "Motor", "icon": "entertaint01.png"},
  {"id": "21", "title": "Bike", "icon": "entertaint01.png"},
  {"id": "22", "title": "Dress/Outfit", "icon": "entertaint01.png"},
  {"id": "23", "title": "Shirts/Pants", "icon": "entertaint01.png"},
  {"id": "24", "title": "Tax", "icon": "entertaint01.png"},
  {"id": "25", "title": "Treatment", "icon": "entertaint01.png"},
  {"id": "26", "title": "Payroll", "icon": "entertaint01.png"},
  {"id": "27", "title": "Other", "icon": "entertaint01.png"},
];

const List<dynamic> CATEG_INCOMES = [
  {"id": "1", "title": "Salary", "icon": "entertaint01.png"},
  {"id": "2", "title": "Savings", "icon": "entertaint01.png"},
  {"id": "3", "title": "Bonus", "icon": "entertaint01.png"},
  {"id": "4", "title": "Overtime", "icon": "entertaint01.png"},
  {"id": "5", "title": "Freelance", "icon": "entertaint01.png"},
  {"id": "6", "title": "Project", "icon": "entertaint01.png"},
  {"id": "7", "title": "Gift", "icon": "entertaint01.png"},
  {"id": "8", "title": "Market", "icon": "entertaint01.png"},
  {"id": "9", "title": "Sosmed", "icon": "entertaint01.png"},
  {"id": "10", "title": "Sales", "icon": "entertaint01.png"},
];

const List<dynamic> CATEG_TOTALS = [
  {"id": "0", "title": "Total", "icon": "entertaint01.png"},
  {"id": "1", "title": "Salary", "icon": "entertaint01.png"},
  {"id": "2", "title": "Savings", "icon": "entertaint01.png"},
  {"id": "3", "title": "Bonus", "icon": "entertaint01.png"},
  {"id": "4", "title": "Overtime", "icon": "entertaint01.png"},
  {"id": "5", "title": "Freelance", "icon": "entertaint01.png"},
  {"id": "6", "title": "Project", "icon": "entertaint01.png"},
  {"id": "7", "title": "Gift", "icon": "entertaint01.png"},
];

class CategoryModel {
  String id;
  String title;
  String icon;
  @override
  String toString() {
    return '$id $title $icon';
  }

  CategoryModel(this.id, this.title, this.icon);
}

const List<Color> gradientColors = [
  //lightColor,
  Color(0xff8399e5),
  mainColor,
  darkMainColor

  /*Color(0xff8399e5),
  Color(0xff5d78db),
  Color(0xff5673d9)*/
];

const List<double> gradientStops = [0.2, 0.6, 0.9];

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final XController x = XController.to;
    return GetMaterialApp(
      title: '${XController.APP_NAME}',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.nunito().fontFamily,
        primaryColor: mainColor,
        accentColor: softMainColor,
      ),
      home: x.isFirst.value ? IntroScreen() : HomePage(),
      builder: (BuildContext? context, Widget? child) {
        /// make sure that loading can be displayed in front of all other widgets
        return FlutterEasyLoading(child: child);
      },
    );
  }
}
