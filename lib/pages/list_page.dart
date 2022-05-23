import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mmanager/core/xcontroller.dart';
import 'package:mmanager/main.dart';
import 'package:mmanager/model/model.dart';
import 'package:mmanager/screens/add_income_screen.dart';
import 'package:mmanager/screens/add_new_screen.dart';

class ManagerListPage extends StatelessWidget {
  final dynamic item;
  final Color color;
  ManagerListPage(this.item, this.color);

  final isSearch = false.obs;
  final query = "".obs;

  @override
  Widget build(BuildContext context) {
    final XController x = XController.to;
    return Container(
      width: Get.width,
      height: Get.height,
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        top: false,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: backgroundColor,
            iconTheme: IconThemeData(color: Colors.black87),
            title: Obx(
              () => isSearch.value
                  ? createInputSearch()
                  : Text(
                      "${item['title']}",
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.bold),
                    ),
            ),
            centerTitle: true,
            elevation: 0.25,
            actions: [
              IconButton(
                icon: CircleAvatar(
                  backgroundColor: mainColor,
                  radius: 30,
                  child: Obx(
                    () => isSearch.value
                        ? Icon(
                            FeatherIcons.x,
                            color: Colors.white,
                            size: 18,
                          )
                        : Icon(
                            FeatherIcons.search,
                            color: Colors.white,
                            size: 18,
                          ),
                  ),
                ),
                onPressed: () {
                  isSearch.value = !isSearch.value;
                },
              )
            ],
          ),
          body: Column(
            children: [
              SizedBox(height: 15),
              Obx(
                () => createListStream(x, query.value),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final TextEditingController queryController = TextEditingController();
  Widget createInputSearch() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: queryController,
            onChanged: (String? text) {
              query.value = text!.trim();
            },
            decoration: new InputDecoration(
              hintText: "Type keyword...",
            ),
            keyboardType: TextInputType.text,
          ),
        ],
      ),
    );
  }

  Widget createListStream(final XController x, final String query) {
    return Flexible(
      child: StreamBuilder<List<DbManager?>>(
        stream: managerProvider.onManagersCategBy(
            categ: "${this.item['categ']}",
            tipe: this.item['tipe'],
            isMonth: this.item['isMonth'],
            paramMonth: this.item['paramMonth'],
            paramDate: this.item['paramDate'],
            query: query),
        builder: (context, snapshot) {
          var managers = snapshot.data;
          if (managers == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
              itemCount: managers.length,
              itemBuilder: (context, index) {
                var manager = managers[index]!;
                bool isExpense = manager.type.v == '2';
                DateTime dateUpdate = DateTime.fromMillisecondsSinceEpoch(
                  manager.updated.v!,
                ).toLocal();

                final dateFormat = DateFormat('E, dd MMM yyyy', 'en_US')
                    .format(dateUpdate)
                    .toString();

                return InkWell(
                  onTap: () async {
                    final getcallback = await Get.to(isExpense
                        ? AddNewScreen(
                            dbManager: manager,
                          )
                        : AddIncomeScreen(
                            dbManager: manager,
                          ));
                    if (getcallback != null) {
                      //refreshClick();
                      //onClickItemToRefresh();
                      Get.back();
                    }
                  },
                  child: Container(
                    width: Get.width,
                    height: 100,
                    margin: EdgeInsets.only(right: 15, left: 15, bottom: 15),
                    padding: EdgeInsets.only(
                        left: 10, right: 12, top: 15, bottom: 15),
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
                              margin: EdgeInsets.only(right: 8, left: 0),
                              padding: EdgeInsets.all(5),
                              child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                radius: 8,
                                child: CircleAvatar(
                                  backgroundColor: this.color,
                                  radius: 8,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: 0),
                                  child: Text(
                                    "$dateFormat",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                                Container(
                                  width: Get.width / 2.6,
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          "${manager.desc.v}",
                                          maxLines: 3,
                                          style: Get.theme.textTheme.bodyText1!
                                              .copyWith(
                                            color: Colors.grey[900],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                                  color: isExpense
                                      ? Colors.redAccent
                                      : Colors.green,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              });
        },
      ),
    );
  }
}
