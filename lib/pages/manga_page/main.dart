import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multi_app/code/classes.dart';
import 'package:multi_app/code/database_handler.dart';
import 'package:multi_app/pages/manga_page/add_manga.dart';
import 'package:multi_app/widgets/star_rating.dart';

class MangaPage extends StatefulWidget {
  const MangaPage({super.key});
  
  @override
  State<MangaPage> createState() => _MangaPageState();
}
class _MangaPageState extends State<MangaPage> {
  late StreamSubscription streamSubscription;
  List<Manga> mangaList = [];

  void button_onAddManga() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddMangaPage()
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

  @override
  void initState() {
    updateMangaList();

    final db = DatabaseHandler();
    if (db.streams[DatabaseTables.mangas] != null) {
      streamSubscription = db.streams[DatabaseTables.mangas]!.listen((_) {
        updateMangaList();
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _toolBar(),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: mangaList.asMap().entries.map((entry) => _mangaCard(entry.value, entry.key)).toList(),
      ),
    );
  }

  @override
  void dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  AppBar _toolBar() {
    return AppBar(
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
  Widget _mangaCard(Manga manga, int index) {
    final String mangaName = manga.ch_name ?? manga.en_name ?? manga.jp_name ?? "null";

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Container(
            width: 96,
            height: 128,
            color: Theme.of(context).colorScheme.surfaceDim,
            child: Center(
              child: Text("Image Not Available", textAlign: TextAlign.center),
            ),
          ),
          Flexible(
            child: Container(
              height: 128,
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${index+1}. $mangaName"),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Chapters : ${manga.chapter_count}"),
                      (manga.rating != -1) ? 
                        StarRating(value: manga.rating) :
                        Text("No Rating")
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}