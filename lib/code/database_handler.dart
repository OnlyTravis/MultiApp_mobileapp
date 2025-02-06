import 'dart:async';

import 'package:multi_app/code/classes.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';

enum DatabaseTables {
  mangas,
  mangaTags;
}

Future<void> initDatabaseHandler() async {
  final db = DatabaseHandler();
  await db.initDatabase();
}

class DatabaseHandler {
  static final DatabaseHandler _instance = DatabaseHandler._internal();

  late Database db;
  Map<DatabaseTables, BehaviorSubject> streams = {};
  String databasePath = "";

  DatabaseHandler._internal();
  Future<void> initDatabase() async {
    // 1. Get Database Path
    final String databaseDirPath = await getDatabasesPath();
    databasePath = "$databaseDirPath/database.db";

    // 2. open & init database
    db = await openDatabase(databasePath);
    await _initDatabaseTable();

    // 3. Init Streams
    _initStreams();
  }
  Future<void> _initDatabaseTable() async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Mangas (
        ch_name TEXT,
        ch_link TEXT,
        en_name TEXT,
        en_link TEXT,
        jp_name TEXT,
        jp_link TEXT,
        img_link TEXT,

        rating REAL,
        tag_list TEXT,
        chapter_count INTEGER,
        length INTEGER,
        ended INTEGER,
        
        id INTEGER PRIMARY KEY AUTOINCREMENT
      );
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS MangaTags (
        name TEXT,
        icon INTEGER,
        count INTEGER,

        id INTEGER PRIMARY KEY AUTOINCREMENT
      );
    ''');
  }
  Future<void> _initStreams() async {
    for (final table in DatabaseTables.values) {
      streams[table] = BehaviorSubject();
    }
  }
  factory DatabaseHandler() => _instance;

  void notifyUpdate(DatabaseTables table) {
    streams[table]!.add("");
  }

  Future<void> createManga(Manga manga) async {
    final map = manga.toMap();
    map["id"] = null;
    await db.insert("Mangas", map);
  }
  Future<void> updateManga(Manga manga) async {
    await db.update("Mangas", manga.toMap(), where: "id = ${manga.id}");
  }
  Future<List<Manga>> getAllManga() async {
    final results = await db.rawQuery('''
      SELECT * FROM Mangas;
    ''');

    List<Manga> arr = [];
    for (final result in results) {
      arr.add(Manga.fromMap(result));
    }
    return arr;
  }

  Future<void> createMangaTag(MangaTag tag) async {
    final map = tag.toMap();
    map["id"] = null;
    await db.insert("MangaTags", map);
  }
  Future<void> updateMangaTag(MangaTag tag) async {
    await db.update("MangaTags", tag.toMap(), where: "id = ${tag.id}");
  }
  Future<List<MangaTag>> getAllMangaTag() async {
    final results = await db.rawQuery('''
      SELECT * FROM MangaTags;
    ''');

    List<MangaTag> arr = [];
    for (final result in results) {
      arr.add(MangaTag.fromMap(result));
    }
    return arr;
  }
}