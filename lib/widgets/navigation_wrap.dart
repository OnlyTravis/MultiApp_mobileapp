import 'package:flutter/material.dart';
import 'package:multi_app/pages/pages.dart';

class TabData {
	final String title;
	final Pages page;

	const TabData({required this.title, required this.page});
}
class NavigationWrap extends StatefulWidget {
	const NavigationWrap({super.key});

	@override
	State<NavigationWrap> createState() => _NavigationWrapState();
}
class _NavigationWrapState extends State<NavigationWrap> with TickerProviderStateMixin {
	final List<TabData> tabList = [
		const TabData(title: "Home", page: Pages.homePage),
		const TabData(title: "Manga", page: Pages.mangaPage),
		...List.generate(10, (int index) => TabData(title: "Item $index", page: Pages.none))
	];

	@override
	Widget build(BuildContext context) {
		return DefaultTabController(
			initialIndex: 0,
			length: tabList.length, 
			child: Scaffold(
				appBar: AppBar(
					backgroundColor: Theme.of(context).colorScheme.primaryContainer,
					title: const Text("Multi-App", textScaler: TextScaler.linear(1.5)),
					bottom: _navigationBar()
				),
				body: TabBarView(
					children: tabList.map((TabData tab) => toPage(tab.page)).toList(),
				),
			),
		);
	}

	TabBar _navigationBar() {
		return TabBar(
			physics: const BouncingScrollPhysics(),
			isScrollable: true,
			tabAlignment: TabAlignment.center,
			tabs: tabList.map((TabData tab) => Tab(
				text: tab.title,
			)).toList()
		);
	}
}