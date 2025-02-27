import 'package:flutter/material.dart';

enum ExpandableListTileTrailing {
	toggledSwitch,
	expandIcon;
}
class ExpandableListTile extends StatefulWidget {
	final Function(bool)? onToggle;
	final Widget? title;
	final Widget? subtitle;
	final EdgeInsetsGeometry? bodyPadding;
	final ExpandableListTileTrailing? trailingStyle;
	final CrossAxisAlignment crossAxisAlignment;
	final Widget? child;
	
	const ExpandableListTile({
		super.key,
		this.onToggle,
		this.title,
		this.subtitle,
		this.bodyPadding,
		this.crossAxisAlignment = CrossAxisAlignment.center,
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
			crossAxisAlignment: widget.crossAxisAlignment,
			children: [
				ListTile(
					onTap: _onToggle,
					title: widget.title,
					subtitle: widget.subtitle,
					trailing: _trailingWidget(),
				),
				if (expanded && widget.child != null) (widget.bodyPadding == null) ? widget.child! : Padding(
					padding: widget.bodyPadding!,
					child: widget.child,
				),
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
			case ExpandableListTileTrailing.expandIcon:
				return (expanded) ? const Icon(Icons.arrow_drop_up) : const Icon(Icons.arrow_drop_down);
		}
	}
}