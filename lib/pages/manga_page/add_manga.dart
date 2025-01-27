import 'package:flutter/material.dart';
import 'package:multi_app/widgets/app_card.dart';
import 'package:multi_app/widgets/page_appbar.dart';

class AddMangaPage extends StatefulWidget {
  const AddMangaPage({super.key});

  @override
  State<AddMangaPage> createState() => _AddMangaPageState();
}
class _AddMangaPageState extends State<AddMangaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageAppBar(title: "Add Manga"),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Text("1. Manga Name"),
          _nameInputCard()
        ],
      ),
    );
  }
  Widget _nameInputCard() {
    return AppCard(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          TextField(
            minLines: 1,
            maxLines: 5,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Chinese name',
            ),
          ),
        ],
      ),
    );
  }
}