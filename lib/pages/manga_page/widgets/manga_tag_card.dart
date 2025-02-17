import 'package:flutter/material.dart';
import 'package:multi_app/code/classes.dart';
import 'package:multi_app/code/database_handler.dart';
import 'package:multi_app/widgets/app_card.dart';
import 'package:multi_app/widgets/tag_card.dart';

class MangaTagListCard extends StatefulWidget {
	final List<MangaTag> tagList;
	final Widget? title;
	final Function(List<MangaTag>)? onAddTags;
	final Function(MangaTag)? onRemoveTag;

	const MangaTagListCard({
		super.key, 
		required this.tagList,
		this.title,
		this.onAddTags,
		this.onRemoveTag
	});

	@override
  State<MangaTagListCard> createState() => _MangaTagListCardState();
}
class _MangaTagListCardState extends State<MangaTagListCard> {
	List<MangaTag> allTagList = [];
	List<MangaTag> exclusiveTagList = [];

	Future<void> button_onAddTag(BuildContext context) async {
		List<int> selectedTagIndices = [];
		await showDialog(
			context: context,
			builder: (BuildContext context) => AlertDialog(
				title: const Text("Select tag(s) to Add"),
				content: exclusiveTagList.isEmpty ? const Text("No other tags available to add.") : _SelectableTagWrap(
					tagList: exclusiveTagList,
					selectedIndices: selectedTagIndices,
				),
				actions: [
					TextButton(
						onPressed: () {
							widget.onAddTags!(selectedTagIndices.map((int index) => exclusiveTagList[index]).toList());
							Navigator.pop(context);
						},
						child: const Text('Add'),
					),
					TextButton(
						onPressed: () {
							Navigator.pop(context);
						},
						child: const Text('Cancel'),
					),
				],
			),
		);
	}

	Future<void> fetchTagList() async {
		final db = DatabaseHandler();
		final tmpAllTagList = await db.getAllMangaTag();
		final tagIdList = widget.tagList.map((MangaTag tag) => tag.id).toList();
		setState(() {
			allTagList = tmpAllTagList;
			exclusiveTagList = tmpAllTagList.where((MangaTag tag) => !tagIdList.contains(tag.id)).toList();
		});
	}

	@override
  void initState() {
    fetchTagList();
    super.initState();
  }

	@override
  void didUpdateWidget(covariant MangaTagListCard oldWidget) {
    final tagIdList = widget.tagList.map((MangaTag tag) => tag.id).toList();
		setState(() {
			exclusiveTagList = allTagList.where((MangaTag tag) => !tagIdList.contains(tag.id)).toList();
		});
    super.didUpdateWidget(oldWidget);
  }

	@override
  Widget build(BuildContext context) {
    return AppCard(
			padding: const EdgeInsets.all(8),
			child: Column(
				mainAxisSize: MainAxisSize.min,
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					if (widget.title != null) widget.title!,
					Wrap(
						children: widget.tagList.map((MangaTag tag) => TagCard(
							name:	tag.name,
							count: tag.count,
							onRemove: widget.onRemoveTag == null ? null : () => widget.onRemoveTag!(tag),
						)).toList(),
					),
					if (widget.onAddTags != null) IconButton(
						onPressed: () => button_onAddTag(context),
						style: IconButton.styleFrom(
							backgroundColor: Theme.of(context).colorScheme.secondaryContainer
						),
						icon: const Row(
							mainAxisSize: MainAxisSize.min,
							children: [
								Text("Add tag"),
								Icon(Icons.add),
							],
						),
					),
				],
			),
		);
  }
}

class _SelectableTagWrap extends StatefulWidget {
	final List<MangaTag> tagList;
	final List<int> selectedIndices;

	const _SelectableTagWrap({
		required this.tagList,
		required this.selectedIndices,
	});

	@override
  State<_SelectableTagWrap> createState() => _SelectableTagWrapState();
}
class _SelectableTagWrapState extends State<_SelectableTagWrap> {
	List<MangaTag> tagList = [];
	List<int> selectedIndices = [];

	@override
  void initState() {
    setState(() {
			tagList = widget.tagList;
      selectedIndices = widget.selectedIndices;
    });
    super.initState();
  }

	@override
  Widget build(BuildContext context) {
    return Wrap(
			children: tagList.asMap().entries.map((entry) => TagCard(
				name: entry.value.name,
				count: entry.value.count,
				color: selectedIndices.contains(entry.key) ? Colors.blue : null,
				onTap: () {
					setState(() {
						if (selectedIndices.contains(entry.key)) {
							tagList[entry.key].count--;
							selectedIndices.remove(entry.key);
						} else {
							tagList[entry.key].count++;
							selectedIndices.add(entry.key);
						}
					});
				},
			)).toList(),
		);
  }
}