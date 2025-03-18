import 'package:flutter/material.dart';
import 'package:multi_app/pages/pages.dart';

class _TabData {
	final String title;
	final IconData icon;
	final Pages page;

	const _TabData({required this.title, required this.icon, required this.page});
}
class NavigationWrap extends StatefulWidget {
	const NavigationWrap({super.key});

	@override
	State<NavigationWrap> createState() => _NavigationWrapState();
}
class _NavigationWrapState extends State<NavigationWrap> with TickerProviderStateMixin {
	int _currentPageIndex = 0;
	final List<_TabData> _tabList = [
		const _TabData(title: "Home", icon: Icons.home, page: Pages.homePage),
		const _TabData(title: "Manga", icon: Icons.book, page: Pages.mangaPage),
		...List.generate(10, (int index) => _TabData(title: "Item $index", icon: Icons.abc_sharp, page: Pages.none))
	];

	void _navigateTo(int index) {
		Navigator.of(context).pop();
		setState(() {
		  _currentPageIndex = index;
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				backgroundColor: Theme.of(context).colorScheme.primaryContainer,
				title: Row(
					children: [
						const Text("Multi-App", textScaler: TextScaler.linear(1.5)),
						Text("   ---   ${_tabList[_currentPageIndex].title}")
					],
				),
			),
			body: toPage(_tabList[_currentPageIndex].page),
			endDrawer: Drawer(
				backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
				child: ListView(
					padding: const EdgeInsets.all(0),
					children: [
						Container(
							color: Theme.of(context).colorScheme.primaryContainer,
							padding: const EdgeInsets.only(left: 16),
							height: 80,
							child: const Row(
								children: [
									Text('Applications', textScaler: TextScaler.linear(1.5))
								],
							),
						),
						..._tabList.asMap().entries.map((entry) => _drawerTab(entry.value, entry.key)),
					],
				),
			),
		);
	}

	ListTile _drawerTab(_TabData tabData, int index) {
		return ListTile(
			selected: (index == _currentPageIndex),
			selectedTileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
			onTap: () => _navigateTo(index),
			leading: Icon(tabData.icon),
			title: Text(tabData.title),
		);
	}
}