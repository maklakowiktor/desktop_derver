import 'package:path/path.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

///
///
///
///
/// https://www.youtube.com/watch?v=UpKrhZ0Hppk&ab_channel=JohannesMilke
/// https://github.com/JohannesMilke/sqflite_database_example/blob/master/lib/db/notes_database.dart
///
///
///

final String tableHashes = 'hashes';

class HashesDatabase {
  // Constants
  static final HashesDatabase instance = HashesDatabase._init();
  static Database? _database;
  static final String id = '_id';
  static final String hash = '_id';

  // Mutable fields
  late DatabaseFactory databaseFactory;
  String? _path;

  // Constructor
  HashesDatabase._init();

  // Getter for private fields '_database'
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('wktransport.db');
    return _database!;
  }

  // Init
  Future<Database> _initDB(String filePath) async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbPath = await databaseFactory.getDatabasesPath();
    final path = join(dbPath, filePath);

    return await databaseFactory.openDatabase(path);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';
    final boolType = 'BOOLEAN NOT NULL';
    final integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE $tableHashes ( 
        $id $idType, 
        $hash $textType,
        )
    ''');
  }

  /// ******************************* My Art *************************
  void onCreate() async {
    // Открываем connection с БД
    _database = await databaseFactory.openDatabase(
      'wktransport.db',
    );

    try {
      // Выполняем запрос на создание БД
      await _database.execute('''
        CREATE TABLE IF NOT EXISTS $_TABLE_NAME (
          id INTEGER PRIMARY KEY,
          hash TEXT
        )
      ''');

      print('Table "$_TABLE_NAME" was created');
      print('Intitialization has been finished successfully 🎉');
    } catch (err) {
      print('❌ $err');
    }

    // await _database.close();
  }

  void addHashes(Function callback) async {
    if (!_database.isOpen) return;

    try {
      // Добавляем новые хэши в бд
      await _database
          .insert("$_TABLE_NAME", <String, Object?>{'hash': 'Qa3fs0z10'});
      await _database
          .insert('$_TABLE_NAME', <String, Object?>{'hash': '0zl49sg8a'});

      print('+2 new writes 🎉');

      callback('+2 new writes 🎉');
    } catch (err) {
      print(err);
    }
  }

  Future getHashes() async {
    var result = await _database.query('Hashes');

    return result;
  }
}

HashesDatabase DBHandler = HashesDatabase();
