import 'package:flutter/material.dart';
import 'package:multi_app/code/classes.dart';
import 'package:multi_app/widgets/page_appbar.dart';

class ViewTagPage extends StatefulWidget {
	final MangaTag tag;
	const ViewTagPage({super.key, required this.tag});

	@override
  State<ViewTagPage> createState() => _ViewTagPage();
}
class _ViewTagPage extends State<ViewTagPage> {
	late MangaTag tag;

	@override
  void initState() {
    setState(() {
      tag = widget.tag;
    });
		super.initState();
  }

	@override
  Widget build(BuildContext context) {
    return Scaffold(
			appBar: PageAppBar(title: tag.name),
			body: const Center(child: Text("WIP")),
		);
  }
}