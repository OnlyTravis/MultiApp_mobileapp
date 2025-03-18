import 'package:flutter/material.dart';

class RoundedBottomNavigationBarItem {
	final String title;
	final Widget icon;

	const RoundedBottomNavigationBarItem({
		required this.title,
		required this.icon,
	});
}
class RoundedBottomNavigationBar extends StatelessWidget {
	final int selectedIndex;
	final List<RoundedBottomNavigationBarItem> items;
	final Function(int) onSelect;
	const RoundedBottomNavigationBar({
		super.key,
		required this.onSelect,
		this.selectedIndex = 0,
		required this.items,
	});

	@override
  Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			decoration: BoxDecoration(
				borderRadius: BorderRadius.vertical(
					top: Radius.elliptical(MediaQuery.sizeOf(context).width, 30),
				),
				color: Theme.of(context).colorScheme.primaryContainer,
			),
			padding: const EdgeInsets.only(
				top: 16,
				bottom: 8,
				left: 16,
				right: 16,
			),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.center,
				spacing: 24,
				children: List.generate(items.length, (int index) => Container(
					decoration: BoxDecoration(
						borderRadius: const BorderRadius.all(Radius.circular(32)),
						color: (selectedIndex == index) ? const Color.fromARGB(11, 135, 135, 135) : null,
					),
					child: IconButton(
						onPressed: () => onSelect(index),
						color: (selectedIndex == index) ? Theme.of(context).colorScheme.primary : Colors.black,
						icon: Wrap(
							direction: Axis.vertical,
							crossAxisAlignment: WrapCrossAlignment.center,
							children: [
								items[index].icon,
								Text(
									items[index].title, 
									style: (selectedIndex == index) ? TextStyle(
										color: Theme.of(context).colorScheme.primary
									) : null,
								),
							],
						)
					)
				)),
			),
		);
	}
}