import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multi_app/code/classes.dart';
import 'package:multi_app/code/database_handler.dart';
import 'package:multi_app/pages/manga_page/add_manga.dart';
import 'package:multi_app/pages/manga_page/view_manga.dart';
import 'package:multi_app/pages/manga_page/widgets/manga_card.dart';

class MangaListPage extends StatefulWidget {
	const MangaListPage({super.key});

	@override
	State<MangaListPage> createState() => _MangaPageListState();
}
class _MangaPageListState extends State<MangaListPage> {
	late StreamSubscription _streamSubscription;
	List<Manga> _mangaList = [];
	SortingType _sortType = SortingType.name;
	SortingOrder _sortOrder = SortingOrder.asc;

	void _onAddManga() {
		Navigator.of(context).push(
			MaterialPageRoute(
				builder: (context) => const AddMangaPage()
			)
		);
	}
	void _onViewManga(Manga manga) {
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
			_mangaList = tmpList;
			sortMangaList();
		});
	}
	void sortMangaList() {
		_mangaList.sort(Manga.sortFunc(_sortType, _sortOrder));
	}

	@override 
	void initState() {
		updateMangaList();

		final db = DatabaseHandler();
		if (db.streams[DatabaseTables.mangas] != null) {
			_streamSubscription = db.streams[DatabaseTables.mangas]!.listen((_) {
				updateMangaList();
			});
		}

		super.initState();
	}
	
	@override 
	void dispose() {
		_streamSubscription.cancel();
		super.dispose();
	}

	@override 
	Widget build(BuildContext context) {
		return Column(
			mainAxisSize: MainAxisSize.min,
			children: [
				_toolBar(),
				Flexible(
					child: Container(
						color: Theme.of(context).colorScheme.primaryContainer,
						child: Container(
							padding: const EdgeInsets.only(top: 8),
							decoration: BoxDecoration(
								borderRadius: BorderRadius.vertical(
									top: Radius.elliptical(MediaQuery.sizeOf(context).width, 30),
								),
								color: Theme.of(context).colorScheme.surface,
							),
							child: ListView(
								padding: const EdgeInsets.all(12),
								children: [
									..._mangaList.asMap().entries.map((entry) => MangaCard(
										index: entry.key,
										manga: entry.value,
										onTap: _onViewManga,
									))
								],
							),
						),
					),
				),
			],
		);
	}

	Widget _toolBar() {
		return Container(
			color: Theme.of(context).colorScheme.primaryContainer,
			height: 40,
			child: Row(
				mainAxisAlignment: MainAxisAlignment.end,
				children: [
					IconButton(
						onPressed: () {}, 
						icon: const Wrap(
							children: [
								Text("Filter"),
								Icon(Icons.filter_alt),
							],
						),
					),
					IconButton(
						onPressed: () {}, 
						icon: const Wrap(
							children: [
								Text("Sorting"),
								Icon(Icons.sort),
							],
						),
					),
					IconButton(
						onPressed: _onAddManga, 
						icon: const Icon(Icons.add),
					),
				],
			),
		);
	}
}