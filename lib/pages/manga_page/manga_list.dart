import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multi_app/code/alert.dart';
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
		SortingType.chapterCount,
		SortingType.length,
		SortingType.dateAdded,
		SortingType.dateLastRead,
	];
	SortingType _sortType = SortingType.name;
	SortingOrder _sortOrder = SortingOrder.asc;

	void _onViewManga(Manga manga) {
		Navigator.of(context).push(
			MaterialPageRoute(
				builder: (context) => ViewMangaPage(
					manga: manga,
				)
			)
		);
	}
	void _onChangeSortingOrder(SortingOrder newSortOrder) {
		setState(() {
		  _sortOrder = newSortOrder;
		});
		_sortMangaList();
	}
	void _onChangeSortingType(SortingType newSortType) {
		setState(() {
		  _sortType = newSortType;
		});
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
				_MangaListToolBar(
					allowedSortingTypes: _allowedSortingtypes,
					sortOrder: _sortOrder,
					sortType: _sortType,
					onChangeSortOrder: _onChangeSortingOrder,
					onChangeSortType: _onChangeSortingType,
				),
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
}

class _MangaListToolBar extends StatelessWidget {
	final List<SortingType> allowedSortingTypes;
	final SortingType sortType;
	final SortingOrder sortOrder;
	final Function(SortingType) onChangeSortType;
	final Function(SortingOrder) onChangeSortOrder;

	const _MangaListToolBar({
		required this.allowedSortingTypes,
		required this.sortType,
		required this.sortOrder,
		required this.onChangeSortType,
		required this.onChangeSortOrder,
	});

	Future<void> _onTapFilter(BuildContext context) async {
		bool confirmed = false;
		await showDialog(
			context: context,
			builder: (BuildContext context) => AlertDialog(
				title: const Text("Select Filter"),
				content: Text("Filter WIP"),
				actions: [
					TextButton(
						onPressed: () {
							confirmed = true;
							Navigator.pop(context);
						},
						child: const Text('Confirm'),
					),
					TextButton(
						onPressed: () {
							Navigator.pop(context);
						},
						child: const Text('Cancel'),
					),
				],
			),
		);

		if (!confirmed) return;
	}

	@override
  Widget build(BuildContext context) {
		assert (allowedSortingTypes.contains(sortType));

    return Container(
			color: Theme.of(context).colorScheme.primaryContainer,
			height: 40,
			child: Row(
				mainAxisAlignment: MainAxisAlignment.end,
				children: [
					IconButton(
						onPressed: () => _onTapFilter(context), 
						icon: Row(
							mainAxisSize: MainAxisSize.min,
							children: [
								Icon(
									Icons.filter_alt,
									color: Theme.of(context).colorScheme.primary,
								),
								Text(
									"Filter",
									style: TextStyle(
										color: Theme.of(context).colorScheme.primary,
									),
								),
							],
						),
					),
					const VerticalDivider(width: 0, indent: 8, endIndent: 8),
					PopUpSelectMenu(
						onChanged: (int index) => onChangeSortType(allowedSortingTypes[index]),
						leadingIcon: const Icon(Icons.sort),
						selectedIndex: allowedSortingTypes.indexOf(sortType), 
						menuItems: allowedSortingTypes.map((sortType) => sortType.toString()).toList(),
					),
					const VerticalDivider(width: 0, indent: 8, endIndent: 8),
					IconButton(
						onPressed: () => onChangeSortOrder(sortOrder.inverse()),
						icon: Icon(
							(sortOrder == SortingOrder.asc) ? Icons.arrow_upward : Icons.arrow_downward, 
							size: 20,
							color: Theme.of(context).colorScheme.primary,
						),
					),
					const VerticalDivider(width: 0, indent: 8, endIndent: 8),
					IconButton(
						padding: EdgeInsets.zero,
						onPressed: () {
							Navigator.of(context).push(
								MaterialPageRoute(
									builder: (context) => const AddMangaPage()
								)
							);
						},
						icon: Icon(Icons.add, size: 20, color: Theme.of(context).colorScheme.primary),
					),
				],
			),
		);
  }
}