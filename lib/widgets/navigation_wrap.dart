import 'package:flutter/material.dart';

import 'package:multi_app/pages/home_page.dart';
import 'package:multi_app/pages/pages.dart';

class NavigationWrap extends StatefulWidget {
  final String title;
  final Widget? child;

  const NavigationWrap({super.key, required this.title, this.child});

  @override
  State<NavigationWrap> createState() => _NavigationWrapState();
}
class _NavigationWrapState extends State<NavigationWrap> {
  Pages selectedPage = Pages.homePage;

  void button_onNavigate(Pages page) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => toPage(page)
      ),
      (_) => false
    );
  }

  Widget toPage(Pages page) {
    switch (page) {
      case Pages.homePage: return HomePage();
      
      default: return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(widget.title),
      ),
      body: widget.child,
      endDrawer: _navigationDrawer(),
    );
  }

  Widget _navigationDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(0),
        children: [
          SizedBox(
            height: 96,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer
              ),
              child: const Text("Multi App"),
            ),
          ),
          _navigationButton(title: "Home", icon: Icons.home, page: Pages.homePage)
        ],
      ),
    );
  }
  Widget _navigationButton({ required String title, required IconData icon, required Pages page }) {
    return GestureDetector(
      onTap: () => button_onNavigate(page),
      child: ListTile(
        title: Text(title),
        leading: Icon(icon),
      ),
    );
  }
}