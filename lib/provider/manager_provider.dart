import 'package:intl/intl.dart';
import 'package:mmanager/core/xcontroller.dart';
import 'package:mmanager/main.dart';
import 'package:tekartik_app_flutter_sqflite/sqflite.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';
import 'package:mmanager/model/model.dart';
import 'package:mmanager/model/model_constant.dart';

DbManager snapshotToManager(Map<String, Object?> snapshot) {
  return DbManager()..fromMap(snapshot);
}

class DbManagers extends ListBase<DbManager> {
  final List<Map<String, Object?>> list;
  late List<DbManager?> _cacheManagers;

  DbManagers(this.list) {
    _cacheManagers = List.generate(list.length, (index) => null);
  }

  @override
  DbManager operator [](int index) {
    return _cacheManagers[index] ??= snapshotToManager(list[index]);
  }

  @override
  int get length => list.length;

  @override
  void operator []=(int index, DbManager? value) => throw 'read-only';

  @override
  set length(int newLength) => throw 'read-only';
}

class DbManagerProvider {
  final XController x = XController.to;
  final lock = Lock(reentrant: true);
  final DatabaseFactory dbFactory;
  // ignore: close_sinks
  final _updateTriggerController = StreamController<bool>.broadcast();
  Database? db;

  DbManagerProvider(this.dbFactory);

  Future openPath(String path) async {
    db = await dbFactory.openDatabase(path,
        options: OpenDatabaseOptions(
            version: kVersion1,
            onCreate: (db, version) async {
              await _createDb(db);
            },
            onUpgrade: (db, oldVersion, newVersion) async {
              if (oldVersion < kVersion1) {
                await _createDb(db);
              }
            }));
  }

  void _triggerUpdate() {
    _updateTriggerController.sink.add(true);
  }

  Future<Database?> get ready async => db ??= await lock.synchronized(() async {
        if (db == null) {
          await open();
        }
        return db;
      });

  Future<DbManager?> getManager(int? id) async {
    var list = (await db!.query(tableManager,
        columns: [
          columnId,
          columnAmount,
          columnCategory,
          columnDescription,
          columnDate,
          columnPath,
          columnImage,
          columnType,
          columnCreated,
          columnUpdated
        ],
        where: '$columnId = ?',
        whereArgs: <Object?>[id]));
    if (list.isNotEmpty) {
      return DbManager()..fromMap(list.first);
    }
    return null;
  }

  final dateNow = DateFormat('E, dd MMM yyyy', 'en_US')
      .format(DateTime.now().toLocal())
      .toString();

  final timestamp = DateTime.now().toLocal().millisecondsSinceEpoch;

  Future _createDb(Database db) async {
    await db.execute('DROP TABLE If EXISTS $tableManager');
    await db.execute(
        'CREATE TABLE $tableManager($columnId INTEGER PRIMARY KEY, $columnAmount INTEGER, $columnCategory TEXT, $columnDescription TEXT, $columnDate TEXT, $columnPath TEXT, $columnImage TEXT, $columnType TEXT, $columnCreated INTEGER, $columnUpdated INTEGER, $columnStatus INTEGER)');
    await db.execute(
        'CREATE INDEX ManagersUpdated ON $tableManager ($columnUpdated)');

    /*await _saveManager(
        db,
        DbManager()
          ..title.v = 'Simple title'
          ..content.v = 'Simple content'
          ..date.v = 1);*/

    /*await _saveManager(
        db,
        DbManager()
          ..amount.v = 10000
          ..category.v = '1'
          ..desc.v =
              'Enter your description\n\nThis is a content. Just tap anywhere to edit the description.\n'
          ..date.v = '$dateNow'
          ..path.v = ''
          ..image.v = ''
          ..type.v = '1'
          ..created.v = timestamp
          ..updated.v = timestamp
          ..status.v = 1);*/

    //print("db created, insert 1 row manager...");
    _triggerUpdate();
  }

  Future truncate(Database db) async {
    await _createDb(db);
  }

  Future open() async {
    await openPath(await fixPath(dbName));
  }

  Future<String> fixPath(String path) async => path;

  /// Add or update a manager
  Future _saveManager(DatabaseExecutor? db, DbManager updatedManager) async {
    if (updatedManager.id.v != null) {
      await db!.update(tableManager, updatedManager.toMap(),
          where: '$columnId = ?', whereArgs: <Object?>[updatedManager.id.v]);
    } else {
      updatedManager.id.v =
          await db!.insert(tableManager, updatedManager.toMap());
    }
  }

  Future saveManager(DbManager updatedManager) async {
    await _saveManager(db, updatedManager);
    _triggerUpdate();
  }

  Future<void> deleteManager(int? id) async {
    await db!
        .delete(tableManager, where: '$columnId = ?', whereArgs: <Object?>[id]);
    _triggerUpdate();
  }

  var managersTransformer = StreamTransformer<List<Map<String, Object?>>,
      List<DbManager>>.fromHandlers(handleData: (snapshotList, sink) {
    sink.add(DbManagers(snapshotList));
  });

  var managerTransformer =
      StreamTransformer<Map<String, Object?>, DbManager?>.fromHandlers(
          handleData: (snapshot, sink) {
    sink.add(snapshotToManager(snapshot));
  });

  /// Listen for changes on any manager
  Stream<List<DbManager?>> onManagers(
      {int? tipe = 1,
      String? paramDate,
      bool? isMonth = false,
      String? paramMonth}) {
    // ignore: close_sinks
    late StreamController<DbManagers> ctlr;
    StreamSubscription? _triggerSubscription;

    Future<void> sendUpdate() async {
      var managers = await getListManagers(
          tipe: tipe,
          paramDate: paramDate,
          isMonth: isMonth,
          paramMonth: paramMonth);
      if (!ctlr.isClosed) {
        ctlr.add(managers);
      }
    }

    ctlr = StreamController<DbManagers>(onListen: () {
      sendUpdate();

      /// Listen for trigger
      _triggerSubscription = _updateTriggerController.stream.listen((_) {
        sendUpdate();
      });
    }, onCancel: () {
      _triggerSubscription?.cancel();
    });
    return ctlr.stream;
  }

  /// Listed for changes on a given manager
  Stream<DbManager?> onManager(int? id) {
    // ignore: close_sinks
    late StreamController<DbManager?> ctlr;
    StreamSubscription? _triggerSubscription;

    Future<void> sendUpdate() async {
      var manager = await getManager(id);
      if (!ctlr.isClosed) {
        ctlr.add(manager);
      }
    }

    ctlr = StreamController<DbManager?>(onListen: () {
      sendUpdate();

      /// Listen for trigger
      _triggerSubscription = _updateTriggerController.stream.listen((_) {
        sendUpdate();
      });
    }, onCancel: () {
      _triggerSubscription?.cancel();
    });
    return ctlr.stream;
  }

  //additional function
  Stream<List<DbManager?>> onManagersGroupBy(
      {int? tipe = 1,
      String? paramDate,
      bool? isMonth = false,
      String? paramMonth}) {
    // ignore: close_sinks
    late StreamController<DbManagers> ctlr;
    StreamSubscription? _triggerSubscription;

    //print("[onManagersGroupBy] type: $tipe");

    Future<void> sendUpdate() async {
      var managers = await getListManagersGroupBy(
          tipe: tipe,
          paramDate: paramDate,
          isMonth: isMonth,
          paramMonth: paramMonth);
      if (!ctlr.isClosed) {
        ctlr.add(managers);
      }
    }

    ctlr = StreamController<DbManagers>(onListen: () {
      sendUpdate();

      /// Listen for trigger
      _triggerSubscription = _updateTriggerController.stream.listen((_) {
        sendUpdate();
      });
    }, onCancel: () {
      _triggerSubscription?.cancel();
    });
    return ctlr.stream;
  }

  Future<DbManagers> getListManagersGroupBy(
      {int? tipe,
      int? offset,
      int? limit,
      bool? descending,
      String? paramDate,
      bool? isMonth = false,
      String? paramMonth}) async {
    // devPrint('fetching $offset $limit');

    if (paramDate == null) {
      String firstDate =
          DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
      String dateTimeString = "$firstDate 00:00:00";
      final formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
      final dateTime = formatter.parse(dateTimeString);

      final firstWeek =
          XController.findFirstDateOfTheWeek(dateTime).millisecondsSinceEpoch;
      final endWeek = XController.findLastDateOfTheWeek(DateTime.now())
          .millisecondsSinceEpoch;
      paramDate = " $columnCreated>=$firstWeek AND $columnCreated<=$endWeek ";
    }

    if (isMonth! && paramMonth != null) {
      paramDate = " $columnDate LIKE '%$paramMonth%' ";
    }

    //print("paramDate getListManagersGroupBy: $paramDate");

    String _sql =
        "SELECT COUNT($columnId) as $columnId, SUM($columnAmount) as $columnAmount, $columnCategory, $columnDescription, $columnDate,$columnPath, $columnImage, $columnType, $columnCreated, $columnUpdated FROM $tableManager WHERE $paramDate GROUP BY $columnCategory";

    if (tipe != 0) {
      _sql =
          "SELECT COUNT($columnId) as $columnId, SUM($columnAmount) as $columnAmount, $columnCategory, $columnDescription, $columnDate,$columnPath, $columnImage, $columnType, $columnCreated, $columnUpdated FROM $tableManager WHERE $paramDate AND $columnType=$tipe GROUP BY $columnCategory";
    }

    //print(_sql);

    var list = (await db!.rawQuery(_sql));
    final Map<String, double> data = new Map<String, double>();
    int totalAmount = 0;
    list.forEach((Map<String, dynamic> element) {
      //print("enterrr");
      //print(element['$columnCategory']);
      //print(element['$columnAmount']);
      //print(element['$columnId']);

      dynamic category = "Category";
      //bool isIncome = manager.type.v == '1';
      //income
      if (element['$columnType'] == '1') {
        category = CATEG_INCOMES[int.parse(element['$columnCategory'])];
      }
      //expense
      else if (element['$columnType'] == '2') {
        category = CATEG_EXPENSES[int.parse(element['$columnCategory'])];
      }
      data[category['title']] = double.parse('${element['$columnAmount']}');
      totalAmount = totalAmount + int.parse('${element['$columnAmount']}');
    });

    Future.delayed(Duration(milliseconds: 1200), () {
      XController.to.setDataMapDetail(data, totalAmount);
    });

    return DbManagers(list);
  }

  // get trans by categ by param
  Stream<List<DbManager?>> onManagersCategBy({
    int? tipe = 1,
    String? categ = "1",
    String? paramDate,
    bool? isMonth = false,
    String? paramMonth,
    String? query,
  }) {
    // ignore: close_sinks
    late StreamController<DbManagers> ctlr;
    StreamSubscription? _triggerSubscription;

    Future<void> sendUpdate() async {
      var managers = await getListManagersCategBy(
        categ: categ,
        tipe: tipe,
        paramDate: paramDate,
        isMonth: isMonth,
        paramMonth: paramMonth,
        query: query,
        limit: 200,
      );
      if (!ctlr.isClosed) {
        ctlr.add(managers);
      }
    }

    ctlr = StreamController<DbManagers>(onListen: () {
      sendUpdate();

      /// Listen for trigger
      _triggerSubscription = _updateTriggerController.stream.listen((_) {
        sendUpdate();
      });
    }, onCancel: () {
      _triggerSubscription?.cancel();
    });
    return ctlr.stream;
  }

  Future<DbManagers> getListManagersCategBy({
    int? tipe,
    String? categ,
    int? offset,
    int? limit,
    bool? descending,
    String? paramDate,
    bool? isMonth = false,
    String? paramMonth,
    String? query,
  }) async {
    //check paramDate is null
    if (paramDate != null) {
      paramDate =
          " $columnCategory='$categ' AND $columnType=$tipe AND $paramDate";
    } else
      paramDate = " $columnCategory='$categ' AND $columnType=$tipe ";

    if (isMonth! && paramMonth != null) {
      paramDate =
          " $columnCategory='$categ' AND $columnType=$tipe AND $columnDate LIKE '%$paramMonth%' ";
    }

    if (query != null && query.length > 0) {
      paramDate = " $paramDate AND $columnDescription LIKE '%$query%' ";
    }

    var list = (await db!.query(tableManager,
        columns: [
          columnId,
          columnAmount,
          columnCategory,
          columnDescription,
          columnDate,
          columnPath,
          columnImage,
          columnType,
          columnCreated,
          columnUpdated
        ],
        where: ' $paramDate ',
        orderBy: '$columnUpdated ${(descending ?? false) ? 'ASC' : 'DESC'}',
        limit: limit,
        offset: offset));

    return DbManagers(list);
  }

  Future<DbManager?> getSumTotalByType({int? tipe, String? params}) async {
    String _sql =
        "SELECT SUM($columnAmount) as total FROM $tableManager WHERE $columnType='$tipe' $params GROUP BY $columnType";
    //print(_sql);

    var list = (await db!.rawQuery(_sql));
    if (list.isNotEmpty) {
      Map<String, dynamic> result = list.first;
      //print(result);
      //print(result['total']);
      return DbManager()..amount.v = result['total'];
    }
    return DbManager()..amount.v = 0;
  }

  Future<DbManager?> getSumIncomeByCateg({int? categ, String? params}) async {
    String sql =
        "SELECT SUM($columnAmount) as total FROM $tableManager WHERE $columnCategory='$categ' AND  $columnType='1' $params GROUP BY $columnType";

    //print("getSumIncomeByCateg sql: $sql");

    var list = (await db!.rawQuery(sql));
    if (list.isNotEmpty) {
      Map<String, dynamic> result = list.first;
      //print(result);
      //print(result['total']);
      return DbManager()..amount.v = result['total'];
    }
    return DbManager()..amount.v = 0;
  }

  //additional function

  /// Don't read all fields
  Future<DbManagers> getListManagers(
      {int? tipe,
      int? offset,
      int? limit,
      bool? descending,
      String? paramDate,
      bool? isMonth = false,
      String? paramMonth}) async {
    // devPrint('fetching $offset $limit');

    if (paramDate == null) {
      String firstDate =
          DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
      String dateTimeString = "$firstDate 00:00:00";
      final formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
      final dateTime = formatter.parse(dateTimeString);

      final firstWeek =
          XController.findFirstDateOfTheWeek(dateTime).millisecondsSinceEpoch;
      final endWeek = XController.findLastDateOfTheWeek(DateTime.now())
          .millisecondsSinceEpoch;
      paramDate = " $columnCreated>=$firstWeek AND $columnCreated<=$endWeek ";
    }

    if (isMonth! && paramMonth != null) {
      paramDate = " $columnDate LIKE '%$paramMonth%' ";
    }

    //print("paramDate getListManagers: $paramDate");

    var list = (await db!.query(tableManager,
        columns: [
          columnId,
          columnAmount,
          columnCategory,
          columnDescription,
          columnDate,
          columnPath,
          columnImage,
          columnType,
          columnCreated,
          columnUpdated
        ],
        where: ' $paramDate ',
        orderBy: '$columnUpdated ${(descending ?? false) ? 'ASC' : 'DESC'}',
        limit: limit,
        offset: offset));

    if (tipe != 0) {
      list = (await db!.query(tableManager,
          columns: [
            columnId,
            columnAmount,
            columnCategory,
            columnDescription,
            columnDate,
            columnPath,
            columnImage,
            columnType,
            columnCreated,
            columnUpdated
          ],
          where: ' $paramDate AND $columnType=$tipe ',
          orderBy: '$columnUpdated ${(descending ?? false) ? 'ASC' : 'DESC'}',
          limit: limit,
          offset: offset));
    }
    return DbManagers(list);
  }

  Future clearAllManagers() async {
    await db!.delete(tableManager);
    _triggerUpdate();
  }

  Future close() async {
    await db!.close();
  }

  Future deleteDb() async {
    await dbFactory.deleteDatabase(await fixPath(dbName));
  }
}
