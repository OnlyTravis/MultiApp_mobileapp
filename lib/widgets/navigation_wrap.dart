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

  void initPosition() {
    Size size = MediaQuery.of(context).size;
    double width = size.width;

    _controller.jumpTo(selectIndex * width * 2 / 11);
  }

  @override
  void initState() {
    // Runs after build
    WidgetsBinding.instance.addPostFrameCallback((_) => initPosition());
    _controller.addListener(() {
      print("AAAAAA");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: const Text("Multi-App", textScaler: TextScaler.linear(1.5)),
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
      height: 48,
      child: CarouselView.weighted(
        controller: _controller,
        itemSnapping: true,
        flexWeights: [2, 2, 3, 2, 2],
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
          child: Text(
            title, 
            overflow: TextOverflow.fade, 
            softWrap: false,
            textScaler: (selectIndex == index)?TextScaler.linear(1.5):null,
          )
        )
      ],
    );
  }

  Widget _pageBody() {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32))
        ),
        child: widget.child,
      ),
    );
  }
}