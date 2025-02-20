import 'package:flutter/material.dart';
import 'package:multi_app/widgets/page_appbar.dart';

void selectPageInput(BuildContext context, {
	required String title,
	required String selected,
	required List<String> inputList,
	Function(int)? onSelectIndex,
}) {
	Navigator.of(context).push(
		MaterialPageRoute(
			builder: (_) => SelectPage(
				title: title,
				selected: selected,
				inputList: inputList,
				onSelectIndex: onSelectIndex,
			)
		)
	);
}

class SelectPage extends StatefulWidget {
	final String title;
	final String selected;
	final List<String> inputList;
	final void Function(int)? onSelectIndex;

	const SelectPage({super.key, required this.title, required this.selected, required this.inputList, this.onSelectIndex});

	@override
	State<SelectPage> createState() => _SelectPageState();
}
class _SelectPageState extends State<SelectPage> {
	String _selected = "";
	void _onTap(int index) {
		setState(() {
			_selected = widget.inputList[index];
		});
		widget.onSelectIndex!(index);
		Navigator.of(context).pop();
	}

	@override
	void initState() {
		if (!widget.inputList.contains(_selected)) assert(!widget.inputList.contains(_selected), 'The expected element is not in the list. (SelectPage)');
		setState(() {
			_selected = widget.selected;
		});
		super.initState();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: PageAppBar(title: widget.title),
			body: Stack(
				children: [
					Container(
						color: Theme.of(context).colorScheme.primaryContainer,
						height: double.infinity,
					),
					Container(
						clipBehavior: Clip.antiAlias,
						decoration: const BoxDecoration(
							borderRadius: BorderRadius.all(Radius.circular(16))
						),
						margin: const EdgeInsets.all(8),
						child: Material(
							color: Theme.of(context).colorScheme.surfaceContainerLow,
							child: ListView.separated(
								shrinkWrap: true,
								itemCount: widget.inputList.length,
								separatorBuilder: (context, index) => const Divider(height: 0, indent: 56),
								itemBuilder: (context, index) => ListTile(
									leading: Icon((widget.inputList[index] == _selected)?Icons.radio_button_checked:Icons.radio_button_off),
									title: Text(widget.inputList[index]),
									onTap: () => _onTap(index),
								),
							),
						),
					),
				]
			),
		);
	}
}