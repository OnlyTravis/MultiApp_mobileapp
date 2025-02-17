import 'package:flutter/material.dart';
import 'package:multi_app/pages/home_page.dart';
import 'package:multi_app/pages/manga_page/main.dart';

enum Pages {
	none,
	homePage,
	mangaPage,
}

Widget toPage(Pages page) {
	switch (page) {
		case Pages.homePage: return const HomePage();
		case Pages.mangaPage: return const MangaPage();
		default: return const Center(child: Text("Empty Page"));
	}
}