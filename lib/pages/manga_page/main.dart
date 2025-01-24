import 'package:flutter/material.dart';
import 'package:multi_app/code/classes.dart';
import 'package:multi_app/widgets/star_rating.dart';

class MangaPage extends StatefulWidget {
  const MangaPage({super.key});
  
  @override
  State<MangaPage> createState() => _MangaPageState();
}
class _MangaPageState extends State<MangaPage> {
  List<Manga> mangaList = [
    Manga(id: 0, ch_name: "This is a Chinese Name", rating: 3.5),
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
                  Text(mangaName),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Chapters : "),
                      if (manga.rating != -1) StarRating(label: "Rating : ", value: manga.rating)
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