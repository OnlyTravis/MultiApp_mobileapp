import 'package:flutter/material.dart';
import 'package:multi_app/code/alert.dart';
import 'package:multi_app/code/classes.dart';
import 'package:multi_app/code/database_handler.dart';
import 'package:multi_app/widgets/app_card.dart';
import 'package:multi_app/widgets/page_appbar.dart';

class ViewTagPage extends StatefulWidget {
	final MangaTag tag;
	const ViewTagPage({super.key, required this.tag});

	@override
  State<ViewTagPage> createState() => _ViewTagPage();
}
class _ViewTagPage extends State<ViewTagPage> {
	late MangaTag _tag;
	List<Manga> _mangaList = [];

	Future<void> _onRenameTag() async {
		// 1. Ask for name input
		String newTagName = (await alertInput<String>(context, 
			title: "Rename Tag",
			text: "Rename Tag '${_tag.name}' to : ", 
			placeHolder: "Enter Tag Name Here"
		) ?? "").trim();
		if (newTagName.isEmpty || _tag.name == newTagName) return;

		// 2. Update tag in database
		_tag.name = newTagName;
		final db = DatabaseHandler();
		await db.updateMangaTag(_tag);
		db.notifyUpdate(DatabaseTables.mangaTags);

		// 3. Update UI & notify user
		setState(() {
			_tag.name = newTagName;
		});
		if (mounted) alertSnackbar(context, text: "Tag renamed to '$newTagName'!");
	}
	Future<void> _onDeleteTag() async {
		// 1. Confirmation
		bool confirmation = await confirm(
			context, 
			title: "Confirm Delete",
			text: "Are you sure you want to delete this tag?", 
		);
		if (!confirmation) return;

		// 2. Remove tag from database
		final db = DatabaseHandler();
		await db.deleteMangaTag(_tag);
		db.notifyUpdate(DatabaseTables.mangaTags);

		// 3. Navigate back to tag list page
		if (mounted) {
			alertSnackbar(context, text: "Tag '${_tag.name}' deleted!");
			Navigator.of(context).pop();
		}
	}

	Future<void> _fetchMangaList() async {
		final db = DatabaseHandler();
		final tmpList = await db.getMangasFromTag(widget.tag);
		setState(() {
		  _mangaList = tmpList;
		});
	}

	@override
  void initState() {
		_fetchMangaList();
    setState(() {
      _tag = widget.tag;
    });
		super.initState();
  }

	@override
  Widget build(BuildContext context) {
    return Scaffold(
			appBar: PageAppBar(title: _tag.name),
			body: ListView(
				padding: const EdgeInsets.all(4),
				children: [
					_tagInfoCard(),
					_mangaListCard(),
					_deleteTagCard(),
				],
			),
		);
  }
	Widget _tagInfoCard() {
		return AppCard(
			margin: const EdgeInsets.all(8),
			child: Column(
				children: [
					ListTile(
						title: const Text("Tag Name"),
						subtitle: Text(_tag.name),
						trailing: IconButton(
							onPressed: _onRenameTag, 
							icon: const Icon(Icons.drive_file_rename_outline)
						),
					),
					const Divider(height: 0),
					ListTile(
						title: const Text("Used in"),
						subtitle: Text(_tag.count.toString()),
					)
				],
			),
		);
	}
	Widget _mangaListCard() {
		return AppCard(
			padding: const EdgeInsets.all(16),
			margin: const EdgeInsets.all(8),
			child: Column(
				mainAxisSize: MainAxisSize.min,
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					const Text("Mangas that uses this tag : ", textScaler: TextScaler.linear(1.2)),
					Container(
						padding: const EdgeInsets.all(8),
						decoration: BoxDecoration(
							color: Theme.of(context).colorScheme.surfaceContainer,
							borderRadius: const BorderRadius.all(Radius.circular(8)) 
						),
						child: _mangaList.isEmpty ? const Text("No manga has used this tag yet.") : ListView.builder(
							shrinkWrap: true,
							itemBuilder: (context, index) => AppCard(
								padding: const EdgeInsets.all(8),
								margin: const EdgeInsets.all(4),
								color: Theme.of(context).colorScheme.secondaryContainer,
								child: Text("$index. ${_mangaList[index].topName()}"),
							),
							itemCount: _mangaList.length,
						),
					),
				],
			),
		);
	}
	Widget _deleteTagCard() {
		return AppCardSplash(
			margin: const EdgeInsets.all(8),
			child: InkWell(
				onTap: _onDeleteTag,
				child: Padding(
					padding: const EdgeInsets.all(8),
					child: Row(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Icon(
								Icons.delete,
								size: 20,
								color: Theme.of(context).colorScheme.primary,
							),
							Text(
								"Delete Tag",
								style: TextStyle(
									color: Theme.of(context).colorScheme.primary,
									fontWeight: FontWeight.bold
								),
							),
						],
					),
				),
			),
		);
	}
}