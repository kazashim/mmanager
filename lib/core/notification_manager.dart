import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mmanager/core/xcontroller.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:timezone/data/latest.dart' as tz;
import 'package:http/http.dart' as http;

class NotificationManager {
  static const TAG = "NotificationManager";
  static const CHANNEL_ID = "Alertmmanager";
  static const CHANNEL_DESC = "Alert mmanager";
  static const THREAD_ID_IOS = "681";

  static const CHANNEL_ID_SCHEDULE = "Notification Mmanager";
  static const CHANNEL_DESC_SCHEDULE = "Alert Notification Mmanager";

  static const String KEY_INSERT_NOTIF = "_pref_insert_notif";

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationManager._internal() {
    print("NotificationManager._internal...");
    init();
  }

  static final NotificationManager _instance = NotificationManager._internal();
  static NotificationManager get instance => _instance;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _initialized = false;

  Future<void> init() async {
    print("[NotificationManager] init...._initialized $_initialized ");

    tz.initializeTimeZones();

    // init local notification
    await initNotification();

    if (!_initialized) {
      print(
          "[NotificationManager] _firebaseMessaging.configure _initialized $_initialized ");
      final NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
      }

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Got a message in the onMessageOpenedApp!');
        print('Message data: ${message.data}');
        getDataFcm(message, false, true);
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');

        if (message.notification != null) {
          print(
              'Message also contained a notification: ${message.notification}');
        }

        getDataFcm(message, false, false);
      });

      if (GetPlatform.isIOS) {
        await _firebaseMessaging.setForegroundNotificationPresentationOptions(
          alert: true, // Required to display a heads up notification
          badge: true,
          sound: true,
        );
      }

      _firebaseMessaging.getToken().then((String? token) {
        if (token != null) {
          try {
            final XController x = XController.to;
            x.setToken(token);
            x.getHome();
          } catch (e) {}
        }
      });
      _initialized = true;
    }

    _firebaseMessaging.onTokenRefresh.listen((String? newToken) {
      if (newToken != null) {
        try {
          final XController x = XController.to;
          x.setToken(newToken);
          x.getHome();
        } catch (e) {}
      }
    });

    _firebaseMessaging.subscribeToTopic(XController.SUBSCRIBE_FCM);
    print("_firebaseMessaging subscribe topic ${XController.SUBSCRIBE_FCM}");
  }

  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();

    try {
      Get.lazyPut<XController>(() => XController());
      print("Handling a background message: ${message.messageId}");
      getDataFcm(message, true, false);
    } catch (e) {
      print("Error firebaseMessagingBackgroundHandler $e");
    }
  }

  var androidPlatformChannelSpecifics =
      new AndroidInitializationSettings('app_icon');
  var iOSPlatformChannelSpecifics = new IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int? id, String? title, String? body, String? payload) async {
        print("onDidReceiveRunning Notification... ");
        var notif = {
          "title": title,
          "body": body,
        };

        try {
          if (payload != null) {
            dynamic data = jsonDecode(payload);
            String keyname = data['keyname'];
            createNotification(keyname, notif, true, jsonEncode(payload));
          }
        } catch (e) {
          print("Error onDidReceiveRunning $e");
        }
      });

  initNotification() {
    var initSetttings = new InitializationSettings(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
        macOS: null);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: (String? payload) async {
      print("onSelectNotification checking payload $payload");
    });

    print("[NotificationManager] init.... initNotification done... ");
  }

  parsingOnSelectPayload(dynamic _payload, bool isForce) {
    try {
      var payload = _payload;

      print(payload);
      if (payload != null && payload != '') {
        getDataFcm(RemoteMessage.fromMap(payload), true, isForce);
      }
    } catch (e) {
      print("errror thiss1111 $e");
    }
  }

  static showNotif(String title, String description, dynamic payload) async {
    print("PM.. notification showNotif created...");

    Future.delayed(Duration(seconds: 5), () async {
      await _showBigTextNotificationNew(
          "$title", "$description", jsonEncode(payload));
    });

    Future.delayed(Duration(seconds: 15), () async {
      //await _scheduleNotification();
    });
  }

  static bool isProcessNotif = false;
  static getDataFcm(RemoteMessage message, bool isBackground, bool isForce) {
    String from = message.from ?? "";

    try {
      print(
          "[NotificationManager] getnotiffff from $from isForce: $isForce isBackground: $isBackground");

      //String id = '701';
      if (message.notification != null) {
        var notif = message.notification;

        String? keyname = "";

        try {
          var messageData = message.data;
          keyname = messageData['keyname'];
        } catch (e) {}
        print("keyname: $keyname"); // peer $peer");

        final XController x = XController.to;
        if (keyname != null &&
            keyname.length > 1 &&
            keyname.startsWith('message')) {
          x.getHome();

          print("keyname : $keyname");
          print("isForce : $isForce");

          try {
            var notifData = {
              "title": notif!.title,
              "body": notif.body,
            };
            x.box.write(
                KEY_INSERT_NOTIF,
                jsonEncode({
                  "notification": notifData,
                  "data": message.data
                })); // jsonEncode(message)

            /**/
          } catch (e) {
            print("try to save box KEY_INSERT_NOTIF error ${e.toString()}");
          }
          if (isForce) {}
        } else {
          if (notif!.title == null || notif.body == null) {
            return;
          }
        }

        if (isBackground) return;

        var notification = {
          "title": notif!.title,
          "body": notif.body,
        };

        print("notification: $notification");

        createNotification(
            keyname!, notification, isBackground, jsonEncode(message.data));
      }
    } catch (e) {
      print("[NotificationManager] error this000 ${e.toString()}");
    }
  }

  //dynamic notif,
  static createNotification(
      String keyname, dynamic notif, bool isBackground, String payload) {
    print("createNotification .. is running... $notif");
    try {
      print("title ${notif['title']}");

      if (notif['title'] == null || notif['body'] == null) {
        return;
      }
    } catch (e) {}

    try {
      if (notif['title'] == '' || notif['body'] == '') {
        print("enter this3333");
        return;
      }
    } catch (e) {}

    if (isProcessNotif || isBackground) return;
    isProcessNotif = true;

    Future.delayed(Duration(milliseconds: 2500), () {
      isProcessNotif = false;
    });

    Future.delayed(Duration(milliseconds: 1300), () async {
      print("Notif created...");
      print(notif);

      await _showBigTextNotificationNew(
        //_showPublicNotification(
        notif['title'],
        notif['body'],
        payload,
      );

      //c.secondCall();
      //c.fetchHome(false);
    });
  }

  static Future<dynamic> onBackgroundMessage(Map<String, dynamic> message) {
    //debugPrint('[NotificationManager] onBackgroundMessage: $message');
    if (message.containsKey('data')) {
      //getDataFcm(message, true, false);
    }
    return Future<void>.value();
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  static Future<void> _showBigTextNotificationNew(
      String title, String body, String payload) async {
    var bigTextStyleInformation = BigTextStyleInformation('$body',
        htmlFormatBigText: true,
        contentTitle: '$title',
        htmlFormatContentTitle: true,
        htmlFormatSummaryText: true);

    String channelID = '601';
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelID,
      'Notification Broadcast',
      'Notification Broadcast Apps',
      importance: Importance.max,
      priority: Priority.high,
      largeIcon: DrawableResourceAndroidBitmap('logoapp_330'),
      autoCancel: true,
      styleInformation: bigTextStyleInformation,
    );
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: IOSNotificationDetails());
    await flutterLocalNotificationsPlugin.show(
        int.parse(channelID), '$title', '$body', platformChannelSpecifics);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Replace with server token from firebase console settings.
  static const String serverToken =
      'AAAAUGkqgFY:APA91bEJe5JSQIHD6S87ycHjo9Rk5H8s8K2j9OG5HyoEmKIQhr3dvYZJBWHl05vWAx9JGJUrIUR606G2XmTNypaDCCicdRg6uCD5v3YE8eOeoaHnKztyQa3oTM02wbkUY2hSz_3_tmdX';
  static const String senderNumber = '345361776726';

  final box = GetStorage();
  Future<Map<String, dynamic>> sendAndRetrieveMessage() async {
    print("do sendAndRetrieveMessage()...");
    String getToken = box.read(XController.KEY_TOKEN) ?? "";
    print("getToken $getToken");

    if (getToken != '') {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': 'this is a body',
              'title': 'this is a title'
            },
            // Set Android priority to "high"
            'android': <String, dynamic>{
              'priority': "high",
            },
            // Add APNS (Apple) config
            'apns': <String, dynamic>{
              'payload': <String, dynamic>{
                'aps': <String, dynamic>{
                  'contentAvailable': true,
                },
              },
              'headers': <String, dynamic>{
                "apns-push-type": "background",
                "apns-priority":
                    "5", // Must be `5` when `contentAvailable` is set to true.
                "apns-topic":
                    "io.flutter.plugins.firebase.messaging", // bundle identifier
              },
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            'to': box.read(XController.KEY_TOKEN),
          },
        ),
      );
    }

    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    return completer.future;
  }
}
