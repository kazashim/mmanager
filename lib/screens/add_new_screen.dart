import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:mmanager/core/xcontroller.dart';
import 'package:mmanager/main.dart';
import 'package:intl/intl.dart';
import 'package:mmanager/model/model.dart';

class AddNewScreen extends StatelessWidget {
  final DbManager? dbManager;
  AddNewScreen({this.dbManager}) {
    if (dbManager != null) {
      Future.delayed(Duration(milliseconds: 400), () {
        amountController.text = "${dbManager!.amount.v}";
        dateController.text = "${dbManager!.date.v}";
        noteController.text = "${dbManager!.desc.v}";

        int categ = int.parse(dbManager!.category.v!);
        idSelectedCateg.value = "${categ + 1}";
      });
    }

    Future.delayed(Duration(seconds: 3), () {
      print("show interstitial");
      XController.to.adsHelper.interstitialAd.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    final XController x = XController.to;
    return Container(
      width: Get.width,
      height: Get.height,
      color: Color(0xfff5f6fa),
      child: SafeArea(
        bottom: false,
        top: false,
        child: Scaffold(
          backgroundColor: Color(0xfff5f6fa),
          appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(FeatherIcons.chevronLeft,
                  size: 32, color: Colors.black54),
              onPressed: () {
                Get.back();
              },
            ),
            elevation: 0.25,
            backgroundColor: Color(0xfff5f6fa),
            // Here we take the value from the MyAddNewScreen object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(
              "${this.dbManager != null ? 'Update' : 'New'} Transaction",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              if (this.dbManager != null)
                IconButton(
                    icon: CircleAvatar(
                      backgroundColor: mainColor,
                      radius: 30,
                      child:
                          Icon(FeatherIcons.x, color: Colors.white, size: 18),
                    ),
                    onPressed: () {
                      confirmDeleteItem();
                    })
            ],
          ),
          body: Container(
            width: Get.width,
            height: Get.height,
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: Get.width,
                        padding: EdgeInsets.only(right: 10),
                        child: Text("${x.dateNowApps.value}",
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.grey[700])),
                      ),
                      amountForm(x),
                      dropdownForm(),
                      dateForm(),
                      noteForm(),
                      SizedBox(height: 120),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 10,
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: mainColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        padding: EdgeInsets.only(bottom: 5, top: 5),
                      ),
                      onPressed: () async {
                        String amount = amountController.text;
                        if (amount == '') {
                          EasyLoading.showToast("Amount invalid...");
                          return;
                        }

                        String note = noteController.text;
                        if (note == '') {
                          EasyLoading.showToast("Description note invalid...");
                          return;
                        }

                        DateTime selectedDate = currentDateToSave.value;
                        String dateNow = DateFormat('E, dd MMM yyyy', 'en_US')
                            .format(selectedDate)
                            .toString();

                        managerProvider.saveManager(DbManager()
                          ..id.v = (this.dbManager != null)
                              ? this.dbManager!.id.v
                              : null
                          ..amount.v = int.parse(amount)
                          ..category.v =
                              '${int.parse(idSelectedCateg.value) - 1}'
                          ..desc.v = '$note'
                          ..date.v = '$dateNow'
                          ..path.v = ''
                          ..image.v = ''
                          ..type.v = '2'
                          ..created.v = selectedDate.millisecondsSinceEpoch
                          ..updated.v = selectedDate.millisecondsSinceEpoch
                          ..status.v = 1);

                        EasyLoading.showToast('Process success');
                        Get.back(result: {"success": "1"});
                        //XController.to.getSummaryIncomeExpense();
                      },
                      child: Container(
                        padding: EdgeInsets.only(bottom: 10, top: 10),
                        child: Text("SAVE"),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ),
      ),
    );
  }

  confirmDeleteItem() async {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            height: 200.0,
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Delete confirmation\nAre you sure to delete it?\n",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        width: (Get.width / 3.5),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        Get.back();
                        await managerProvider
                            .deleteManager(this.dbManager!.id.v);
                        EasyLoading.showToast("Item note deleted...");
                        Future.delayed(Duration(milliseconds: 1200), () {
                          Get.back(result: {"deleted": "1"});
                        });
                      },
                      child: Container(
                        width: (Get.width / 3.5),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: mainColor,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  final TextStyle titleStyle = TextStyle(color: Colors.grey[600]);
  final TextEditingController amountController = new TextEditingController();
  Widget amountForm(final XController x) {
    return Container(
        margin: EdgeInsets.only(top: 10),
        padding: EdgeInsets.only(top: 10, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Amount", style: titleStyle),
            Row(
              children: [
                Text("${x.defCurrency.value}",
                    style: Get.theme.textTheme.headline6!
                        .copyWith(fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Flexible(
                  child: TextField(
                    controller: amountController,
                    style: TextStyle(color: Colors.redAccent, fontSize: 20),
                    keyboardType: TextInputType.number,
                    decoration: new InputDecoration(
                      hintText: "1000000",
                      //labelText: "Email",
                      //labelStyle:
                      //    new TextStyle(color: const Color(0xFF424242))
                    ),
                  ),
                )
              ],
            )
          ],
        ));
  }

  final idSelectedCateg = "1".obs;

  Widget dropdownForm() {
    var categoryModelList = [];
    CATEG_EXPENSES.forEach((e) =>
        categoryModelList.add(CategoryModel(e['id'], e['title'], e['icon'])));

    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("Category", style: titleStyle),
          InputDecorator(
            //expands: false,
            decoration: InputDecoration(
              icon: Icon(Icons.grid_view),
              contentPadding: EdgeInsets.only(top: 0),
              //labelText: 'Color',
            ),
            child: DropdownButtonHideUnderline(
              child: Container(
                padding: EdgeInsets.all(0.0),
                child: Obx(
                  () => DropdownButton<String>(
                      itemHeight: 50,
                      value: "${idSelectedCateg.value}",
                      icon: Icon(
                        FeatherIcons.chevronDown,
                      ),
                      items: categoryModelList.map((map) {
                        CategoryModel categ = map;
                        return new DropdownMenuItem<String>(
                          value: categ.id,
                          child: Container(
                            child: Text(
                              categ.title,
                              style: new TextStyle(color: Colors.black),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        print(value);
                        idSelectedCateg.value = value!;
                        //setState(() {
                        //  _value = value;
                        //});
                      }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  final dateNow = DateFormat('E, dd MMM yyyy', 'en_US')
      .format(DateTime.now().toLocal())
      .toString();
  final dateSelected = "".obs;
  final TextEditingController dateController = new TextEditingController();

  Widget dateForm() {
    dateSelected.value = dateNow;
    dateController.text = "$dateNow";

    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.only(top: 10, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("Date", style: titleStyle),
          TextField(
            controller: dateController,
            decoration: new InputDecoration(
              hintText: "${dateSelected.value}",
            ),
            onTap: () {
              print("ontap");
              _selectDate();
            },
            readOnly: true,
          )
        ],
      ),
    );
  }

  final DateTime selectedDate = DateTime.now();
  final currentDateToSave = DateTime.now().toLocal().obs;

  _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.toLocal(), // Refer step 1
      firstDate: DateTime(2021), //selectedDate.toLocal(),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      currentDateToSave.value = picked.toLocal();
      dateSelected.value = DateFormat('E, dd MMM yyyy', 'en_US')
          .format(picked.toLocal())
          .toString();
      dateController.text = "${dateSelected.value}";
    }
  }

  final TextEditingController noteController = new TextEditingController();
  Widget noteForm() {
    return Container(
        margin: EdgeInsets.only(top: 20),
        padding: EdgeInsets.only(top: 10, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Note", style: titleStyle),
            TextField(
              controller: noteController,
              decoration: new InputDecoration(
                hintText: "Buy something new",
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 3,
            )
          ],
        ));
  }
}
