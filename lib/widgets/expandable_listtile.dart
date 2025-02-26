import 'package:flutter/material.dart';

enum ExpandableListTileTrailing {
	toggledSwitch;
}
class ExpandableListTile extends StatefulWidget {
	final Function(bool)? onToggle;
	final Widget? title;
	final Widget? subtitle;
	final ExpandableListTileTrailing? trailingStyle;
	final Widget? child;
	
	const ExpandableListTile({
		super.key,
		this.onToggle,
		this.title,
		this.subtitle,
		this.trailingStyle,
		this.child,
	});

	@override
  State<ExpandableListTile> createState() => _ExpandableListTileState();
}
class _ExpandableListTileState extends State<ExpandableListTile> {
	bool expanded = false;

	void _onToggle() {
		if (widget.onToggle != null) widget.onToggle!(!expanded);
		setState(() {
		  expanded = !expanded;
		});
	}

	@override
  Widget build(BuildContext context) {
		return Column(
			mainAxisSize: MainAxisSize.min,
			children: [
				ListTile(
					onTap: _onToggle,
					title: widget.title,
					subtitle: widget.subtitle,
					trailing: _trailingWidget(),
				),
				if (expanded && widget.child != null) widget.child!,
			],
		);
  }
	Widget? _trailingWidget() {
		if (widget.trailingStyle == null) return null;

		switch (widget.trailingStyle!) {
			case ExpandableListTileTrailing.toggledSwitch:
				return Switch(
					value: expanded, 
					onChanged: (_) => _onToggle(),
				);
		}
	}
}