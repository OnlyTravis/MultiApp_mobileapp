import 'dart:async';

import 'package:multi_app/code/classes.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';

enum DatabaseTables {
	mangas(tableName: "Mangas"),
	mangaTags(tableName: "MangaTags"),
	mangaBookmarks(tableName: "MangaBookmarks");

	final String tableName;

	const DatabaseTables({
		required this.tableName,
	});

	@override
	String toString() {
		return tableName;
	}
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
			CREATE TABLE IF NOT EXISTS ${DatabaseTables.mangas} (
				ch_name TEXT,
				ch_link TEXT,
				en_name TEXT,
				en_link TEXT,
				jp_name TEXT,
				jp_link TEXT,
				img_link TEXT,

				description TEXT,

				rating REAL,
				tag_list TEXT,
				bookmark_list TEXT,
				chapter_count INTEGER,
				length INTEGER,
				ended INTEGER,

				time_added INTEGER,
				time_last_read INTEGER,
				
				id INTEGER PRIMARY KEY AUTOINCREMENT
			);
		''');
		await db.execute('''
			CREATE TABLE IF NOT EXISTS ${DatabaseTables.mangaTags} (
				name TEXT,
				count INTEGER,

				id INTEGER PRIMARY KEY AUTOINCREMENT
			);
		''');
		await db.execute('''
			CREATE TABLE IF NOT EXISTS ${DatabaseTables.mangaBookmarks} (
				name TEXT,
				chapter REAL,
				link TEXT,

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
		await db.insert(DatabaseTables.mangas.toString(), map);
	}
	Future<void> updateManga(Manga manga) async {
		await db.update(DatabaseTables.mangas.toString(), manga.toMap(), where: "id = ${manga.id}");
	}
	Future<void> deleteManga(Manga manga) async {
		// 1. Delete manga record
		await db.delete(
			DatabaseTables.mangas.toString(),
			where: "id = ?",
			whereArgs: [manga.id],
		);

		// 2. Update Tags counts
		for (final tagId in manga.tag_list) {
			await db.rawUpdate('''
				UPDATE ${DatabaseTables.mangaTags} 
				SET count = count - 1
				WHERE id = $tagId;
			''');
		}
	}
	Future<List<Manga>> getAllManga() async {
		final results = await db.query(DatabaseTables.mangas.toString());

		List<Manga> arr = [];
		for (final result in results) {
			arr.add(Manga.fromMap(result));
		}
		return arr;
	}
	Future<List<Manga>> getMangasFromTag(MangaTag tag) async {
		final results = await db.query(
			DatabaseTables.mangas.toString(),
			where: "tag_list like '%,${tag.id},%'"
		);
		List<Manga> returnArr = [];
		for (final result in results) {
			returnArr.add(Manga.fromMap(result));
		}
		return returnArr;
	}

	Future<void> createMangaTag(MangaTag tag) async {
		final map = tag.toMap();
		map["id"] = null;
		await db.insert(
			DatabaseTables.mangaTags.toString(), 
			map
		);
	}
	Future<void> updateMangaTag(MangaTag tag) async {
		await db.update(
			DatabaseTables.mangaTags.toString(), 
			tag.toMap(), 
			where: "id = ${tag.id}"
		);
	}
	Future<void> deleteMangaTag(MangaTag tag) async {
		// 1. Remove tag from database
		await db.delete(
			DatabaseTables.mangaTags.toString(), 
			where: "id = ${tag.id}",
		);

		// 2. Update Mangas with that tag
		final List<Manga> mangaList = await getMangasFromTag(tag);
		for (final manga in mangaList) {
			manga.tag_list.remove(tag.id);
			await updateManga(manga);
		}
	} 
	Future<MangaTag?> getMangaTagFromId(int id) async {
		try {
			final result = await db.query(
				DatabaseTables.mangaTags.toString(), 
				where: "id = $id"
			);

			return MangaTag.fromMap(result.first);
		} catch (err) {
			return null;
		}
	}
	Future<List<MangaTag>> getAllMangaTag() async {
		final results = await db.query(DatabaseTables.mangaTags.toString());

		List<MangaTag> arr = [];
		for (final result in results) {
			arr.add(MangaTag.fromMap(result));
		}
		return arr;
	}

	
}