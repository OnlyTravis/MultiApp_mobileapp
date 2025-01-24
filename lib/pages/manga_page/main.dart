import 'package:flutter/material.dart';
import 'package:multi_app/code/classes.dart';

class MangaPage extends StatefulWidget {
  const MangaPage({super.key});
  
  @override
  State<MangaPage> createState() => _MangaPageState();
}
class _MangaPageState extends State<MangaPage> {
  List<Manga> mangaList = [
    Manga(id: 0, ch_name: "This is a Chinese Name"),
    Manga(id: 1, en_name: "This is an Englist Name"),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: mangaList.map((Manga manga) => mangaCard(manga)).toList(),
    );
  }

  Widget mangaCard(Manga manga) {
    final String mangaName = manga.ch_name ?? manga.en_name ?? manga.jp_name ?? "null";

    return Card(
      child: ListTile(
        leading: Container(
          width: 96,
          height: 128,
          color: Theme.of(context).colorScheme.surfaceDim,
          child: Center(
            child: Text("Image Not Available"),
          ),
        ),
        title: Text(mangaName),
        dense: true,
        visualDensity: VisualDensity(vertical: 3)
      ),
    );
  }
}