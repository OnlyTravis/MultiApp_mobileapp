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
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Mangas (
        id INTEGER

        ch_name TEXT
        ch_link TEXT
        en_name TEXT
        en_link TEXT
        jp_name TEXT
        jp_link TEXT
        img_link TEXT

        rating REAL
        tag_list TEXT
        chapter_count INTEGER
        length INTEGER
        ended INTEGER
      );
      CREATE TABLE IF NOT EXISTS MangaTags (
        name TEXT
        id INTEGER
        color INTEGER
        count INTEGER
      );
    ''');
  }
  factory DatabaseHandler() {
    return _instance;
  }
}