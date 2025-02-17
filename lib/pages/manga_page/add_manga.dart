import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_app/code/alert.dart';
import 'package:multi_app/code/classes.dart';
import 'package:multi_app/code/database_handler.dart';
import 'package:multi_app/pages/manga_page/widgets/manga_tag_card.dart';
import 'package:multi_app/widgets/app_card.dart';
import 'package:multi_app/widgets/page_appbar.dart';
import 'package:multi_app/widgets/select_page.dart';
import 'package:multi_app/widgets/star_rating.dart';

class AddMangaPage extends StatefulWidget {
	const AddMangaPage({super.key});

	@override
	State<AddMangaPage> createState() => _AddMangaPageState();
}
class _AddMangaPageState extends State<AddMangaPage> {
	List<TextEditingController> inputNameControllers = [TextEditingController(), TextEditingController(), TextEditingController()];
	List<TextEditingController> inputLinkControllers = [TextEditingController(), TextEditingController(), TextEditingController()];
	TextEditingController imageLinkController = TextEditingController();
	TextEditingController chapterCountController = TextEditingController();

	bool toggleRating = false;
	double rating = 0;
	bool ended = false;
	MangaLength mangaLength = MangaLength.short;
	List<MangaTag> tagList = [];

	bool checkValues() {
		// Atlease 1 name
		bool failed = true;
		for (final controller in inputNameControllers) {
			if (controller.text.isNotEmpty) {
				failed = false;
				break;
			}
		}
		if (failed) {
			alert(context, text: "Please enter atleast 1 valid manga name.");
			return false;
		}

		// Number of Chapters
		if (chapterCountController.text.isEmpty) {
			alert(context, text: "Please Enter Number of Chapters");
			return false;
		}

		return true;
	}
	Future<void> button_onCreateManga() async {
		// 1. Check Values & Confirm creation
		if (!checkValues()) return;
		if (!await confirm(context, title: "Confirm Creating", text: "Are you sure you want to create this manga entry?")) return;

		// 2. Add Manga record in Database
		final db = DatabaseHandler();
		final Manga manga = Manga(
			ch_name: inputNameControllers[0].text,
			en_name: inputNameControllers[1].text,
			jp_name: inputNameControllers[2].text,
			ch_link: inputLinkControllers[0].text,
			en_link: inputLinkControllers[1].text,
			jp_link: inputLinkControllers[2].text,
			img_link: imageLinkController.text,
			id: -1, 
			chapter_count: int.parse(chapterCountController.text),
			rating: toggleRating ? (rating*10).round()/10 : -1,
			length: mangaLength,
			ended: ended,
			tag_list: tagList.map((MangaTag tag) => tag.id).toList(),
		);
		await db.createManga(manga);

		// 3. Update Tag's count in database
		for (final tag in tagList) {
			await db.updateMangaTag(tag);
		}

		// 4. Alert + pop navigation route
		if (mounted) {
			alert(context, text: "Manga Added !");
			Navigator.pop(context);
			db.notifyUpdate(DatabaseTables.mangas);
			if (tagList.isNotEmpty) db.notifyUpdate(DatabaseTables.mangaTags);
		}
	}
	void button_onAddTags(List<MangaTag> addTagList) {
		setState(() {
			tagList.addAll(addTagList);
		});
	}
	void button_onRemoveTag(MangaTag removeTag) {
		int index = tagList.indexWhere((MangaTag tag) => tag.id == removeTag.id);
		tagList[index].count--;
		setState(() {
			tagList.removeAt(index);
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: const PageAppBar(title: "Add Manga"),
			body: Container(
				color: Theme.of(context).colorScheme.primaryContainer,
				child: ListView(
					padding: const EdgeInsets.all(8),
					children: [
						_cardTitle(title: "1. Manga Names : (atleast 1)"),
						_textInputCard(labelList: const ["Chinese Name", "English Name", "Japanese Name"], controllerList: inputNameControllers),
						_cardTitle(title: "2. Manga Links : (optional)"),
						_textInputCard(labelList: const ["Chinese Link", "English Link", "Japanese Link"], controllerList: inputLinkControllers),
						_cardTitle(title: "3. Manga Image Link : (optional)"),
						_textInputCard(labelList: const ["Image Link"], controllerList: [imageLinkController]),
						_cardTitle(title: "4. Manga States : "),
						_mangaStateInputCard(),            
						_cardTitle(title: "5. Manga Tags : (optional)"),
						MangaTagListCard(
							tagList: tagList,
							onAddTags: button_onAddTags,
							onRemoveTag: button_onRemoveTag,
						),
						_confirmCard(),
					],
				),
			),
		);
	}
	Widget _cardTitle({String title = ""}) {
		return Padding(
			padding: const EdgeInsets.only(left: 20, top: 8),
			child: Text(title, textScaler: const TextScaler.linear(1.3)),
		);
	}
	Widget _textInputCard({required List<String> labelList, required List<TextEditingController> controllerList}) {
		if (labelList.length != controllerList.length) {
			throw Exception("Length of labelList does not match with length of controllerList in _textInputCard in addMangaPage.");
		}
		return AppCard(
			padding: const EdgeInsets.all(16),
			child: ListView.separated(
				physics: const NeverScrollableScrollPhysics(),
				shrinkWrap: true,
				separatorBuilder: (context, index) => const Divider(),
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

	Widget _mangaStateInputCard() {
		return AppCardSplash(
			color: Theme.of(context).colorScheme.surfaceContainerLow,
			child: Column(
				children: [
					_ratingInput(),
					const Divider(height: 0),
					_chapterInput(),
					const Divider(height: 0),
					_endedInput(),
					const Divider(height: 0),
					_lengthInput(),
				],
			),
		);
	}
	Widget _ratingInput() {
		return Column(
			mainAxisSize: MainAxisSize.min,
			children: [
				ListTile(
					contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
					title: Text(toggleRating?"Rating : ${(rating*10).round()/10} / 5.0":"Rating : Off"),
					trailing: Switch(
						value: toggleRating, 
						onChanged: (bool newValue) {
							setState(() {
								toggleRating = newValue;
							});
						}
					),
					onTap: () {
						setState(() {
							toggleRating = !toggleRating;
						});
					},
				),
				if (toggleRating) ...[
					StarRating(value: (rating*10).round()/10),
					Slider(
						min: 0,
						max: 5,
						value: rating, 
						onChanged: (newValue) {
							setState(() {
								rating = newValue;
							});
						}
					)
				]
			],
		);
	}
	Widget _chapterInput() {
		return ListTile(
			title: const Text("Number of Chapters : "),
			contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
			trailing: SizedBox(
				width: 128,
				child: TextField(
					keyboardType: const TextInputType.numberWithOptions(decimal: false),
					inputFormatters: [
						FilteringTextInputFormatter.digitsOnly,
					],
					decoration: const InputDecoration(
						border: OutlineInputBorder(),
					),
					controller: chapterCountController,
				),
			),
		);
	}
	Widget _endedInput() {
		return ListTile(
			contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
			title: const Text("Ended : "),
			trailing: Switch(
				value: ended, 
				onChanged: (bool newValue) {
					setState(() {
						ended = newValue;
					});
				}
			),
			onTap: () {
				setState(() {
					ended = !ended;
				});
			},
		);
	}
	Widget _lengthInput() {
		return ListTile(
			onTap: () => selectPageInput(
				context, 
				title: "Manga Length",
				selected: mangaLength.toString(),
				inputList: MangaLength.values.map((value) => value.toString()).toList(),
				onSelectIndex: (int index) {
					setState(() {
						mangaLength = MangaLength.values[index];
					});
				},
			),
			contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
			title: const Text("Manga Length : "),
			subtitle: Text(mangaLength.toString()),
		);
	}
	Widget _confirmCard() {
		return AppCard(
			margin: const EdgeInsets.only(top: 8),
			child: TextButton(
				onPressed: button_onCreateManga, 
				child: const Text("Create Manga Entry")
			),
		);
	}
}