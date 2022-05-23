import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:mmanager/core/xcontroller.dart';
import 'package:mmanager/widgets/weekly_detail.dart';

class ThreeMonthsDetailWidget extends StatelessWidget {
  final dynamic item;
  ThreeMonthsDetailWidget({required this.item}) {
    final XController x = XController.to;
    x.setNullDataMap();

    x.getSummaryIncomeExpenseDetail(
        tipe: this.item['expense'] != null ? 2 : 1,
        paramDate: x.itemThreeMonthDetail.value.paramDate);
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
                    x.setLastThreeMonthDetail(
                        x.itemThreeMonthDetail.value.first!,
                        this.item['expense'] != null ? 2 : 1);
                  }),
              Obx(
                () => Text("${x.itemThreeMonthDetail.value.month}"),
              ),
              IconButton(
                  icon: Icon(FeatherIcons.chevronRight,
                      size: 30, color: Colors.black54),
                  onPressed: () {
                    x.setDataMapDetail({}, 0);
                    x.setNextThreeMonthDetail(
                        x.itemThreeMonthDetail.value.first!,
                        this.item['expense'] != null ? 2 : 1);
                  }),
            ],
          ),
          SizedBox(height: 10),
          WeeklyDetailWidget.widgetDetail(x, this.item['expense'] != null),

          // latest trans weekly
          Obx(() => x.itemThreeMonthDetail.value.paramDate == null
              ? Container()
              : WeeklyDetailWidget.latestTransaction(x,
                  tipe: this.item['expense'] != null ? 2 : 1,
                  isWeekly: true,
                  paramMonth: null,
                  getParamDate:
                      x.itemThreeMonthDetail.value.paramDate!.substring(5))),
        ],
      ),
    );
  }
}
