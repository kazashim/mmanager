import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:mmanager/core/xcontroller.dart';
import 'package:mmanager/main.dart';
import 'package:mmanager/model/model.dart';
import 'package:mmanager/model/model_constant.dart';
import 'package:mmanager/pages/list_page.dart';
import 'package:mmanager/screens/expense_screen.dart';
import 'package:mmanager/screens/income_screen.dart';
import 'package:pie_chart/pie_chart.dart';

class WeeklyDetailWidget extends StatelessWidget {
  final dynamic item;
  WeeklyDetailWidget({@required this.item}) {
    final XController x = XController.to;
    x.setNullDataMap();

    final firstWeek = x.itemWeekDetail.value.first!.millisecondsSinceEpoch;
    final endWeek = x.itemWeekDetail.value.last!.millisecondsSinceEpoch;
    String paramDate =
        " AND $columnCreated>=$firstWeek AND $columnCreated<=$endWeek ";
    x.getSummaryIncomeExpenseDetail(
        paramDate: paramDate, tipe: this.item['expense'] != null ? 2 : 1);
  }

  @override
  Widget build(BuildContext context) {
    final XController x = XController.to;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  icon: Icon(FeatherIcons.chevronLeft,
                      size: 30, color: Colors.black54),
                  onPressed: () async {
                    x.setDataMapDetail({}, 0);
                    x.setLastWeek(x.itemWeekDetail.value.first!,
                        x.itemWeekDetail.value.last!, true);
                  }),
              Obx(
                () => Text("${x.itemWeekDetail.value.week}",
                    style: TextStyle(fontSize: 12)),
              ),
              IconButton(
                  icon: Icon(FeatherIcons.chevronRight,
                      size: 30, color: Colors.black54),
                  onPressed: () {
                    x.setDataMapDetail({}, 0);
                    x.setNextWeek(x.itemWeekDetail.value.first!,
                        x.itemWeekDetail.value.last!, true);
                  }),
            ],
          ),
          SizedBox(height: 10),

          widgetDetail(x, this.item['expense'] != null),

          // latest trans weekly
          latestTransaction(x,
              isWeekly: true, tipe: this.item['expense'] != null ? 2 : 1),
        ],
      ),
    );
  }

  static Widget widgetDetail(final XController x, final bool isExpense) {
    //print("widgetDetail: isExpense: $isExpense");

    if (isExpense) {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${x.defCurrency.value}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 19)),
                SizedBox(width: 8),
                Obx(
                  () => Text(
                      "${x.numberFormat(x.itemTotalDetail.value.totalByType!)}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                          fontSize: 19)),
                ),
              ],
            ),
            SizedBox(height: 20),
            createPieChart(x),
          ],
        ),
      );
    }

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${x.defCurrency.value}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 19)),
              SizedBox(width: 8),
              Obx(
                () => Text(
                    "${x.numberFormat(x.itemTotalDetail.value.totalByType!)}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 19)),
              ),
            ],
          ),
          SizedBox(height: 20),
          createPieChart(x),
        ],
      ),
    );
  }

  static createPieChart(final XController x) {
    return Obx(
      () => x.itemTotalDetail.value.dataMap != null &&
              x.itemTotalDetail.value.dataMap!.isNotEmpty
          ? Container(
              margin: EdgeInsets.only(bottom: 15),
              child: PieChart(
                dataMap: x.itemTotalDetail.value.dataMap!,
                animationDuration: Duration(milliseconds: 800),
                chartLegendSpacing: 32,
                chartRadius: Get.width / 3.7,
                colorList: colorList,
                initialAngleInDegree: 0,
                chartType: ChartType.ring,
                ringStrokeWidth: 20,
                centerText: "",
                legendOptions: LegendOptions(
                  showLegends: false,
                ),
                chartValuesOptions: ChartValuesOptions(
                  showChartValueBackground: true,
                  showChartValues: true, //false
                  showChartValuesInPercentage: true, //false
                  showChartValuesOutside: false,
                  decimalPlaces: 1,
                ),
              ),
            )
          : Container(
              child: Center(child: CircularProgressIndicator()),
            ),
    );
  }

  static Widget rowIncomeExpense(final XController x) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            Get.to(IncomeScreen(), transition: Transition.fadeIn);
          },
          child: Container(
            margin: EdgeInsets.only(right: 10, bottom: 5),
            padding: EdgeInsets.only(left: 20, right: 32, top: 15, bottom: 15),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  //spreadRadius: 0,
                  blurRadius: 5,
                  offset: Offset(2, 2),
                  // changes position of shadow
                ),
              ],
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 3),
                  child: Text(
                    "Income",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                Obx(
                  () => x.thisManagerB.value.managerIncome != null &&
                          x.thisManagerB.value.managerIncome!.amount.v != null
                      ? Text(
                          "${x.numberFormat(x.thisManagerB.value.managerIncome!.amount.v!)}",
                          style: Get.theme.textTheme.bodyText1!.copyWith(
                              fontSize: 18,
                              color: Colors.green,
                              fontWeight: FontWeight.w800),
                        )
                      : Container(
                          child: Center(child: CircularProgressIndicator())),
                )
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            Get.to(ExpenseScreen(), transition: Transition.cupertinoDialog);
          },
          child: Container(
            margin: EdgeInsets.only(right: 0, bottom: 5),
            padding: EdgeInsets.only(left: 20, right: 32, top: 15, bottom: 15),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  //spreadRadius: 0,
                  blurRadius: 5,
                  offset: Offset(2, 2),
                  // changes position of shadow
                ),
              ],
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 3),
                  child: Text(
                    "Expense",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                Obx(
                  () => x.thisManagerB.value.managerExpense != null &&
                          x.thisManagerB.value.managerExpense!.amount.v != null
                      ? Text(
                          "${x.numberFormat(x.thisManagerB.value.managerExpense!.amount.v!)}",
                          style: Get.theme.textTheme.bodyText1!.copyWith(
                              fontSize: 18,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w800),
                        )
                      : Container(
                          child: Center(child: CircularProgressIndicator())),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  static Widget latestTransaction(final XController x,
      {bool? isWeekly, String? paramMonth, int? tipe, String? getParamDate}) {
    return Container(
      width: Get.width,
      padding: EdgeInsets.only(left: 5, right: 5, top: 25, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            child: Text("Breakdown",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 15),
          createListTrans(x,
              isWeekly: isWeekly,
              paramMonth: paramMonth,
              tipe: tipe,
              getParamDate: getParamDate),
        ],
      ),
    );
  }

  //final mapStringGroup = Map<String, double>().obs;
  //final Map<String, double> data = new Map<String, double>();

  static Widget createListTrans(final XController x,
      {bool? isWeekly, String? paramMonth, int? tipe, String? getParamDate}) {
    //mapStringGroup.value = {"category": 0};
    final firstWeek = x.itemWeekDetail.value.first!.millisecondsSinceEpoch;
    final endWeek = x.itemWeekDetail.value.last!.millisecondsSinceEpoch;
    String paramDate =
        " $columnCreated>=$firstWeek AND $columnCreated<=$endWeek ";

    if (getParamDate != null) {
      paramDate = getParamDate;
    }

    //print("WeeklyDetail createListTrans: paramDate: $paramDate");

    return Container(
      child: StreamBuilder<List<DbManager?>>(
        stream: managerProvider.onManagersGroupBy(
            tipe: tipe,
            isMonth: !isWeekly!,
            paramMonth: paramMonth,
            paramDate: paramDate),
        builder: (context, snapshot) {
          var managers = snapshot.data;
          //print(managers);

          if (managers == null) {
            return Container(
              color: Colors.transparent,
              alignment: Alignment.center,
              width: Get.width,
              height: 35,
              child: SizedBox(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }

          if (managers.length < 1) {
            return Container(
              color: Colors.transparent,
              alignment: Alignment.center,
              width: Get.width,
              height: 120,
              child: SizedBox(
                child: Center(
                  child: InkWell(
                    onTap: () {
                      Get.to(IncomeScreen(), transition: Transition.fadeIn);
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 10, bottom: 5),
                      padding: EdgeInsets.only(
                          left: 20, right: 32, top: 15, bottom: 15),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            //spreadRadius: 0,
                            blurRadius: 5,
                            offset: Offset(2, 2),
                            // changes position of shadow
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 3),
                            child: Text(
                              "No transaction found",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ),
                          Text(
                            "Click + button to add new transaction",
                            style: Get.theme.textTheme.bodyText1!.copyWith(
                                fontSize: 18,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          //data = null;
          return Column(
            children: managers.map((e) {
              int index = managers.indexOf(e);
              var manager = managers[index]!;

              dynamic category = "Category";
              bool isExpense = manager.type.v == '2';
              //income
              if (manager.type.v == '1') {
                category = CATEG_INCOMES[int.parse(manager.category.v!)];
              }
              //expense
              else if (manager.type.v == '2') {
                category = CATEG_EXPENSES[int.parse(manager.category.v!)];
              }

              //data[category['title']] = double.parse("${manager.amount.v!}");
              //mapStringGroup.value = MapEntry<String, double>("ttitle", 0);

              return InkWell(
                onTap: () {
                  Map<String, dynamic> item = {
                    "title": "${category['title']} Detail",
                    "categ": "${manager.category.v!}",
                    "tipe": tipe,
                    "isMonth": !isWeekly,
                    "paramMonth": paramMonth,
                    "paramDate": paramDate,
                  };

                  //print(item);
                  Get.to(ManagerListPage(item, colorList[index]));
                },
                child: Container(
                  width: Get.width,
                  height: 70,
                  margin: EdgeInsets.only(right: 0, bottom: 18),
                  padding:
                      EdgeInsets.only(left: 10, right: 12, top: 15, bottom: 15),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        //spreadRadius: 0,
                        blurRadius: 5,
                        offset: Offset(2, 2),
                        // changes position of shadow
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 3),
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 30,
                              child: Icon(FeatherIcons.grid),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 0),
                                child: Text(
                                  "${category['title']}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 5),
                                    child: CircleAvatar(
                                      backgroundColor: colorList[index],
                                      radius: 7,
                                    ),
                                  ),
                                  Obx(
                                    () => Text(
                                      //"${manager.amount.v! / x.itemTotalDetail.value.totalAmount!}",
                                      "${countPercentTotal(x, manager.amount.v!, x.itemTotalDetail.value.totalAmount!)}",
                                      style: Get.theme.textTheme.bodyText1!
                                          .copyWith(
                                        color: Colors.grey[900],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                      // total trans
                      Container(
                        margin: EdgeInsets.only(top: 0),
                        child: Center(
                          child: Text(
                            "${isExpense ? '-' : ''}${x.numberFormat(manager.amount.v!)}",
                            style: Get.theme.textTheme.bodyText1!.copyWith(
                                color:
                                    isExpense ? Colors.redAccent : Colors.green,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  static String countPercentTotal(
      final XController x, final int amount, final int totalAmount) {
    String result = "100%";
    double dbl = amount / totalAmount * 100;

    //"${manager.amount.v! / x.itemTotalDetail.value.totalAmount!}%"
    result = x.numberFormatDec(dbl, 1);
    return "$result%";
  }
}
