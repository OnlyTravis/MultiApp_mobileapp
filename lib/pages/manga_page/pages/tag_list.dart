import 'dart:async';

import 'package:flutter/material.dart';
import 'package:multi_app/code/alert.dart';
import 'package:multi_app/code/classes.dart';
import 'package:multi_app/code/database_handler.dart';
import 'package:multi_app/pages/manga_page/pages/view_tag.dart';
import 'package:multi_app/widgets/app_card.dart';
import 'package:multi_app/widgets/pop_up_menu.dart';

class MangaTagListPage extends StatefulWidget {
	const MangaTagListPage({super.key});

	@override
	State<MangaTagListPage> createState() => _MangaTagListPageState();
}
class _MangaTagListPageState extends State<MangaTagListPage> {
	late StreamSubscription _streamSubscription;
	List<MangaTag> _tagList = [];

	SortingType _sortType = SortingType.name;
	SortingOrder _sortOrder = SortingOrder.asc;
	static const List<SortingType> _allowedSortingTypes = [
		SortingType.name,
		SortingType.count,
	];

	Future<void> _onAddTag() async {
		// 1. Ask for name input
		final String tagName = (await alertInput<String>(context, 
			title: "Create New Tag", 
			placeHolder: "Enter Tag Name Here"
		) ?? "").trim();
		if (tagName.isEmpty) return;

		// 2. Update tag in database & UI
		final MangaTag tag = MangaTag(name: tagName, count: 0, id: -1);
		final db = DatabaseHandler();
		await db.createRecord(DatabaseTables.mangaTags, tag);
		await _updateTagList();
	}
	Future<void> _onRenameTag(MangaTag tag) async {
		// 1. Ask for name input
		String newTagName = (await alertInput<String>(context, 
			title: "Rename Tag",
			text: "Rename Tag '${tag.name}' to : ", 
			placeHolder: "Enter Tag Name Here"
		) ?? "").trim();
		if (newTagName.isEmpty || tag.name == newTagName) return;

		// 2. Update tag in database & UI
		tag.name = newTagName;
		final db = DatabaseHandler();
		await db.updateMangaTag(tag);
		await _updateTagList();
	}
	Future<void> _onViewTag(MangaTag tag) async {
		Navigator.of(context).push(MaterialPageRoute(
			builder: (_) => ViewTagPage(tag: tag)
		));
	}

	Future<void> _updateTagList() async {
		final db = DatabaseHandler();
		final tmpList = await db.getAllMangaTag();
		_tagList = tmpList;
		_sortTagList();
	}
	void _sortTagList() {
		setState(() {
		  _tagList.sort(MangaTag.sortFunc(_sortType, _sortOrder));
		});
	}
	void listenForUpdate() {
		final db = DatabaseHandler();
		_streamSubscription = db.streams[DatabaseTables.mangaTags]!.listen((_) {
			_updateTagList();
		});
	}

	@override
	void initState() {
		_updateTagList();
		listenForUpdate();
		super.initState();
	}
	@override
  void dispose() {
    _streamSubscription.cancel();
		super.dispose();
  }

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			floatingActionButton: FloatingActionButton(
				onPressed: _onAddTag,
				child: const Icon(Icons.add),
			),
			body: Column(
				mainAxisSize: MainAxisSize.min,
				children: [
					_ToolBar(
						sortType: _sortType,
						sortOrder: _sortOrder,
						allowedSortingTypes: _allowedSortingTypes,
						onChangeSortType: (newSortType) {
							setState(() {
							  _sortType = newSortType;
							});
							_sortTagList();
						},
						onChangeSortOrder: (newSortOrder) {
							setState(() {
							  _sortOrder = newSortOrder;
							});
							_sortTagList();
						},
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
									padding: const EdgeInsets.all(4),
									children: _tagList.map((MangaTag tag) => _tagCard(tag)).toList(),
								),
							),
						),
					),
				],
			),
		);
	}
	Widget _tagCard(MangaTag tag) {
		return AppCardSplash(
			margin: const EdgeInsets.all(4),
			child: InkWell(
				onTap: () => _onViewTag(tag),
				child: ListTile(
					title: Text(tag.name),
					subtitle: Text("Used in ${tag.count} manga${tag.count > 1 ? "s" : ""}"),
					trailing: Wrap(
						children: [
							IconButton(
								onPressed: () => _onRenameTag(tag),
								icon: const Icon(Icons.drive_file_rename_outline)
							),
						],
					),
				),
			),
		);
	}
}

class _ToolBar extends StatelessWidget {
	final SortingType sortType;
	final SortingOrder sortOrder;
	final List<SortingType> allowedSortingTypes;
	final Function(SortingType) onChangeSortType;
	final Function(SortingOrder) onChangeSortOrder;

	const _ToolBar({
		required this.sortType,
		required this.sortOrder,
		required this.allowedSortingTypes,
		required this.onChangeSortType,
		required this.onChangeSortOrder,
	});

	@override
  Widget build(BuildContext context) {
		return Container(
			color: Theme.of(context).colorScheme.primaryContainer,
			height: 40,
			child: Row(
				children: [
					const SizedBox(width: 16),
					const Text("Tag List"),
					const Expanded(child: SizedBox()),
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
				],
			),
		);
	}
}