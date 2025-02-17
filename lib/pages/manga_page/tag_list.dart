import 'package:flutter/material.dart';
import 'package:multi_app/code/alert.dart';
import 'package:multi_app/code/classes.dart';
import 'package:multi_app/code/database_handler.dart';
import 'package:multi_app/pages/manga_page/view_tag.dart';
import 'package:multi_app/widgets/app_card.dart';

class TagListPage extends StatefulWidget {
	const TagListPage({super.key});

	@override
	State<TagListPage> createState() => _TagListPageState();
}
class _TagListPageState extends State<TagListPage> {
	List<MangaTag> tagList = [];

	Future<void> button_onAddTag() async {
		// 1. Ask for name input
		final String tagName = (await alertInput<String>(context, 
			title: "Create New Tag", 
			placeHolder: "Enter Tag Name Here"
		) ?? "").trim();
		if (tagName.isEmpty) return;

		// 2. Update tag in database & UI
		final MangaTag tag = MangaTag(name: tagName, count: 0, id: -1);
		final db = DatabaseHandler();
		await db.createMangaTag(tag);
		await updateTagList();
	}
	Future<void> button_onRenameTag(MangaTag tag) async {
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
		await updateTagList();
	}
	Future<void> button_onViewTag(MangaTag tag) async {
		Navigator.of(context).push(MaterialPageRoute(
			builder: (_) => ViewTagPage(tag: tag)
		));
	}

	Future<void> updateTagList() async {
		final db = DatabaseHandler();
		final tmpList = await db.getAllMangaTag();
		setState(() {
			tagList = tmpList;
		});
	}

	@override
	void initState() {
		updateTagList();
		super.initState();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			floatingActionButton: FloatingActionButton(
				onPressed: button_onAddTag,
				child: const Icon(Icons.add),
			),
			body: ListView(
				padding: const EdgeInsets.all(4),
				children: tagList.map((MangaTag tag) => _tagCard(tag)).toList(),
			),
		);
	}
	Widget _tagCard(MangaTag tag) {
		return AppCardSplash(
			margin: const EdgeInsets.all(4),
			child: InkWell(
				onTap: () => button_onViewTag(tag),
				child: ListTile(
					title: Text(tag.name),
					subtitle: Text("Used in ${tag.count} mangas"),
					trailing: Wrap(
						children: [
							IconButton(
								onPressed: () => button_onRenameTag(tag),
								icon: const Icon(Icons.drive_file_rename_outline)
							),
						],
					),
				),
			),
		);
	}
}