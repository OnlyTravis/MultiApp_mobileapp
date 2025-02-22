import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multi_app/code/classes.dart';
import 'package:multi_app/code/database_handler.dart';
import 'package:multi_app/pages/manga_page/add_manga.dart';
import 'package:multi_app/pages/manga_page/view_manga.dart';
import 'package:multi_app/pages/manga_page/widgets/manga_card.dart';
import 'package:multi_app/widgets/pop_up_menu.dart';

class MangaListPage extends StatefulWidget {
	const MangaListPage({super.key});

	@override
	State<MangaListPage> createState() => _MangaPageListState();
}
class _MangaPageListState extends State<MangaListPage> {
	late StreamSubscription _streamSubscription;
	List<Manga> _mangaList = [];
	final List<SortingType> _allowedSortingtypes = [
		SortingType.name,
		SortingType.dateAdded,
		SortingType.dateLastRead,
	];
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
	void _onChangeSortingOrder() {
		_sortOrder = _sortOrder.inverse();
		_sortMangaList();
	}

	Future<void> _updateMangaList() async {
		final db = DatabaseHandler();
		_mangaList = await db.getAllManga();
		_sortMangaList();
	}
	void _sortMangaList() {
		setState(() {
			_mangaList.sort(Manga.sortFunc(_sortType, _sortOrder));
		});
	}

	@override 
	void initState() {
		_updateMangaList();

		final db = DatabaseHandler();
		if (db.streams[DatabaseTables.mangas] != null) {
			_streamSubscription = db.streams[DatabaseTables.mangas]!.listen((_) {
				_updateMangaList();
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
								Icon(Icons.filter_alt),
								Text("Filter"),
							],
						),
					),
					const VerticalDivider(width: 0, indent: 8, endIndent: 8),
					PopUpSelectMenu(
						selectedIndex: _allowedSortingtypes.indexOf(_sortType), 
						menuItems: _allowedSortingtypes.map((sortType) => PopUpSelectMenuItem(label: sortType.toString())).toList(),
						onChanged: (int index) {
							setState(() {
							  _sortType = _allowedSortingtypes[index];
							});
						}
					),
					const VerticalDivider(width: 0, indent: 8, endIndent: 8),
					IconButton(
						onPressed: _onChangeSortingOrder, 
						icon: Icon((_sortOrder == SortingOrder.asc) ? Icons.arrow_upward : Icons.arrow_downward, size: 20),
					),
					const VerticalDivider(width: 0, indent: 8, endIndent: 8),
					IconButton(
						padding: EdgeInsets.zero,
						onPressed: _onAddManga, 
						icon: const Icon(Icons.add, size: 20),
					),
				],
			),
		);
	}
}