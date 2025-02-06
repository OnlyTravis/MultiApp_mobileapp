import 'package:flutter/material.dart';
import 'package:multi_app/pages/manga_page/manga_list.dart';
import 'package:multi_app/widgets/bottom_navigation_wrap.dart';

class MangaPage extends StatelessWidget {
  const MangaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationWrap(
      pageTitles: [
        "Manga List",
        "Tags"
      ],
      pageIcons: [
        const Icon(Icons.list),
        const Icon(Icons.tag)
      ],
      pages: [
        MangaListPage(),
        Container()
      ]
    );
  }
}