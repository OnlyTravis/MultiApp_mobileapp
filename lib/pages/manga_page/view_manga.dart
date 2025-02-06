import 'package:flutter/material.dart';
import 'package:multi_app/code/alert.dart';
import 'package:multi_app/code/classes.dart';
import 'package:multi_app/code/database_handler.dart';
import 'package:multi_app/widgets/app_card.dart';
import 'package:multi_app/widgets/manga_card.dart';
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
  late Manga manga;
  bool editing = false;

  double ratingBuffer = 0;

  void button_toggleEdit() {
    setState(() {
      editing = !editing;
    });
  }
  Future<void> button_editString(String name, String key, String old_value) async {
    final String? newValue = await alertInput<String>(context, title: "Update Value", text: "Change '$name' to : ", defaultValue: old_value);

    if (newValue == null) return;

    await updateValue(key, newValue);
  }
  Future<void> button_editNumber(String name, String key, int old_value) async {
    final int? newValue = await alertInput<int>(context, title: "Update Value", text: "Change '$name' to : ", defaultValue: old_value.toString());
    if (newValue == null) return;

    await updateValue(key, newValue);
  }
  Future<void> button_editMangaLength(String name, String key, int old_value) async {
    final int? newValue = await alertInput<int>(context, title: "Update Value", text: "Change '$name' to : ", defaultValue: old_value.toString());
    if (newValue == null) return;

    await updateValue(key, newValue);
  }
  Future<void> button_openLink(String link) async {
    final Uri url = Uri.parse(link);
    try {
      if (!await launchUrl(url)) {
        if (mounted) alert(context, text: "Could not launch link '$link' in browser!");
      }
    } catch (err) {
      if (mounted) alert(context, text: "Could not launch link '$link' in browser!");
    }
  }

  Future<void> updateValue(String key, dynamic value) async {
    final map = manga.toMap();
    map[key] = value;
    final Manga tmpManga = Manga.fromMap(map);
    setState(() {
      manga = tmpManga;
    });

    final db = DatabaseHandler();
    await db.updateManga(tmpManga);
    db.notifyUpdate(DatabaseTables.mangas);
  }

  @override
  void initState() {
    setState(() {
      manga = widget.manga;
			ratingBuffer = (widget.manga.rating == -1) ? 0 : widget.manga.rating;
    });
    super.initState();
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageAppBar(title: manga.topName()),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          MangaCard(manga: manga),
          SizedBox(height: 12),
          editing ? _editDisplay() : _viewDisplay(),
					SizedBox(height: 64),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: button_toggleEdit,
        child: Icon(editing ? Icons.edit_off : Icons.edit),
      ),
    );
  }
  Widget _editDisplay() {
    final List<Widget> arr = [
      _textInfoCard(title: "Chinese Name", key: "ch_name", value: manga.ch_name),
      _textInfoCard(title: "English Name", key: "en_name", value: manga.en_name),
      _textInfoCard(title: "Japanese Name", key: "jp_name", value: manga.jp_name),
      _textInfoCard(title: "Chinese Manga Link", key: "ch_link", value: manga.ch_link),
      _textInfoCard(title: "English Manga Link", key: "en_link", value: manga.en_link),
      _textInfoCard(title: "Japanese Manga Link", key: "jp_link", value: manga.jp_link),
      _textInfoCard(title: "Image Link", key: "img_link", value: manga.img_link),
      _numberInfoCard(title: "Chapter Count", key: "chapter_count", value: manga.chapter_count),
      _mangaLengthCard(),
      _ratingCard(editable: true),
    ];

    return AppCardSplash(
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder:(context, index) => arr[index],
        separatorBuilder: (context, index) => Divider(height: 0),
        itemCount: arr.length,
      ),
    );
  }
  Widget _textInfoCard({required String title, String key = "", required String value}) {
    return ListTile(
      onTap: key.isNotEmpty ? () => button_editString(title, key, value) : null,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      title: Text(title),
      subtitle: value.isEmpty ? const Text("Not Provided") : Text(value),
    );
  }
  Widget _numberInfoCard({required String title, String key = "", required int value}) {
    return ListTile(
      onTap: key.isNotEmpty ? () => button_editNumber(title, key, value) : null,
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
        selected: manga.length.toString(), 
        inputList: MangaLength.values.map((value) => value.toString()).toList(),
        onSelectIndex: (int index) {
          updateValue("length", MangaLength.values[index]);
        }
      ) : null,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      title: Text("Manga Length"),
      subtitle: Text(manga.length.toString()),
    );
  }
  Widget _ratingCard({ bool editable = false }) {
    return Column(
			mainAxisSize: MainAxisSize.min,
			children: [
				ListTile(
					contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
					title: Text("Rating : ${manga.rating == -1 ? "Off" : "${ratingBuffer.toStringAsFixed(1)}/5.0"}"),
					trailing: Wrap(
						spacing: 16,
						children: [
							if (manga.rating != -1 && !editable) StarRating(value: manga.rating),
							editable ? Switch(
								value: (manga.rating != -1), 
								onChanged: (bool toggled) {
									if (manga.rating == -1) {
										updateValue("rating", (ratingBuffer*10).round()/10);
									} else {
										updateValue("rating", -1.0);
									}
								}
							) : SizedBox(width: 24)
						],
					),
				),
				if (editable && manga.rating != -1) ...[
					StarRating(value: ratingBuffer),
          Slider(
            min: 0,
            max: 5,
            value: ratingBuffer, 
            onChanged: (newValue) {
              setState(() {
                ratingBuffer = newValue;
              });
            },
						onChangeEnd: (newValue) {
							setState(() {
							  updateValue("rating", (newValue*10).round()/10);
							});
						},
          )
				]
			],
		);
  }

  Widget _viewDisplay() {
    final List<Widget> arr = [];

    if (manga.ch_link.isNotEmpty) arr.add(_linkDisplay(title: "Manga (Chinese)", link: manga.ch_link));
    if (manga.en_link.isNotEmpty) arr.add(_linkDisplay(title: "Manga (English)", link: manga.en_link));
    if (manga.jp_link.isNotEmpty) arr.add(_linkDisplay(title: "Manga (Japanese)", link: manga.jp_link));
    if (manga.ch_name.isNotEmpty) arr.add(_textInfoCard(title: "Chinese Name", value: manga.ch_name));
    if (manga.en_name.isNotEmpty) arr.add(_textInfoCard(title: "English Name", value: manga.en_name));
    if (manga.jp_name.isNotEmpty) arr.add(_textInfoCard(title: "Japanese Name", value: manga.jp_name));
    arr.addAll([
      _numberInfoCard(title: "Chapter Count", value: manga.chapter_count),
      _mangaLengthCard(),
      _ratingCard(),
    ]);

    return AppCardSplash(
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder:(context, index) => arr[index],
        separatorBuilder: (context, index) => Divider(height: 0),
        itemCount: arr.length,
      ),
    );
  }
  Widget _linkDisplay({required String title, required String link}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      title: Text(title),
      trailing: Card(
        child: TextButton(
          onPressed: () => button_openLink(link),
          child: const Text("Open Link")
        ),
      ),
    );
  }
}