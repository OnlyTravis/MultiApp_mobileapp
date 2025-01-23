import 'package:flutter/material.dart';

import 'package:multi_app/pages/home_page.dart';
import 'package:multi_app/pages/pages.dart';

class Navigation {
  final String title;
  final IconData? icon;
  final Pages page;

  const Navigation({required this.title, this.icon, required this.page});
}
class NavigationWrap extends StatefulWidget {
  final String title;
  final Widget? child;

  const NavigationWrap({super.key, required this.title, this.child});

  @override
  State<NavigationWrap> createState() => _NavigationWrapState();
}
class _NavigationWrapState extends State<NavigationWrap> {
  static int selectIndex = 0;
  final CarouselController _controller = CarouselController();

  static final List<Navigation> navigationList = [
    Navigation(title: "Home", icon: Icons.home, page: Pages.homePage),
    ...List.generate(10, (int index) => Navigation(title: "Item $index", page: Pages.none))
  ];

  void button_onNavigate(int index) {
    selectIndex = index;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, _, __) => toPage(navigationList[index].page),
        
      ),
      (_) => false
    );
  }

  Widget toPage(Pages page) {
    switch (page) {
      case Pages.homePage: return HomePage();
      
      default: return NavigationWrap(title: "Empty Page");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(widget.title),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Column(
          children: [
            _navigationBar(),
            _pageBody()
          ],
        ),
      ),
    );
  }

  Widget _navigationBar() {
    return SizedBox(
      height: 64,
      child: CarouselView.weighted(
        controller: _controller,
        itemSnapping: true,
        flexWeights: [2, 3, 4, 3, 2],
        backgroundColor: Colors.transparent,
        onTap: (int index) => button_onNavigate(index),
        children: [
          ...navigationList.asMap().entries.map((entry) => _navigationButton(title: entry.value.title, icon: entry.value.icon, page: entry.value.page, index: entry.key))
        ],
      ),
    );
  }
  Widget _navigationButton({ required String title, IconData? icon, required Pages page, required int index }) {
    return Stack(
      children: [
        Center(
          child: InkWell(
            onTap: () => button_onNavigate(index), 
            child: Text(title, overflow: TextOverflow.fade, softWrap: false)
          ),
        )
      ],
    );
  }

  Widget _pageBody() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32))
        ),
        child: widget.child,
      ),
    );
  }
}