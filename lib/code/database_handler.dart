import 'package:sqflite/sqflite.dart';

Future<void> initDatabaseHandler() async {
  final db = DatabaseHandler();
  await db.initDatabase();
}

class DatabaseHandler {
  static final DatabaseHandler _instance = DatabaseHandler._internal();

  late Database db;
  String databasePath = "";

  DatabaseHandler._internal();
  Future<void> initDatabase() async {
    // 1. Get Database Path
    final String databaseDirPath = await getDatabasesPath();
    databasePath = "$databaseDirPath/database.db";

    // 2. open & init database
    db = await openDatabase(databasePath);
    await _initDatabaseTable();
  }
  Future<void> _initDatabaseTable() async {
    // todo : think of table structures
  }

  factory DatabaseHandler() {
    return _instance;
  }
}