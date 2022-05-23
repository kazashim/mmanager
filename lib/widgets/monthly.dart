import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:mmanager/core/xcontroller.dart';
import 'package:mmanager/widgets/weekly.dart';

class MonthlyWidget extends StatelessWidget {
  final dynamic item;
  final VoidCallback callback;
  MonthlyWidget({required this.item, required this.callback}) {
    final XController x = XController.to;
    x.getSummaryIncomeExpense(
        categ: this.item['categ'],
        isMonth: true,
        paramMonth: "${x.itemMonth.value.month}");

    Future.delayed(Duration(milliseconds: 100), () async {
      if (this.item['categ'] > -1) {
        await x.getSummaryIncomeByCateg(
            categ: this.item['categ'],
            isMonth: true,
            paramMonth: "${x.itemMonth.value.month}");
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
                    x.setLastMonth(x.itemMonth.value.first!, false);
                  }),
              Obx(
                () => Text("${x.itemMonth.value.month}",
                    style: TextStyle(fontSize: 20)),
              ),
              IconButton(
                  icon: Icon(FeatherIcons.chevronRight,
                      size: 30, color: Colors.black54),
                  onPressed: () {
                    x.setNextMonth(x.itemMonth.value.first!, false);
                  }),
            ],
          ),
          SizedBox(height: 10),
          WeeklyWidget.rowIncomeExpense(x),

          // latest trans weekly
          WeeklyWidget.latestTransaction(x, this.callback,
              isWeekly: false, paramMonth: x.itemMonth.value.month)
        ],
      ),
    );
  }
}
