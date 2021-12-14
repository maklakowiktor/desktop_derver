import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHandler {
  late DatabaseFactory databaseFactory;
  late Database _db;

  String _TABLE_NAME = 'Hashes';

  static DatabaseHandler? _instance;

  DatabaseHandler._() {
    init();
  }

  factory DatabaseHandler() {
    return _instance ??= DatabaseHandler._();
  }

  void init() {
    sqfliteFfiInit();

    databaseFactory = databaseFactoryFfi;
    print('Intitialization has been finished successfully');
  }

  void onCreate() async {
    // Открываем соедиение с БД
    _db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    print('Path: $inMemoryDatabasePath');

    // Выполняем запрос на создание БД
    await _db.execute('''
      CREATE TABLE $_TABLE_NAME (
        id INTEGER PRIMARY KEY,
        msg TEXT
      )
    ''');

    // await _db.close();
    print('Table $_TABLE_NAME was created');
  }

  void addHashes(Function callback) async {
    try {
      // Открываем соедиение с БД
      // _db = await databaseFactory.openDatabase(inMemoryDatabasePath);

      // Добавляем новые хэши в бд
      await _db.insert("$_TABLE_NAME", <String, Object?>{'msg': 'Qa3fs0z10'});
      await _db.insert('$_TABLE_NAME', <String, Object?>{'msg': '0zl49sg8a'});

      print('+2 new writes 🎉');

      // await _db.close();
      callback(1);
    } catch (err) {
      print(err);
    }
  }

  dynamic getHashes() async {
    // Открываем соедиение с БД
    // _db = await databaseFactory.openDatabase(inMemoryDatabasePath);

    var result = await _db.query('Hashes');

    // await _db.close();
    return result;
  }
}

DatabaseHandler DBHandler = DatabaseHandler();
