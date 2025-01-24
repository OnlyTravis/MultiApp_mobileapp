import 'package:flutter/material.dart';
import 'package:multi_app/pages/home_page.dart';
import 'package:multi_app/pages/manga_page.dart';

enum Pages {
  none,
  homePage,
  mangaPage,
}

Widget toPage(Pages page) {
  switch (page) {
    case Pages.homePage: return HomePage();
    case Pages.mangaPage: return MangaPage();
    default: return Center(child: Text("Empty Page"));
  }
}