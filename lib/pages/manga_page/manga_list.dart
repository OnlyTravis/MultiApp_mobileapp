import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multi_app/code/classes.dart';
import 'package:multi_app/code/database_handler.dart';
import 'package:multi_app/pages/manga_page/add_manga.dart';
import 'package:multi_app/pages/manga_page/view_manga.dart';
import 'package:multi_app/widgets/manga_card.dart';

class MangaListPage extends StatefulWidget {
  const MangaListPage({super.key});
  
  @override
  State<MangaListPage> createState() => _MangaPageListState();
}
class _MangaPageListState extends State<MangaListPage> {
  late StreamSubscription streamSubscription;
  List<Manga> mangaList = [];

  void button_onAddManga() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddMangaPage()
      )
    );
  }
  void button_onViewManga(Manga manga) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ViewMangaPage(
          manga: manga,
        )
      )
    );
  }

  Future<void> updateMangaList() async {
    final db = DatabaseHandler();
    final List<Manga> tmpList = await db.getAllManga();
    setState(() {
      mangaList = tmpList;
    });
  }

  @override void initState() {
    updateMangaList();

    final db = DatabaseHandler();
    if (db.streams[DatabaseTables.mangas] != null) {
      streamSubscription = db.streams[DatabaseTables.mangas]!.listen((_) {
        updateMangaList();
      });
    }

    super.initState();
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: _toolBar(),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: mangaList.asMap().entries.map((entry) => MangaCard(
          index: entry.key,
          manga: entry.value,
          onTap: button_onViewManga,
        )).toList(),
      ),
    );
  }
  @override void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  AppBar _toolBar() {
    return AppBar(
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
			),
      toolbarHeight: 40,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      actions: [
        IconButton(
          onPressed: () {}, 
          icon: Wrap(
            children: [
              Text("Filter"),
              Icon(Icons.filter_alt),
            ],
          ),
        ),
        IconButton(
          onPressed: button_onAddManga, 
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
}