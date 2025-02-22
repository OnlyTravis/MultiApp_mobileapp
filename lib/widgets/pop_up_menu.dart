import 'package:flutter/material.dart';

class PopUpSelectMenu extends StatefulWidget {
	final Function(int) onChanged;
	final Icon? leadingIcon;
	final int selectedIndex;
	final List<String> menuItems;

	const PopUpSelectMenu({
		super.key,
		required this.onChanged,
		this.leadingIcon,
		required this.selectedIndex,
		required this.menuItems,
	});

	@override
  State<PopUpSelectMenu> createState() => _PopUpSelectMenuState();
}
class _PopUpSelectMenuState extends State<PopUpSelectMenu> {
	final FocusNode _buttonFocusNode = FocusNode();

	@override
  void dispose() {
    _buttonFocusNode.dispose();
    super.dispose();
  }

	@override
  Widget build(BuildContext context) {
    return MenuAnchor(
			childFocusNode: _buttonFocusNode,
			alignmentOffset: const Offset(0, -40),
			style: MenuStyle(
				backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.secondaryContainer),
				shape: WidgetStateProperty.all(const RoundedRectangleBorder(
					borderRadius: BorderRadius.all(Radius.circular(16))
				)),
			),
			menuChildren: widget.menuItems.asMap().entries.map((entry) {
				bool selected = (entry.key == widget.selectedIndex);
				return MenuItemButton(
					onPressed: () => widget.onChanged(entry.key),
					child: Padding(
						padding: const EdgeInsets.symmetric(horizontal: 16),
						child: Row(
							mainAxisSize: MainAxisSize.min,
							mainAxisAlignment: MainAxisAlignment.spaceBetween,
							spacing: 32,
							children: [
								Text(
									entry.value, 
									style: selected ? TextStyle(
										color: Theme.of(context).colorScheme.primary,
									) : null
								),
								selected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : const SizedBox(width: 24),
							],
						),
					),
				);
			}).toList(),
			builder: (context, controller, _) => TextButton(
				focusNode: _buttonFocusNode,
				onPressed: () {
					if (controller.isOpen) {
						controller.close();
					} else {
						controller.open();
					}
				}, 
				child: (widget.leadingIcon == null) ? Text(widget.menuItems[widget.selectedIndex]) : Row(
					mainAxisSize: MainAxisSize.min,
					children: [
						widget.leadingIcon!,
						Text(widget.menuItems[widget.selectedIndex]),
					],
				)
			),
		);
  }
}