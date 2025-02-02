import 'package:flutter/material.dart';
import 'package:multi_app/code/alert.dart';
import 'package:multi_app/code/classes.dart';
import 'package:multi_app/code/database_handler.dart';
import 'package:multi_app/widgets/app_card.dart';
import 'package:multi_app/widgets/manga_card.dart';
import 'package:multi_app/widgets/page_appbar.dart';
import 'package:multi_app/widgets/select_page.dart';

class ViewMangaPage extends StatefulWidget {
  final Manga manga;
  const ViewMangaPage({super.key, required this.manga});

  @override
  State<ViewMangaPage> createState() => _ViewMangaPageState();
}
class _ViewMangaPageState extends State<ViewMangaPage> {
  late Manga manga;
  bool showAll = false;

  void button_toggleShowAll() {
    setState(() {
      showAll = !showAll;
    });
  }
  Future<void> button_editString(String name, String key, String old_value) async {
    final String newValue = await alertInput(context, title: "Update Value", text: "Change '$name' to : ", defaultValue: old_value);
    if (newValue.isEmpty) return;

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

  Future<void> updateValue(String key, dynamic value) async {
    final map = manga.toMap();
    map[key] = value;
    setState(() {
      manga = Manga.fromMap(map);
    });

    final db = DatabaseHandler();
    await db.updateManga(manga);
    db.notifyUpdate(DatabaseTables.mangas);
  }

  @override
  void initState() {
    setState(() {
      manga = widget.manga;
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
          _infoDisplay(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: button_toggleShowAll,
        child: Icon(showAll ? Icons.visibility_off : Icons.visibility),
      ),
    );
  }
  Widget _infoDisplay() {
    List<Widget> arr = [];
    if (showAll || manga.ch_name.isNotEmpty) arr.add(_textInfoCard(title: "Chinese Name", key: "ch_name", value: manga.ch_name));
    if (showAll || manga.en_name.isNotEmpty) arr.add(_textInfoCard(title: "English Name", key: "en_name", value: manga.en_name));
    if (showAll || manga.jp_name.isNotEmpty) arr.add(_textInfoCard(title: "Japanese Name", key: "jp_name", value: manga.jp_name));
    if (showAll || manga.ch_link.isNotEmpty) arr.add(_textInfoCard(title: "Chinese Manga Link", key: "ch_link", value: manga.ch_link));
    if (showAll || manga.en_link.isNotEmpty) arr.add(_textInfoCard(title: "English Manga Link", key: "en_link", value: manga.en_link));
    if (showAll || manga.jp_link.isNotEmpty) arr.add(_textInfoCard(title: "Japanese Manga Link", key: "jp_link", value: manga.jp_link));
    if (showAll || manga.img_link.isNotEmpty) arr.add(_textInfoCard(title: "Image Link", key: "img_link", value: manga.img_link));
    
    arr.addAll([
      _numberInfoCard(title: "Chapter Count", key: "chapter_count", value: manga.chapter_count),
      _mangaLengthCard(),
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
  Widget _textInfoCard({required String title, required String key, required String value}) {
    return ListTile(
      onTap: () => button_editString(title, key, value),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      title: Text(title),
      subtitle: value.isEmpty ? const Text("Not Provided") : Text(value),
    );
  }
  Widget _numberInfoCard({required String title, required String key, required int value}) {
    return ListTile(
      onTap: () => button_editNumber(title, key, value),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      title: Text(title),
      subtitle: Text(value.toString()),
    );
  }
  Widget _mangaLengthCard() {
    return ListTile(
      onTap: () => selectPageInput(
        context, 
        title: "Manga Length", 
        selected: manga.length.toString(), 
        inputList: MangaLength.values.map((value) => value.toString()).toList(),
        onSelectIndex: (int index) {
          updateValue("length", MangaLength.values[index]);
        }
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      title: Text("Manga Length"),
      subtitle: Text(manga.length.toString()),
    );
  }
}