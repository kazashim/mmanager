import 'package:mmanager/db/db.dart';
import 'package:mmanager/model/model_constant.dart';

class DbManager extends DbRecord {
  /*String columnId = '_id';
  String columnAmount = 'amount';
  String columnCategory = 'category';
  String columnDescription = 'description';
  String columnDate = 'datestr';
  String columnType = 'typestr';
  String columnCreated = 'created';
  String columnUpdated = 'updated';
  
  $columnId INTEGER PRIMARY KEY, $columnAmount INTEGER, $columnCategory TEXT, $columnDescription TEXT, $columnDate TEXT, $columnType TEXT, $columnCreated INTEGER, $columnUpdated INTEGER, $columnStatus INTEGER
  */

  final amount = intField(columnAmount);
  final category = stringField(columnCategory);
  final desc = stringField(columnDescription);
  final date = stringField(columnDate);
  final path = stringField(columnPath);
  final image = stringField(columnImage);
  final type = stringField(columnType);
  final created = intField(columnCreated);
  final updated = intField(columnUpdated);
  final status = intField(columnStatus);

  @override
  List<Field> get fields => [
        id,
        amount,
        category,
        desc,
        date,
        path,
        image,
        type,
        created,
        updated,
        status
      ];
}
