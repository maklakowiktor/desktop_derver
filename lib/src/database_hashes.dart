import 'package:path/path.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const String tableHashes = 'hashes';

class HashesDatabase {
  // Constants
  static final HashesDatabase instance = HashesDatabase._init();
  static Database? _database;

  // Fields name in db
  static const String id = '_id';
  static const String hash = '_hash';

  // Mutable fields
  late DatabaseFactory databaseFactory;

  /// Constructor
  HashesDatabase._init();

  /// Getter for private fields '_database'
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('wktransport.db');
    _createDB(_database!);
    return _database!;
  }

  /// Init DB
  Future<Database> _initDB(String filePath) async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final dbPath = await databaseFactory.getDatabasesPath();
    final path = join(dbPath, filePath);
    print('dbPath: $path');

    return await databaseFactory.openDatabase(path);
  }

  /// Method for Creating db
  Future _createDB(Database db, [int version = 1]) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'VARCHAR(50) NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableHashes ( 
        $id $idType, 
        $hash $textType
      )
    ''');
  }

  /// Method for reading data from db
  Future create(Map<String, Object?> message) async {
    final db = await instance.database;

    final id = await db.insert(tableHashes, message);
  }

  /// Read message from db
  Future readMsg(int _id) async {
    final db = await instance.database;

    final hashes = await db.query(
      tableHashes,
      columns: [id, hash],
      where: '$id = $_id',
    );

    if (hashes.isNotEmpty) {
      return hashes.first;
    } else {
      throw Exception('ID $id not found');
    }
  }

  /// Read all messages from db
  Future<List<Map<String, Object?>>> readAllHashes() async {
    final db = await instance.database;

    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(tableHashes);

    return result.map((json) => json).toList();
  }

  /// Delete from db
  Future<int> delete(int msgId) async {
    final db = await instance.database;

    return await db.delete(
      tableHashes,
      where: '$id = $msgId',
    );
  }

  /// Closing method
  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
