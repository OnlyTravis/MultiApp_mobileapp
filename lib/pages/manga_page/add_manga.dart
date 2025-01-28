import 'package:flutter/material.dart';
import 'package:multi_app/widgets/app_card.dart';
import 'package:multi_app/widgets/page_appbar.dart';

class AddMangaPage extends StatefulWidget {
  const AddMangaPage({super.key});

  @override
  State<AddMangaPage> createState() => _AddMangaPageState();
}
class _AddMangaPageState extends State<AddMangaPage> {
  List<TextEditingController> inputNameControllers = [TextEditingController(), TextEditingController(), TextEditingController()];
  List<TextEditingController> inputLinkControllers = [TextEditingController(), TextEditingController(), TextEditingController()];
  TextEditingController imageLinkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PageAppBar(title: "Add Manga"),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          _cardTitle(title: "1. Manga Names : (atleast 1)"),
          _textInputCard(labelList: const ["Chinese Name", "English Name", "Japanese Name"], controllerList: inputNameControllers),
          _cardTitle(title: "2. Manga Links : (if any)"),
          _textInputCard(labelList: const ["Chinese Link", "English Link", "Japanese Link"], controllerList: inputLinkControllers),
          _cardTitle(title: "3. Manga Image Link : (if any)"),
          _textInputCard(labelList: const ["Image Link"], controllerList: [imageLinkController]),
          _cardTitle(title: "4. Others : "),

        ],
      ),
    );
  }
  Widget _cardTitle({String title = ""}) {
    return Padding(
      padding: EdgeInsets.only(left: 20, top: 8),
      child: Text(title, textScaler: TextScaler.linear(1.3)),
    );
  }
  Widget _textInputCard({required List<String> labelList, required List<TextEditingController> controllerList}) {
    if (labelList.length != controllerList.length) {
      throw Exception("Length of labelList does not match with length of controllerList in _textInputCard in addMangaPage.");
    }
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        shrinkWrap: true,
        separatorBuilder: (context, index) => Divider(),
        itemCount: labelList.length,
        itemBuilder: (context, index) => TextField(
          minLines: 1,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: labelList[index],
          ),
          controller: controllerList[index],
        ),
      ),
    );
  }
  Widget _otherInputCard() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          
        ],
      ),
    );
  }
}