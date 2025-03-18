import 'package:flutter/material.dart';
import 'package:multi_app/pages/manga_page/pages/manga_list.dart';
import 'package:multi_app/pages/manga_page/pages/settings.dart';
import 'package:multi_app/pages/manga_page/pages/tag_list.dart';
import 'package:multi_app/widgets/navigation_bar.dart';

class MangaPage extends StatefulWidget {
	const MangaPage({super.key});

	@override
  State<MangaPage> createState() => _MangaPageState();
}
class _MangaPageState extends State<MangaPage> with SingleTickerProviderStateMixin {
	int _selectedIndex = 0;
	late final TabController _controller;

	void _onSwipe() {
		setState(() {
		  _selectedIndex = _controller.index;
		});
	}

	@override
  void initState() {
		_controller = TabController(length: 3, vsync: this);
		_controller.addListener(_onSwipe);
    super.initState();
  }

	@override
	Widget build(BuildContext context) {
		return Column(
			children: [
				Flexible(
					child: TabBarView(
						controller: _controller,
						children: const [
							MangaListPage(),
							MangaTagListPage(),
							MangaSettingsPage(),
						],
					),
				),
				RoundedBottomNavigationBar(
					selectedIndex: _selectedIndex,
					onSelect: (int index) {
						_controller.animateTo(index);
						setState(() {
						  _selectedIndex = index;
						});
					}, 
					items: const [
						RoundedBottomNavigationBarItem(title: "Manga List", icon: Icon(Icons.list)),
						RoundedBottomNavigationBarItem(title: "Tags", icon: Icon(Icons.tag)),
						RoundedBottomNavigationBarItem(title: "Settings", icon: Icon(Icons.settings)),
					]
				),
			],
		);
	}
}