import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mmanager/core/xcontroller.dart';

class AmountIncome extends StatelessWidget {
  final int? type;
  final bool? show;
  //final int? total;
  AmountIncome({this.type, this.show});

  @override
  Widget build(BuildContext context) {
    //print("rebuild.. AmountIncome this.type: ${this.type}");

    final XController x = XController.to;
    return Container(
      child: this.show!
          ? SizedBox(
              width: 30,
              height: 30,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          : Obx(
              () => Text(
                "${x.defCurrency.value} ${totalAmount(x, this.type!, x.itemTotalCateg.value.total!)}",
                //"IDR ${x.numberFormat(x.itemTotal.value.total!)}",
                style: Get.theme.textTheme.headline6!.copyWith(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w800),
              ),
            ),
    );
  }

  String totalAmount(final XController x, final int type, final int total) {
    String result = "${x.numberFormat(x.itemTotalCateg.value.total!)}";

    //print("totalAmount: $result");

    switch (type) {
      case 2:
        result = "${x.numberFormat(x.itemTotalCateg.value.totalByType!)}";
        break;
      default:
    }

    return result;
  }
}
