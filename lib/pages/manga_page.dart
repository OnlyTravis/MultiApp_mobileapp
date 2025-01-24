import 'package:flutter/material.dart';
import 'package:multi_app/widgets/navigation_wrap.dart';

class MangaPage extends StatefulWidget {
  const MangaPage({super.key});
  
  @override
  State<MangaPage> createState() => _MangaPageState();
}
class _MangaPageState extends State<MangaPage> {
  @override
  Widget build(BuildContext context) {
    return NavigationWrap(
      title: "Manga Page"
    );
  }
}