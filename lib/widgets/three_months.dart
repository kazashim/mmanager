import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:mmanager/core/xcontroller.dart';
import 'package:mmanager/widgets/weekly.dart';

class ThreeMonthsWidget extends StatelessWidget {
  final dynamic item;
  final VoidCallback callback;
  ThreeMonthsWidget({required this.item, required this.callback}) {
    final XController x = XController.to;
    x.getSummaryIncomeExpense(
        categ: this.item['categ'], paramDate: x.itemThreeMonth.value.paramDate);

    Future.delayed(Duration(milliseconds: 100), () async {
      if (this.item['categ'] > -1) {
        await x.getSummaryIncomeByCateg(
            categ: this.item['categ'],
            paramDate: x.itemThreeMonth.value.paramDate);
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
                  onPressed: () {
                    x.setLastThreeMonth(
                        x.itemThreeMonth.value.first!, this.item['categ']);
                  }),
              Obx(
                () => Text("${x.itemThreeMonth.value.month}"),
              ),
              IconButton(
                  icon: Icon(FeatherIcons.chevronRight,
                      size: 30, color: Colors.black54),
                  onPressed: () {
                    x.setNextThreeMonth(
                        x.itemThreeMonth.value.first!, this.item['categ']);
                  }),
            ],
          ),
          SizedBox(height: 10),
          WeeklyWidget.rowIncomeExpense(x),

          // latest trans weekly
          Obx(() => x.itemThreeMonth.value.paramDate == null
              ? Container()
              : WeeklyWidget.latestTransaction(x, this.callback,
                  isWeekly: true,
                  paramMonth: null,
                  getParamDate:
                      x.itemThreeMonth.value.paramDate!.substring(5))),
        ],
      ),
    );
  }
}
