import 'package:flutter/material.dart';
import 'package:multi_app/code/alert.dart';
import 'package:multi_app/code/classes.dart';
import 'package:multi_app/code/database_handler.dart';
import 'package:multi_app/pages/manga_page/widgets/manga_tag_card.dart';
import 'package:multi_app/widgets/app_card.dart';
import 'package:multi_app/pages/manga_page/widgets/manga_card.dart';
import 'package:multi_app/widgets/page_appbar.dart';
import 'package:multi_app/widgets/select_page.dart';
import 'package:multi_app/widgets/star_rating.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewMangaPage extends StatefulWidget {
	final Manga manga;
	const ViewMangaPage({super.key, required this.manga});

	@override
	State<ViewMangaPage> createState() => _ViewMangaPageState();
}
class _ViewMangaPageState extends State<ViewMangaPage> {
	late Manga _manga;
	List<MangaTag> _tagList = [];
	
	bool _editing = false;

	double _ratingBuffer = 0;

	void _toggleEdit() {
		setState(() {
			_editing = !_editing;
		});
	}
	Future<void> _editString(String name, String key, String old_value) async {
		final String? newValue = await alertInput<String>(
			context, 
			title: "Update Value", 
			text: "Change '$name' to : ", 
			defaultValue: old_value
		);

		if (newValue == null) return;

		await _updateValue(key, newValue);
	}
	Future<void> _editNumber(String name, String key, int old_value) async {
		final int? newValue = await alertInput<int>(
			context, 
			title: "Update Value", 
			text: "Change '$name' to : ", 
			defaultValue: old_value.toString()
		);
		if (newValue == null) return;

		await _updateValue(key, newValue);
	}
	Future<void> _onAddTags(List<MangaTag> addTagList) async {
		if (addTagList.isEmpty) return;

		// 1. Update Manga record in database
		final db = DatabaseHandler();
		_manga.tag_list.addAll(addTagList.map((MangaTag tag) => tag.id));
		await db.updateManga(_manga);

		// 2. Update MangaTag records in database
		for (final tag in addTagList) {
			await db.updateMangaTag(tag);
		}

		// 3. Broadcast change, notify user & update UI
		db.notifyUpdate(DatabaseTables.mangas);
		db.notifyUpdate(DatabaseTables.mangaTags);
		if (mounted) alertSnackbar(context, text: "Tags added to manga!");
		setState(() {
		  _tagList.addAll(addTagList);
		});
	}
	Future<void> _onRemoveTag(MangaTag removeTag) async {
		// 1. Update Manga record in database
		final db = DatabaseHandler();
		if (!_manga.tag_list.remove(removeTag.id)) return;
		await db.updateManga(_manga);

		// 2. Update MangaTag records in database & tagList
		int index = _tagList.indexWhere((MangaTag tag) => tag.id == removeTag.id);
		_tagList[index].count--;
		await db.updateMangaTag(_tagList[index]);
		setState(() {
		  _tagList.removeAt(index);
		});

		// 3. Update UI & broadcast change
		db.notifyUpdate(DatabaseTables.mangas);
		db.notifyUpdate(DatabaseTables.mangaTags);
	}
	Future<void> _onUpdateLink() async {
		setState(() async {
		  _manga.time_last_read = DateTime.now();
			final db = DatabaseHandler();
			await db.updateManga(_manga);
			if (mounted) alertSnackbar(context, text: "Time last read updated !");
		});
	}

	Future<void> _updateValue(String key, dynamic value) async {
		final map = _manga.toMap();
		map[key] = value;
		final Manga tmpManga = Manga.fromMap(map);
		setState(() {
			_manga = tmpManga;
		});

		final db = DatabaseHandler();
		await db.updateManga(tmpManga);
		db.notifyUpdate(DatabaseTables.mangas);
	}
	Future<void> _fetchTagList() async {
		final db = DatabaseHandler();

		List<MangaTag> tmpList = [];
		for (final int id in _manga.tag_list) {
			final MangaTag? tag = await db.getMangaTagFromId(id);
			if (tag == null) throw ErrorDescription("MangaTag with id $id cannot be found in database.");
			tmpList.add(tag);
		}

		setState(() {
			_tagList = tmpList;
		});
	}

	@override
	void initState() {
		_manga = widget.manga;
		setState(() {
			_ratingBuffer = (widget.manga.rating == -1) ? 0 : widget.manga.rating;
		});
		_fetchTagList();
		super.initState();
	}

	@override 
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: PageAppBar(title: _manga.topName()),
			body: ListView(
				padding: const EdgeInsets.all(12),
				children: [
					MangaCard(manga: _manga),
					const SizedBox(height: 12),
					_editing ? _editDisplay() : _viewDisplay(),
					const SizedBox(height: 12),
					MangaTagListCard(
						tagList: _tagList,
						title: const Text("Tags : ", textScaler: TextScaler.linear(1.2)),
						emptyText: _editing ? null : const Text("No Tag Added", textScaler: TextScaler.linear(1.1)),
						onAddTags: _editing ? _onAddTags : null,
						onRemoveTag: _editing ? _onRemoveTag : null,
					),
					const SizedBox(height: 12),
					_DeleteMangaCard(manga: _manga),
					const SizedBox(height: 64),
				],
			),
			floatingActionButton: FloatingActionButton(
				onPressed: _toggleEdit,
				child: Icon(_editing ? Icons.edit_off : Icons.edit),
			),
		);
	}
	Widget _editDisplay() {
		final List<Widget> arr = [
			_textInfoCard(title: "Chinese Name", key: "ch_name", value: _manga.ch_name),
			_textInfoCard(title: "English Name", key: "en_name", value: _manga.en_name),
			_textInfoCard(title: "Japanese Name", key: "jp_name", value: _manga.jp_name),
			_textInfoCard(title: "Chinese Manga Link", key: "ch_link", value: _manga.ch_link),
			_textInfoCard(title: "English Manga Link", key: "en_link", value: _manga.en_link),
			_textInfoCard(title: "Japanese Manga Link", key: "jp_link", value: _manga.jp_link),
			_textInfoCard(title: "Image Link", key: "img_link", value: _manga.img_link),
			_numberInfoCard(title: "Chapter Count", key: "chapter_count", value: _manga.chapter_count),
			_mangaLengthCard(),
			_ratingCard(editable: true),
		];

		return AppCardSplash(
			child: ListView.separated(
				shrinkWrap: true,
				physics: const NeverScrollableScrollPhysics(),
				itemBuilder:(context, index) => arr[index],
				separatorBuilder: (context, index) => const Divider(height: 0),
				itemCount: arr.length,
			),
		);
	}
	Widget _textInfoCard({required String title, String key = "", required String value}) {
		return ListTile(
			onTap: key.isNotEmpty ? () => _editString(title, key, value) : null,
			contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
			title: Text(title),
			subtitle: value.isEmpty ? const Text("Not Provided") : Text(value),
		);
	}
	Widget _numberInfoCard({required String title, String key = "", required int value}) {
		return ListTile(
			onTap: key.isNotEmpty ? () => _editNumber(title, key, value) : null,
			contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
			title: Text(title),
			subtitle: Text(value.toString()),
		);
	}
	Widget _mangaLengthCard({ bool editable = false }) {
		return ListTile(
			onTap: editable ? () => selectPageInput(
				context, 
				title: "Manga Length", 
				selected: _manga.length.toString(), 
				inputList: MangaLength.values.map((value) => value.toString()).toList(),
				onSelectIndex: (int index) {
					_updateValue("length", MangaLength.values[index]);
				}
			) : null,
			contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
			title: const Text("Manga Length"),
			subtitle: Text(_manga.length.toString()),
		);
	}
	Widget _ratingCard({ bool editable = false }) {
		return Column(
			mainAxisSize: MainAxisSize.min,
			children: [
				ListTile(
					contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
					title: Text("Rating : ${_manga.rating == -1 ? "Off" : "${_ratingBuffer.toStringAsFixed(1)}/5.0"}"),
					trailing: Wrap(
						spacing: 16,
						children: [
							if (_manga.rating != -1 && !editable) StarRating(value: _manga.rating),
							editable ? Switch(
								value: (_manga.rating != -1), 
								onChanged: (bool toggled) {
									if (_manga.rating == -1) {
										_updateValue("rating", (_ratingBuffer*10).round()/10);
									} else {
										_updateValue("rating", -1.0);
									}
								}
							) : const SizedBox(width: 24)
						],
					),
				),
				if (editable && _manga.rating != -1) ...[
					StarRating(value: _ratingBuffer),
					Slider(
						min: 0,
						max: 5,
						value: _ratingBuffer, 
						onChanged: (newValue) {
							setState(() {
								_ratingBuffer = newValue;
							});
						},
						onChangeEnd: (newValue) {
							setState(() {
								_updateValue("rating", (newValue*10).round()/10);
							});
						},
					)
				]
			],
		);
	}

	Widget _viewDisplay() {
		final List<Widget> arr = [];

		if (_manga.ch_link.isNotEmpty) arr.add(_LinkDisplayCard(manga: _manga, title: "Manga (Chinese)", link: _manga.ch_link, onUpdate: _onUpdateLink));
		if (_manga.en_link.isNotEmpty) arr.add(_LinkDisplayCard(manga: _manga, title: "Manga (English)", link: _manga.en_link, onUpdate: _onUpdateLink));
		if (_manga.jp_link.isNotEmpty) arr.add(_LinkDisplayCard(manga: _manga, title: "Manga (Japanese)", link: _manga.jp_link, onUpdate: _onUpdateLink));
		if (_manga.ch_name.isNotEmpty) arr.add(_textInfoCard(title: "Chinese Name", value: _manga.ch_name));
		if (_manga.en_name.isNotEmpty) arr.add(_textInfoCard(title: "English Name", value: _manga.en_name));
		if (_manga.jp_name.isNotEmpty) arr.add(_textInfoCard(title: "Japanese Name", value: _manga.jp_name));
		arr.addAll([
			_numberInfoCard(title: "Chapter Count", value: _manga.chapter_count),
			_mangaLengthCard(),
			_ratingCard(),
			_DateDisplayCard(title: "Time last read", date: _manga.time_last_read),
			_DateDisplayCard(title: "Time added", date: _manga.time_added),
		]);

		return AppCardSplash(
			child: ListView.separated(
				shrinkWrap: true,
				physics: const NeverScrollableScrollPhysics(),
				itemBuilder:(context, index) => arr[index],
				separatorBuilder: (context, index) => const Divider(height: 0),
				itemCount: arr.length,
			),
		);
	}
}
class _LinkDisplayCard extends StatelessWidget {
	final Manga manga;
	final String title;
	final String link;
	final Function() onUpdate;
	
	const _LinkDisplayCard({
		required this.manga,
		required this.title,
		required this.link,
		required this.onUpdate,
	});

	@override
  Widget build(BuildContext context) {
    return ListTile(
			contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
			title: Text(title),
			trailing: Row(
				mainAxisSize: MainAxisSize.min,
				children: [
					Card(
						clipBehavior: Clip.antiAlias,
						color: Theme.of(context).colorScheme.primaryContainer,
						child: InkWell(
							onTap: onUpdate,
							child: Ink(
								padding: const EdgeInsets.all(12),
								child: const Text("Mark Read"),
							),
						),
					),
					Card(
						clipBehavior: Clip.antiAlias,
						color: Theme.of(context).colorScheme.primaryContainer,
						child: InkWell(
							onTap: () async {
								final Uri url = Uri.parse(link);
								try {
									if (!await launchUrl(url)) {
										if (context.mounted) alertSnackbar(context, text: "Could not launch link '$link' in browser!");
									}
								} catch (err) {
									if (context.mounted) alertSnackbar(context, text: "Could not launch link '$link' in browser!");
								}
							},
							child: Ink(
								padding: const EdgeInsets.all(12),
								child: const Text("Open Link"),
							),
						),
					),
				],
			)
		);
  }
}
class _DateDisplayCard extends StatelessWidget {
	final String title;
	final DateTime date;

	const _DateDisplayCard({
		required this.title,
		required this.date,
	});

	@override
  Widget build(BuildContext context) {
		return ListTile(
			contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
			title: Text(title),
			subtitle: Text(date.toString()),
		);
	}
}
class _DeleteMangaCard extends StatelessWidget {
	final Manga manga;

	const _DeleteMangaCard({
		required this.manga,
	});

	@override
  Widget build(BuildContext context) {
		return AppCardSplash(
			child: InkWell(
				onTap: () async {
					// 1. Confirmation
					final bool confrimation = await confirm(
						context,
						title: "Confirm Delete",
						text: "Are you sure you want to delete this Manga?"
					);
					if (!confrimation) return;

					// 2. Remove Manga record from database
					final db = DatabaseHandler();
					await db.deleteManga(manga);
					db.notifyUpdate(DatabaseTables.mangas);

					// 3. Alert user, pop navigation
					if (context.mounted) {
						alertSnackbar(context, text: "Manga '${manga.topName()}' removed!");
						Navigator.of(context).pop();
					}
				},
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
								"Delete Manga",
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