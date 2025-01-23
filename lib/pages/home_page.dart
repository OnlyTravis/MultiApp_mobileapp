import 'package:flutter/material.dart';
import 'package:multi_app/widgets/navigation_wrap.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return NavigationWrap(
      title: "Home Page",
      child: Text("This is home"),
    );
  }
}