import 'package:flutter/material.dart';

class PopUpSelectMenuItem {
	final String label;
	final Widget child;

	PopUpSelectMenuItem({
		required this.label,
		Widget? child,
	}):
		child = child ?? Text(label);
}
class PopUpSelectMenu extends StatelessWidget {
	final List<PopUpSelectMenuItem> menuItems;
	final int selectedIndex;
	final Function(int) onChanged;
	const PopUpSelectMenu({
		super.key,
		required this.selectedIndex,
		required this.menuItems,
		required this.onChanged,
	});

	@override
  Widget build(BuildContext context) {
    return MenuAnchor(
			menuChildren: menuItems.asMap().entries.map((entry) => MenuItemButton(
				onPressed: () => onChanged(entry.key),
				child: entry.value.child,
			)).toList(),
			builder: (context, controller, _) => TextButton(
				onPressed: () {
					if (controller.isOpen) {
						controller.close();
					} else {
						controller.open();
					}
				}, 
				child: Text(menuItems[selectedIndex].label)
			),
		);
  }
}