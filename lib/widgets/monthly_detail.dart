import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:mmanager/core/xcontroller.dart';
import 'package:mmanager/widgets/weekly_detail.dart';

class MonthlyDetailWidget extends StatelessWidget {
  final dynamic item;
  MonthlyDetailWidget({@required this.item}) {
    final XController x = XController.to;
    x.setNullDataMap();

    x.getSummaryIncomeExpenseDetail(
        tipe: this.item['expense'] != null ? 2 : 1,
        isMonth: true,
        paramMonth: "${x.itemMonthDetail.value.month}");
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
                    x.setDataMapDetail({}, 0);
                    x.setLastMonth(x.itemMonthDetail.value.first!, true);
                  }),
              Obx(
                () => Text("${x.itemMonthDetail.value.month}",
                    style: TextStyle(fontSize: 20)),
              ),
              IconButton(
                  icon: Icon(FeatherIcons.chevronRight,
                      size: 30, color: Colors.black54),
                  onPressed: () {
                    x.setDataMapDetail({}, 0);
                    x.setNextMonth(x.itemMonthDetail.value.first!, true);
                  }),
            ],
          ),
          SizedBox(height: 10),
          WeeklyDetailWidget.widgetDetail(x, this.item['expense'] != null),

          // latest trans weekly
          WeeklyDetailWidget.latestTransaction(x,
              tipe: this.item['expense'] != null ? 2 : 1,
              isWeekly: false,
              paramMonth: x.itemMonthDetail.value.month)
        ],
      ),
    );
  }
}
