import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mmanager/core/xcontroller.dart';
import 'package:mmanager/main.dart';
import 'package:mmanager/model/model.dart';
import 'package:mmanager/model/model_constant.dart';
import 'package:mmanager/screens/add_income_screen.dart';
import 'package:mmanager/screens/add_new_screen.dart';
import 'package:mmanager/screens/expense_screen.dart';
import 'package:mmanager/screens/income_screen.dart';

class WeeklyWidget extends StatelessWidget {
  final dynamic item;
  final VoidCallback callback;

  WeeklyWidget({required this.item, required this.callback}) {
    final XController x = XController.to;
    final firstWeek = x.itemWeek.value.first!.millisecondsSinceEpoch;
    final endWeek = x.itemWeek.value.last!.millisecondsSinceEpoch;
    String paramDate =
        " AND $columnCreated>=$firstWeek AND $columnCreated<=$endWeek ";
    x.getSummaryIncomeExpense(categ: this.item['categ'], paramDate: paramDate);

    Future.delayed(Duration(milliseconds: 100), () async {
      if (this.item['categ'] > -1) {
        await x.getSummaryIncomeByCateg(
            categ: this.item['categ'], paramDate: paramDate);
      }
    });
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
                    x.setLastWeek(
                        x.itemWeek.value.first!, x.itemWeek.value.last!, false);
                  }),
              Obx(
                () => Text("${x.itemWeek.value.week}",
                    style: TextStyle(fontSize: 12)),
              ),
              IconButton(
                  icon: Icon(FeatherIcons.chevronRight,
                      size: 30, color: Colors.black54),
                  onPressed: () {
                    x.setNextWeek(
                        x.itemWeek.value.first!, x.itemWeek.value.last!, false);
                  }),
            ],
          ),
          SizedBox(height: 10),

          rowIncomeExpense(x),

          // latest trans weekly
          latestTransaction(x, this.callback, isWeekly: true)
        ],
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
                  () => x.thisManagerA.value.managerIncome != null &&
                          x.thisManagerA.value.managerIncome!.amount.v != null
                      ? Text(
                          "${x.numberFormat(x.thisManagerA.value.managerIncome!.amount.v!)}",
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
            x.adsHelper.interstitialAd.show();
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
                  () => x.thisManagerA.value.managerExpense != null &&
                          x.thisManagerA.value.managerExpense!.amount.v != null
                      ? Text(
                          "${x.numberFormat(x.thisManagerA.value.managerExpense!.amount.v!)}",
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

  static Widget latestTransaction(
      final XController x, final VoidCallback refreshClick,
      {bool? isWeekly, String? paramMonth, String? getParamDate}) {
    //print("latestTransaction: getParamDate: $getParamDate");

    return Container(
      width: Get.width,
      padding: EdgeInsets.only(left: 5, right: 5, top: 25, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            child: Text("Latest Transaction",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 15),
          createListTrans(x, refreshClick,
              isWeekly: isWeekly,
              paramMonth: paramMonth,
              getParamDate: getParamDate),
        ],
      ),
    );
  }

  static Widget createListTrans(
      final XController x, final VoidCallback refreshClick,
      {bool? isWeekly, String? paramMonth, String? getParamDate}) {
    final firstWeek = x.itemWeek.value.first!.millisecondsSinceEpoch;
    final endWeek = x.itemWeek.value.last!.millisecondsSinceEpoch;
    String paramDate =
        " $columnCreated>=$firstWeek AND $columnCreated<=$endWeek ";
    if (getParamDate != null) {
      paramDate = getParamDate;
    }

    //print("createListTrans: paramDate: $paramDate");

    return Container(
      child: StreamBuilder<List<DbManager?>>(
        stream: managerProvider.onManagers(
            tipe: 0,
            paramDate: paramDate,
            isMonth: !isWeekly!,
            paramMonth: paramMonth),
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

          return Column(
            children: managers.map((e) {
              int index = managers.indexOf(e);
              var manager = managers[index]!;
              DateTime dateUpdate = DateTime.fromMillisecondsSinceEpoch(
                manager.updated.v!,
              ).toLocal();

              final dateFormat = DateFormat('E, dd MMM yyyy', 'en_US')
                  .format(dateUpdate)
                  .toString();

              dynamic category = "Category";
              bool isIncome = manager.type.v == '1';
              //income
              if (manager.type.v == '1') {
                category = CATEG_INCOMES[int.parse(manager.category.v!)];
              }
              //expense
              else if (manager.type.v == '2') {
                category = CATEG_EXPENSES[int.parse(manager.category.v!)];
              }

              return InkWell(
                onTap: () async {
                  final getcallback = await Get.to(isIncome
                      ? AddIncomeScreen(
                          dbManager: manager,
                        )
                      : AddNewScreen(
                          dbManager: manager,
                        ));
                  if (getcallback != null) {
                    refreshClick();
                    //onClickItemToRefresh();

                  }
                },
                child: Container(
                  width: Get.width,
                  height: 90,
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
                            margin: EdgeInsets.only(right: 8),
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
                                margin: EdgeInsets.only(bottom: 5),
                                child: Text(
                                  "${category['title']}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ),
                              Text("$dateFormat",
                                  style:
                                      Get.theme.textTheme.bodyText1!.copyWith(
                                    color: Colors.grey[900],
                                    fontSize: 12,
                                  ))
                            ],
                          ),
                        ],
                      ),
                      // total trans
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        child: Text(
                          "${isIncome ? '' : '-'}${x.numberFormat(manager.amount.v!)}",
                          style: Get.theme.textTheme.bodyText1!.copyWith(
                              color: isIncome ? Colors.green : Colors.redAccent,
                              fontWeight: FontWeight.w800),
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
}
