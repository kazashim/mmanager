import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:mmanager/core/ads_helper.dart';
import 'package:mmanager/core/notification_manager.dart';
import 'package:mmanager/main.dart';
import 'package:mmanager/model/model.dart';
import 'package:mmanager/model/model_constant.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class ItemManager {
  ItemManager();
  DbManager? managerIncome;
  DbManager? managerExpense;
}

class ItemTotal {
  ItemTotal();
  int? total = 0;
  int? totalByType = 0;
  Map<String, double>? dataMap = new Map<String, double>();
  int? totalAmount = 0;
}

class ItemWeek {
  ItemWeek();
  String? week;
  DateTime? first;
  DateTime? last;
}

class ItemMonth {
  ItemMonth();
  String? month;
  String? firstMonth;
  String? firstYear;
  DateTime? first;
}

class ItemThreeMonth {
  ItemThreeMonth();
  String? month;
  String? firstMonth;
  String? firstYear;
  DateTime? first;
  int? index;
  String? paramDate;
}

class UserLogin {
  UserLogin();
  dynamic? userLogin;
  int? status;
}

class XController extends GetxController {
  static XController get to => Get.find<XController>();

  static const APP_NAME = "MManager";
  static const APP_VERSION = "0.9.5";

  static const String KEY_CURRENCY = "_k_currency";
  static const String KEY_LANG = "_k_lang";
  static const String KEY_MEMBER = "_k_member";

  static const String KEY_UUID = "_k_uuid";
  static const String KEY_TOKEN = "_k_token";

  static const String KEY_FIRST = "_k_first";
  static const String KEY_VER_DB = "_k_verdb";
  static const String SUBSCRIBE_FCM = "topicsmmanager";

  final AdsHelper _adsHelper = AdsHelper.instance;
  AdsHelper get adsHelper => _adsHelper;

  final NotificationManager _helper = NotificationManager.instance;
  NotificationManager get helper => _helper;

  final dateTimeNow = DateTime.now().toLocal();
  final showFirst = true.obs;

  final defCurrency = "IDR".obs;
  final defLang = "en".obs;
  final box = GetStorage();

  final isFirst = true.obs;
  final dbVersion = 1.obs;

  final defToken = "".obs;
  final defUUID = "".obs;

  final userLogin = Map<String, dynamic>().obs;

  @override
  void onInit() {
    print("onInit XController running...");
    // get dbVersion
    final getDbVersion = box.read(KEY_VER_DB) ?? 1;
    setDbVersion(getDbVersion);

    // get first
    final getFirst = box.read(KEY_FIRST) ?? true;
    setFirstLoad(getFirst);

    // get uuID
    final getUUID = box.read(KEY_UUID) ?? Uuid().v1();
    setUUID(getUUID);
    print("get UUID...${defUUID.value}");

    // get token
    final getToken = box.read(KEY_TOKEN) ?? "";
    setToken(getToken);

    // get language
    final getLang = box.read(KEY_LANG) ?? "en";
    setDefLanguage(getLang);

    // get currency
    final getCurrency = box.read(KEY_CURRENCY) ?? "ZMW";
    setDefCurrency(getCurrency);

    // get user
    final getLogin = box.read(KEY_MEMBER) ?? null;
    //print(getLogin);
    userLogin.value = getLogin != null ? jsonDecode(getLogin) : {};
    update();

    super.onInit();

    thisMonth.value = DateFormat('MMM yyyy').format(dateTimeNow).toString();

    final month = DateFormat('MM').format(dateTimeNow).toString();
    int getMonth = int.parse(month);
    setMonthValue(getMonth);
    setFirstThreeMonth();
    setDatenowApp();

    //listen box storage
    box.listenKey(KEY_MEMBER, (value) {
      //listening key member
      userLogin.value = value != null ? jsonDecode(value) : {};
      update();
    });
  }

  setUUID(String? uuid) {
    if (uuid != null) {
      defUUID.value = uuid;
      update();
      box.write(KEY_UUID, uuid);
    }
  }

  setToken(String? token) {
    if (token != null) {
      defToken.value = token;
      update();
      box.write(KEY_TOKEN, token);
    }
  }

  setFirstLoad(bool? first) {
    if (first != null) {
      isFirst.value = first;
      update();
      box.write(KEY_FIRST, first);
    }
  }

  setDbVersion(int? version) {
    if (version != null) {
      dbVersion.value = version;
      update();
      box.write(KEY_VER_DB, version);
    }
  }

  setFirstThreeMonth() {
    //String year = DateFormat('yyyy').format(dateTimeNow).toString();
    String nameMonth = DateFormat('MMM').format(dateTimeNow).toString();
    THREE_MONTHS.forEach((dynamic element) {
      int index = THREE_MONTHS.indexOf(element);
      if (element['id'] == nameMonth) {
        setThreeMonthValue("${element['title']}", index);
      }
    });
  }

  setDefCurrency(String? currency) {
    // for example currency = IDR
    if (currency != null && currency != '') {
      defCurrency.value = currency;
      update();
      box.write(KEY_CURRENCY, currency);
    }
  }

  setDefLanguage(String? language) {
    if (language != null && language != '') {
      defLang.value = language;
      update();
      box.write(KEY_LANG, language);
    }
  }

  final dateNowApps = "".obs;
  final itemWeek = ItemWeek().obs;
  final itemMonth = ItemMonth().obs;
  final itemThreeMonth = ItemThreeMonth().obs;

  final itemWeekDetail = ItemWeek().obs;
  final itemMonthDetail = ItemMonth().obs;

  setDatenowAppOnly() {
    String dtNow = DateFormat('E, dd MMM yyyy HH:mm:ss')
        .format(dateTimeNow.toLocal())
        .toString();
    dateNowApps.value = dtNow;
    update();
  }

  setThisMonthOnly(bool? isDetail) {
    thisMonth.value = DateFormat('MMM yyyy').format(dateTimeNow).toString();

    if (isDetail != null && isDetail) {
      itemMonthDetail.update((val) {
        val!.month = thisMonth.value;
        val.first = dateTimeNow;
      });
    } else
      itemMonth.update((val) {
        val!.month = thisMonth.value;
        val.first = dateTimeNow;
      });
  }

  setThisWeek(bool? isDetail) {
    DateTime getfirst = XController.findFirstDateOfTheWeek(dateTimeNow);
    String firstDate = DateFormat('yyyy-MM-dd').format(getfirst).toString();
    String dateTimeString = "$firstDate 00:00:00"; //23:59:59
    final formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
    DateTime first = formatter.parse(dateTimeString);

    DateTime getlast = XController.findLastDateOfTheWeek(dateTimeNow);
    String lastDate = DateFormat('yyyy-MM-dd').format(getlast).toString();
    String dateTimeLastString = "$lastDate 23:59:59"; //23:59:59
    final formatterLast = DateFormat('yyyy-MM-dd hh:mm:ss');
    DateTime last = formatterLast.parse(dateTimeLastString);

    String thisWeek =
        "${XController.formatDateByDatetime(first)} - ${XController.formatDateByDatetime(last)}";

    if (isDetail != null && isDetail) {
      itemWeekDetail.update((val) {
        val!.week = thisWeek;
        val.first = first;
        val.last = last;
      });
    } else
      itemWeek.update((val) {
        val!.week = thisWeek;
        val.first = first;
        val.last = last;
      });
  }

  setDatenowApp() {
    setDatenowAppOnly();

    setThisMonthOnly(false);
    setThisMonthOnly(true);

    setThisWeek(false);
    setThisWeek(true);
  }

  // last threeMontDetail
  setLastThreeMonthDetail(final DateTime firstMonth, final int? tipe) {
    DateTime lastMonth = firstMonth.subtract(Duration(days: 90));
    int index = itemThreeMonthDetail.value.index!;
    //print("setLastThreeMonthDetail index: $index");

    String month = itemThreeMonthDetail.value.month!;
    int finalIndex = index;
    if (index > 1) {
      finalIndex = index - 3;
      month =
          "${THREE_MONTHS[finalIndex]['title'].toString()} ${itemThreeMonthDetail.value.firstYear!}";
    }

    //print(month);
    String paramDate = getStringParamThreeMonth(finalIndex);

    itemThreeMonthDetail.update((val) {
      val!.month = month;
      val.first = lastMonth;
      val.index = finalIndex;
      val.paramDate = paramDate;
    });

    getSummaryIncomeExpenseDetail(tipe: tipe, paramDate: paramDate);
  }

  setNextThreeMonthDetail(final DateTime firstMonth, final int? tipe) {
    DateTime lastMonth = firstMonth.add(Duration(days: 90));
    int index = itemThreeMonthDetail.value.index!;
    //print("setNextThreeMonthDetail index: $index");

    String month = itemThreeMonthDetail.value.month!;
    int finalIndex = index;
    if (index >= 0) {
      finalIndex = index + 3;
      month =
          "${THREE_MONTHS[finalIndex]['title'].toString()} ${itemThreeMonthDetail.value.firstYear!}";
    }

    //print(month);
    String paramDate = getStringParamThreeMonth(finalIndex);

    itemThreeMonthDetail.update((val) {
      val!.month = month;
      val.first = lastMonth;
      val.index = finalIndex;
      val.paramDate = paramDate;
    });

    getSummaryIncomeExpenseDetail(tipe: tipe, paramDate: paramDate);
  }

  // last threeMontDetail

  setLastThreeMonth(final DateTime firstMonth, final int? categ) {
    DateTime lastMonth = firstMonth.subtract(Duration(days: 90));
    int index = itemThreeMonth.value.index!;
    //print("setLastThreeMonth index: $index");

    String month = itemThreeMonth.value.month!;
    int finalIndex = index;
    if (index > 1) {
      finalIndex = index - 3;
      month =
          "${THREE_MONTHS[finalIndex]['title'].toString()} ${itemThreeMonth.value.firstYear!}";
    }

    //print(month);
    String paramDate = getStringParamThreeMonth(finalIndex);

    itemThreeMonth.update((val) {
      val!.month = month;
      val.first = lastMonth;
      val.index = finalIndex;
      val.paramDate = paramDate;
    });

    getSummaryIncomeExpense(categ: categ, paramDate: paramDate);
  }

  setNextThreeMonth(final DateTime firstMonth, final int? categ) {
    DateTime lastMonth = firstMonth.add(Duration(days: 90));
    int index = itemThreeMonth.value.index!;
    //print("setNextThreeMonth index: $index");

    String month = itemThreeMonth.value.month!;
    int finalIndex = index;
    if (index >= 0) {
      finalIndex = index + 3;
      month =
          "${THREE_MONTHS[finalIndex]['title'].toString()} ${itemThreeMonth.value.firstYear!}";
    }

    //print(month);
    String paramDate = getStringParamThreeMonth(finalIndex);

    itemThreeMonth.update((val) {
      val!.month = month;
      val.first = lastMonth;
      val.index = finalIndex;
      val.paramDate = paramDate;
    });

    getSummaryIncomeExpense(categ: categ, paramDate: paramDate);
  }

  setLastMonth(final DateTime firstMonth, bool? isDetail) {
    DateTime lastMonth = firstMonth.subtract(Duration(days: 30));
    thisMonth.value = DateFormat('MMM yyyy').format(lastMonth).toString();

    if (isDetail != null && isDetail) {
      itemMonthDetail.update((val) {
        val!.month = thisMonth.value;
        val.first = lastMonth;
      });
    } else
      itemMonth.update((val) {
        val!.month = thisMonth.value;
        val.first = lastMonth;
      });
  }

  setNextMonth(final DateTime firstMonth, bool? isDetail) {
    DateTime lastMonth = firstMonth.add(Duration(days: 30));
    thisMonth.value = DateFormat('MMM yyyy').format(lastMonth).toString();

    if (isDetail != null && isDetail) {
      itemMonthDetail.update((val) {
        val!.month = thisMonth.value;
        val.first = lastMonth;
      });
    } else
      itemMonth.update((val) {
        val!.month = thisMonth.value;
        val.first = lastMonth;
      });
  }

  setLastWeek(
      final DateTime firstDate, final DateTime lastDate, bool? isDetail) {
    DateTime lastStart = firstDate.subtract(Duration(days: 7));
    DateTime lastEnd = lastDate.subtract(Duration(days: 7));

    String thisWeek =
        "${XController.formatDateByDatetime(lastStart)} - ${XController.formatDateByDatetime(lastEnd)}";

    //print("thisWeek $thisWeek");

    if (isDetail != null && isDetail) {
      itemWeekDetail.update((val) {
        val!.week = thisWeek;
        val.first = lastStart;
        val.last = lastEnd;
      });
    } else
      itemWeek.update((val) {
        val!.week = thisWeek;
        val.first = lastStart;
        val.last = lastEnd;
      });
  }

  setNextWeek(
      final DateTime firstDate, final DateTime lastDate, bool? isDetail) {
    DateTime lastStart = firstDate.add(Duration(days: 7));
    DateTime lastEnd = lastDate.add(Duration(days: 7));

    String thisWeek =
        "${XController.formatDateByDatetime(lastStart)} - ${XController.formatDateByDatetime(lastEnd)}";

    //print("thisWeek $thisWeek");

    if (isDetail != null && isDetail) {
      itemWeekDetail.update((val) {
        val!.week = thisWeek;
        val.first = lastStart;
        val.last = lastEnd;
      });
    } else
      itemWeek.update((val) {
        val!.week = thisWeek;
        val.first = lastStart;
        val.last = lastEnd;
      });
  }

  final monthValue = 4.obs;
  final thisMonth = "".obs;
  setMonthValue(int index) {
    monthValue.value = index;
    update();
  }

  setThreeMonthValue(final String threeMonth, final int index) {
    //print("setThreeMonthValue threeMonth: $threeMonth, index: $index");

    String year = DateFormat('yyyy').format(dateTimeNow).toString();
    String nameMonth = DateFormat('MMM').format(dateTimeNow).toString();

    String firstDate = DateFormat('yyyy-MM-dd').format(dateTimeNow).toString();
    String dateTimeString = "$firstDate 00:00:00";
    final formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
    final dateTime = formatter.parse(dateTimeString);

    String paramDate = getStringParamThreeMonth(index);

    itemThreeMonth.update((val) {
      val!.month = "$threeMonth $year";
      val.firstMonth = nameMonth;
      val.firstYear = year;
      val.first = dateTime;
      val.index = index;
      val.paramDate = paramDate;
    });
  }

  bool processGetSummary = false;
  final thisManagerA = ItemManager().obs;
  final itemTotal = ItemTotal().obs;
  final itemTotalCateg = ItemTotal().obs;

  getSummaryIncomeExpense(
      {int? categ = 1,
      String? paramDate,
      bool? isMonth = false,
      String? paramMonth}) async {
    //print(
    //    "getSummaryIncomeExpense is ${processGetSummary ? 'waiting' : 'running'}...");
    if (processGetSummary) {
      return;
    }

    processGetSummary = true;
    Future.delayed(Duration(milliseconds: 600), () {
      processGetSummary = false;
    });

    thisManagerA.update((val) {
      val!.managerIncome = DbManager();
      val.managerExpense = DbManager();
    });

    itemTotal.update((val) {
      val!.total = 0;
      val.totalByType = 0;
    });

    if (paramDate == null) {
      String firstDate =
          DateFormat('yyyy-MM-dd').format(dateTimeNow).toString();
      String dateTimeString = "$firstDate 00:00:00";
      final formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
      final dateTime = formatter.parse(dateTimeString);
      final firstWeek =
          XController.findFirstDateOfTheWeek(dateTime).millisecondsSinceEpoch;

      DateTime getEndWeek = XController.findLastDateOfTheWeek(dateTimeNow);
      String lastDate = DateFormat('yyyy-MM-dd').format(getEndWeek).toString();
      String dateTimeLastString = "$lastDate 23:59:59"; //23:59:59
      final formatterLast = DateFormat('yyyy-MM-dd hh:mm:ss');
      DateTime last = formatterLast.parse(dateTimeLastString);
      final endWeek =
          XController.findLastDateOfTheWeek(last).millisecondsSinceEpoch;

      paramDate =
          " AND $columnCreated>=$firstWeek AND $columnCreated<=$endWeek ";
    }

    if (isMonth != null && isMonth) {
      paramDate = " AND $columnDate LIKE '%$paramMonth%' ";
    }

    //print("categ $categ paramDate getSummaryIncomeExpense: $paramDate ");

    final managerIncome =
        await managerProvider.getSumTotalByType(tipe: 1, params: paramDate);
    final managerExpense =
        await managerProvider.getSumTotalByType(tipe: 2, params: paramDate);

    //print(managerIncome);
    //print(managerExpense);

    if (categ == -1) {
      //print("categ $categ reload");
      itemTotalCateg.update((val) {
        val!.total = managerIncome!.amount.v! - managerExpense!.amount.v!;
        val.totalByType = managerIncome.amount.v!;
      });
    }

    Future.delayed(Duration(milliseconds: 300), () {
      thisManagerA.update((val) {
        val!.managerIncome = managerIncome;
        val.managerExpense = managerExpense;
      });

      itemTotal.update((val) {
        val!.total = managerIncome!.amount.v! - managerExpense!.amount.v!;
        val.totalByType = managerIncome.amount.v!;
      });
    });
  }

  getStringParamThreeMonth(int index) {
    //print("getStringParamThreeMonth: $index");

    String year = DateFormat('yyyy').format(dateTimeNow).toString();
    String nameMonth = DateFormat('MMM').format(dateTimeNow).toString();

    Map<String, dynamic> getMonths =
        THREE_MONTHS.firstWhere((element) => element['id'] == nameMonth);
    if (index != -1) {
      getMonths = THREE_MONTHS[index];
    }

    // print("getMonths");
    // print(getMonths);

    if (getMonths['title'] != null) {
      String getDateStart = getMonths['title'].toString();
      //print("get getDateStart $getDateStart");

      var split1 = getDateStart.split("-");
      //print("split1[0] ${split1[0]}, split1[1] ${split1[1]}");
      //String firstDate =
      //    DateFormat('yyyy-MM-dd').format(dateTimeNow).toString();

      String dateTimeString = "$year-${split1[0].trim()}-01 00:00:00";
      final formatter = DateFormat('yyyy-MMM-dd hh:mm:ss');
      final dateTime = formatter.parse(dateTimeString);
      final firstWeek = findFirstDateOfTheWeek(dateTime).millisecondsSinceEpoch;

      String enddateTimeString = "$year-${split1[1].trim()}-31 23:59:59";
      final endformatter = DateFormat('yyyy-MMM-dd hh:mm:ss');
      final enddateTime = endformatter.parse(enddateTimeString);

      final endWeek = findLastDateOfTheWeek(enddateTime).millisecondsSinceEpoch;
      String paramDate =
          " AND $columnCreated>=$firstWeek AND $columnCreated<=$endWeek ";
      //print("[getStringParamThreeMonth] set paramDate: $paramDate");

      return paramDate;
    } else
      return null;
  }

  bool processGetSummaryByCateg = false;
  getSummaryIncomeByCateg(
      {int? categ = 1,
      String? paramDate,
      bool? isMonth = false,
      String? paramMonth}) async {
    //print(
    //    "getSummaryIncomeByCateg is categ $categ ${processGetSummaryByCateg ? 'waiting' : 'running'}...");

    if (processGetSummaryByCateg) {
      return;
    }

    processGetSummaryByCateg = true;
    Future.delayed(Duration(milliseconds: 300), () {
      processGetSummaryByCateg = false;
    });

    if (paramDate == null) {
      String firstDate =
          DateFormat('yyyy-MM-dd').format(dateTimeNow).toString();
      String dateTimeString = "$firstDate 00:00:00";
      final formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
      final dateTime = formatter.parse(dateTimeString);
      final firstWeek =
          XController.findFirstDateOfTheWeek(dateTime).millisecondsSinceEpoch;

      DateTime getEndWeek = XController.findLastDateOfTheWeek(dateTimeNow);
      String lastDate = DateFormat('yyyy-MM-dd').format(getEndWeek).toString();
      String dateTimeLastString = "$lastDate 23:59:59"; //23:59:59
      final formatterLast = DateFormat('yyyy-MM-dd hh:mm:ss');
      DateTime last = formatterLast.parse(dateTimeLastString);
      final endWeek =
          XController.findLastDateOfTheWeek(last).millisecondsSinceEpoch;

      paramDate =
          " AND $columnCreated>=$firstWeek AND $columnCreated<=$endWeek ";
    }

    if (isMonth != null && isMonth) {
      paramDate = " AND $columnDate LIKE '%$paramMonth%' ";
    }

    //print("getSummaryIncomeByCateg paramDate $paramDate");

    itemTotalCateg.update((val) {
      val!.total = 0;
      val.totalByType = 0;
    });

    var managerIncome = await managerProvider.getSumIncomeByCateg(
        categ: categ, params: paramDate);
    var totalSum = managerIncome!.amount.v!;

    if (categ == -1) {
      managerIncome =
          await managerProvider.getSumTotalByType(tipe: 1, params: paramDate);
      var managerExpense =
          await managerProvider.getSumTotalByType(tipe: 2, params: paramDate);
      totalSum = managerIncome!.amount.v! - managerExpense!.amount.v!;

      //print(managerIncome);
      //print(managerExpense);
    }

    itemTotalCateg.update((val) {
      val!.total = totalSum;
      val.totalByType = managerIncome!.amount.v!;
    });
  }

  getHome() async {
    print("token FCM: ${defToken.value}");

    pushAutoInstall();
  }

  //auto install user
  pushAutoInstall() async {
    print("pushAutoInstall isRunning...");

    dynamic member = userLogin.isEmpty ? {} : userLogin;
    try {
      var json = {
        "id": member['id_install'] ?? '',
        //"nm": member['fullname'] ?? '',
        "em": member['email'] ?? '',
        //"ph": member['phone'] ?? '',
        "ft": member['forgot_token'] ?? '',
        "tk": defToken.value,
        "ui": defUUID.value,
        "uf": "",
        "fr": GetPlatform.isAndroid ? "Android" : "iOS"
      };
      //print(jsonEncode(json));

      final response =
          await pushResponse('install/update_fcm', jsonEncode(json));
      if (response != null && response.statusCode == 200) {
        dynamic _result = jsonDecode(response.body);
        //print(_result);
        if (_result['code'] == '200') {
          List<dynamic>? res = _result['result'];
          if (res != null && res[0] != null) {
            userLogin.value = res[0];
            box.write(KEY_MEMBER, jsonEncode(res[0]));
          }
        }
      }
    } catch (e) {
      print("Error\n $e");
    }
  }

  //push update password
  pushUpdatePassword(String? password) async {
    print("pushUpdateName isRunning...");

    dynamic member = userLogin.isEmpty ? {} : userLogin;
    try {
      //print(member);
      var json = {
        "id": member['id_install'] ?? '',
        "ps": password ?? '',
        "ft": member['forgot_token'] ?? '',
        "tk": defToken.value,
        "ui": defUUID.value,
        "uf": "",
        "fr": GetPlatform.isAndroid ? "Android" : "iOS"
      };
      //print(jsonEncode(json));

      final response =
          await pushResponse('install/change_password', jsonEncode(json));
      if (response != null && response.statusCode == 200) {
        dynamic _result = jsonDecode(response.body);
        //print(_result);
        if (_result['code'] == '200') {
          List<dynamic>? res = _result['result'];
          if (res != null && res[0] != null) {
            userLogin.value = res[0];
            box.write(KEY_MEMBER, jsonEncode(res[0]));
          }
        } else {
          Future.delayed(Duration(milliseconds: 900), () async {
            EasyLoading.showError('Error\n ${_result['message']}');
          });
        }
      }
    } catch (e) {
      print("Error\n $e");
    }
  }

  //push update name
  pushUpdateName(String? nm) async {
    print("pushUpdateName isRunning...");

    dynamic member = userLogin.isEmpty ? {} : userLogin;
    try {
      //print(member);
      var json = {
        "id": member['id_install'] ?? '',
        "nm": nm ?? '',
        "ft": member['forgot_token'] ?? '',
        "tk": defToken.value,
        "ui": defUUID.value,
        "uf": "",
        "fr": GetPlatform.isAndroid ? "Android" : "iOS"
      };
      //print(jsonEncode(json));

      final response =
          await pushResponse('install/change_name', jsonEncode(json));
      if (response != null && response.statusCode == 200) {
        dynamic _result = jsonDecode(response.body);
        //print(_result);
        if (_result['code'] == '200') {
          List<dynamic>? res = _result['result'];
          if (res != null && res[0] != null) {
            userLogin.value = res[0];
            box.write(KEY_MEMBER, jsonEncode(res[0]));
          }
        } else {
          Future.delayed(Duration(milliseconds: 900), () async {
            EasyLoading.showError('Error\n ${_result['message']}');
          });
        }
      }
    } catch (e) {
      print("Error\n $e");
    }
  }

  pushLogout() async {
    print("pushLogout isRunning...");

    dynamic member = userLogin.isEmpty ? {} : userLogin;
    try {
      //print(member);
      var json = {
        "id": member['id_install'] ?? '',
        "ft": member['forgot_token'] ?? '',
        "tk": defToken.value,
        "ui": defUUID.value,
        "uf": "",
        "fr": GetPlatform.isAndroid ? "Android" : "iOS"
      };
      //print(jsonEncode(json));

      final response = await pushResponse('install/logout', jsonEncode(json));
      if (response != null && response.statusCode == 200) {
        dynamic _result = jsonDecode(response.body);
        //print(_result);
        if (_result['code'] == '200') {
          List<dynamic>? res = _result['result'];
          if (res != null && res[0] != null) {
            userLogin.value = res[0];
            box.write(KEY_MEMBER, jsonEncode(res[0]));
          }
        } else {
          Future.delayed(Duration(milliseconds: 900), () async {
            EasyLoading.showError('Error\n ${_result['message']}');
          });
        }
      }
    } catch (e) {
      print("Error\n $e");
    }
  }

  //push Login
  pushLogin(String? email, String? password) async {
    print("pushLogin isRunning...");

    dynamic member = userLogin.isEmpty ? {} : userLogin;
    try {
      //print(member);
      var json = {
        "id": member['id_install'] ?? '',
        "em": email ?? '',
        "ps": password ?? '',
        "ft": member['forgot_token'] ?? '',
        "tk": defToken.value,
        "ui": defUUID.value,
        "uf": "",
        "fr": GetPlatform.isAndroid ? "Android" : "iOS"
      };
      //print(jsonEncode(json));

      final response = await pushResponse('install/login', jsonEncode(json));
      if (response != null && response.statusCode == 200) {
        dynamic _result = jsonDecode(response.body);
        //print(_result);
        if (_result['code'] == '200') {
          List<dynamic>? res = _result['result'];
          if (res != null && res[0] != null) {
            userLogin.value = res[0];
            box.write(KEY_MEMBER, jsonEncode(res[0]));
            //print(res[0]);
          }
        } else {
          Future.delayed(Duration(milliseconds: 900), () async {
            EasyLoading.showError('Error\n ${_result['message']}');
          });
        }
      }
    } catch (e) {
      print("Error\n $e");
    }
  }

  //push register
  pushRegister(String? fullname, String? email, String? password) async {
    print("pushRegister isRunning...");

    dynamic member = userLogin.isEmpty ? {} : userLogin;
    try {
      var json = {
        "id": member['id_install'] ?? '',
        "nm": fullname ?? '',
        "em": email ?? '',
        "ps": password ?? '',
        "ft": member['forgot_token'] ?? '',
        "tk": defToken.value,
        "ui": defUUID.value,
        "uf": "",
        "fr": GetPlatform.isAndroid ? "Android" : "iOS"
      };
      //print(jsonEncode(json));

      final response = await pushResponse('install/register', jsonEncode(json));
      if (response != null && response.statusCode == 200) {
        dynamic _result = jsonDecode(response.body);
        //print(_result);
        if (_result['code'] == '200') {
          List<dynamic>? res = _result['result'];
          if (res != null && res[0] != null) {
            userLogin.value = res[0];
            box.write(KEY_MEMBER, jsonEncode(res[0]));
          }
        } else {
          Future.delayed(Duration(milliseconds: 900), () async {
            EasyLoading.showError('Error\n ${_result['message']}');
          });
        }
      }
    } catch (e) {
      print("Error\n $e");
    }
  }

  //for detail widget
  bool processGetSummaryDetail = false;
  final thisManagerB = ItemManager().obs;
  final itemTotalDetail = ItemTotal().obs;

  setDataMapDetail(final Map<String, double> dataMap, final int totalAmount) {
    itemTotalDetail.update((val) {
      val!.dataMap = null;
    });

    itemTotalDetail.update((val) {
      val!.dataMap = dataMap;
      val.totalAmount = totalAmount;
    });
  }

  setNullDataMap() {
    itemTotalDetail.update((val) {
      val!.dataMap = null;
    });
  }

  bool processGetSummaryByCategDetail = false;
  getSummaryIncomeByCategDetail(
      {int? categ = 1,
      String? paramDate,
      bool? isMonth = false,
      String? paramMonth}) async {
    //print(
    //    "getSummaryIncomeByCategDetail is categ $categ ${processGetSummaryByCategDetail ? 'waiting' : 'running'}...");
    if (processGetSummaryByCategDetail) {
      return;
    }

    processGetSummaryByCategDetail = true;
    Future.delayed(Duration(milliseconds: 600), () {
      processGetSummaryByCategDetail = false;
    });

    if (paramDate == null) {
      String firstDate =
          DateFormat('yyyy-MM-dd').format(dateTimeNow).toString();
      String dateTimeString = "$firstDate 00:00:00";
      final formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
      final dateTime = formatter.parse(dateTimeString);

      final firstWeek =
          XController.findFirstDateOfTheWeek(dateTime).millisecondsSinceEpoch;

      DateTime getEndWeek = XController.findLastDateOfTheWeek(dateTimeNow);
      String lastDate = DateFormat('yyyy-MM-dd').format(getEndWeek).toString();
      String dateTimeLastString = "$lastDate 23:59:59"; //23:59:59
      final formatterLast = DateFormat('yyyy-MM-dd hh:mm:ss');
      DateTime last = formatterLast.parse(dateTimeLastString);
      final endWeek =
          XController.findLastDateOfTheWeek(last).millisecondsSinceEpoch;

      paramDate =
          " AND $columnCreated>=$firstWeek AND $columnCreated<=$endWeek ";
    }

    if (isMonth != null && isMonth) {
      paramDate = " AND $columnDate LIKE '%$paramMonth%' ";
    }

    //print("paramDate $paramDate");

    itemTotalDetail.update((val) {
      val!.total = 0;
      val.totalByType = 0;
    });

    final managerIncome = await managerProvider.getSumIncomeByCateg(
        categ: categ, params: paramDate);
    //print(managerIncome);

    //Future.delayed(Duration(milliseconds: 1200), () {
    itemTotalDetail.update((val) {
      val!.total = managerIncome!.amount.v!;
      val.totalByType = managerIncome.amount.v!;
    });
    //});
  }

  final itemThreeMonthDetail = ItemThreeMonth().obs;
  setFirstThreeMonthDetail() {
    //String year = DateFormat('yyyy').format(dateTimeNow).toString();
    String nameMonth = DateFormat('MMM').format(dateTimeNow).toString();
    THREE_MONTHS.forEach((dynamic element) {
      int index = THREE_MONTHS.indexOf(element);
      if (element['id'] == nameMonth) {
        setThreeMonthValueDetail("${element['title']}", index);
      }
    });
  }

  setThreeMonthValueDetail(final String threeMonth, final int index) {
    //print(
    //    "setThreeMonthValueDetail itemThreeMonthDetail: $threeMonth, index: $index");

    String year = DateFormat('yyyy').format(dateTimeNow).toString();
    String nameMonth = DateFormat('MMM').format(dateTimeNow).toString();

    String firstDate = DateFormat('yyyy-MM-dd').format(dateTimeNow).toString();
    String dateTimeString = "$firstDate 00:00:00";
    final formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
    final dateTime = formatter.parse(dateTimeString);

    String paramDate = getStringParamThreeMonth(index);

    itemThreeMonthDetail.update((val) {
      val!.month = "$threeMonth $year";
      val.firstMonth = nameMonth;
      val.firstYear = year;
      val.first = dateTime;
      val.index = index;
      val.paramDate = paramDate;
    });
  }

  getSummaryIncomeExpenseDetail(
      {int? tipe = 1,
      String? paramDate,
      bool? isMonth = false,
      String? paramMonth}) async {
    //print(
    //    "getSummaryIncomeExpenseDetail is tipe: $tipe ${processGetSummaryDetail ? 'waiting' : 'running'}...");
    if (processGetSummaryDetail) {
      return;
    }

    processGetSummaryDetail = true;
    Future.delayed(Duration(milliseconds: 600), () {
      processGetSummaryDetail = false;
    });

    thisManagerB.update((val) {
      val!.managerIncome = DbManager();
      val.managerExpense = DbManager();
    });

    itemTotalDetail.update((val) {
      val!.total = 0;
      val.totalByType = 0;
    });

    if (paramDate == null) {
      String firstDate =
          DateFormat('yyyy-MM-dd').format(dateTimeNow).toString();
      String dateTimeString = "$firstDate 00:00:00";
      final formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
      final dateTime = formatter.parse(dateTimeString);
      final firstWeek =
          XController.findFirstDateOfTheWeek(dateTime).millisecondsSinceEpoch;

      DateTime getEndWeek = XController.findLastDateOfTheWeek(dateTimeNow);
      String lastDate = DateFormat('yyyy-MM-dd').format(getEndWeek).toString();
      String dateTimeLastString = "$lastDate 23:59:59"; //23:59:59
      final formatterLast = DateFormat('yyyy-MM-dd hh:mm:ss');
      DateTime last = formatterLast.parse(dateTimeLastString);
      final endWeek =
          XController.findLastDateOfTheWeek(last).millisecondsSinceEpoch;

      paramDate =
          " AND $columnCreated>=$firstWeek AND $columnCreated<=$endWeek ";
    }

    if (isMonth != null && isMonth) {
      paramDate = " AND $columnDate LIKE '%$paramMonth%' ";
    }

    //print("paramDate getSummaryIncomeExpenseDetail: $paramDate");

    final managerIncome =
        await managerProvider.getSumTotalByType(tipe: 1, params: paramDate);
    final managerExpense =
        await managerProvider.getSumTotalByType(tipe: 2, params: paramDate);

    //print(managerIncome);
    //print(managerExpense);
    //

    Future.delayed(Duration(milliseconds: 600), () {
      thisManagerB.update((val) {
        val!.managerIncome = managerIncome;
        val.managerExpense = managerExpense;
      });

      itemTotalDetail.update((val) {
        val!.total = managerIncome!.amount.v! - managerExpense!.amount.v!;
        val.totalByType =
            tipe == 1 ? managerIncome.amount.v! : managerExpense.amount.v!;
      });
    });
  }

  static shareContent(String? path) {
    String linkToDownload = GetPlatform.isAndroid
        ? "https://play.google.com/store/apps"
        : "https://apps.apple.com/us/developer/";
    String text = "Download $APP_NAME\nDownload $linkToDownload";

    if (path == null) {
      Share.share(text, subject: 'Share $APP_NAME');
    } else {
      Share.shareFiles([path], subject: "Image Share $APP_NAME", text: text);
    }
  }

  static launchURL(url) async {
    final String encodedURl = Uri.encodeFull(url);

    if (await canLaunch(encodedURl)) {
      await launch(encodedURl);
    } else {
      print('Could not launch $encodedURl');
      throw 'Could not launch $encodedURl';
    }
  }

  static formatDateByDatetime(DateTime dateUpdate) {
    return DateFormat('E, dd MMM yyyy', 'en_US').format(dateUpdate).toString();
  }

  static DateTime findFirstDateOfTheWeek(DateTime dateTime) {
    return dateTime.subtract(Duration(days: dateTime.weekday - 1));
  }

  static DateTime findLastDateOfTheWeek(DateTime dateTime) {
    return dateTime
        .add(Duration(days: DateTime.daysPerWeek - dateTime.weekday));
  }

  static bool isValidEmail(String email) => RegExp(
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(email);

  numberFormat(int number) {
    final NumberFormat numberFormat =
        NumberFormat.currency(symbol: "", decimalDigits: 0);

    return numberFormat.format(number);
  }

  static Widget photoView(photoUrl) {
    return Scaffold(
      appBar: AppBar(
        brightness: Get.theme.brightness,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Get.back();
          },
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Get.theme.backgroundColor,
        padding: const EdgeInsets.all(0.0),
        alignment: Alignment.topLeft,
        child: PhotoView(
          loadingBuilder: (context, event) => Center(
            child: Container(
                child: SizedBox(
                    width: 30,
                    height: 30,
                    child: Center(child: CircularProgressIndicator()))),
          ),
          imageProvider: NetworkImage(
            '$photoUrl',
          ),
        ),
      ),
    );
  }

  distanceFormat(double meters) {
    double km = meters;
    if (meters > 0.0) {
      km = meters / 1000;
      return numberFormatDec(km, 2);
    } else {
      return numberFormatDec(km, 0);
    }
  }

  numberFormatDec(double number, int digit) {
    final NumberFormat numberFormat =
        NumberFormat.currency(symbol: "", decimalDigits: digit);

    return numberFormat.format(number);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // API Restufl JSON Backend utility
  final http.Client _client = http.Client();
  static const BASE_URL = "https://profme.online/";
  static const BASE_URL_API = "https://demo.profme.online/";
  static const BASE_URL_TOKEN = 'YWRtaW5AZXJoYWNvcnAuaWQ6YjFzbTFsbDRo';

  pushResponse(String path, dynamic body) async {
    try {
      var urlPush = BASE_URL_API + path;

      final response = await _client.post(
        Uri.parse(urlPush),
        body: body,
        headers: {
          "Authentication": "Basic $BASE_URL_TOKEN",
          "Content-type": "application/json"
        },
      ).timeout(
        Duration(seconds: 220),
      );
      return response;
    } catch (e) {}

    return null;
  }
}
