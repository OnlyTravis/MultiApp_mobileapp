import 'package:flutter/material.dart';

class BottomNavigationWrap extends StatefulWidget {
	final List<String> pageTitles;
	final List<Icon> pageIcons; 
	final List<Widget> pages;
	final int defaultIndex;
	const BottomNavigationWrap({
		super.key,
		required this.pageTitles,
		required this.pageIcons,
		required this.pages,
		this.defaultIndex = 0
	});

	@override
	State<BottomNavigationWrap> createState() => _BottomNavigationWrapState();
}
class _BottomNavigationWrapState extends State<BottomNavigationWrap> {
	int currentIndex = 0;

	void _navigateTo(int index) {
		setState(() {
			currentIndex = index;
		});
	}

	@override
	void initState() {
		if (widget.pageTitles.length != widget.pages.length) {
			throw ErrorDescription("A list of length ${widget.pages.length} expected in the pageTitle argument in BottomNavigationWrap, got a list of length ${widget.pageTitles.length} instead.");
		}
		if (widget.pageIcons.length != widget.pages.length) {
			throw ErrorDescription("A list of length ${widget.pages.length} expected in the pageIcons argument in BottomNavigationWrap, got a list of length ${widget.pageIcons.length} instead.");
		}
		setState(() {
			currentIndex = widget.defaultIndex;
		});
		super.initState();
	}

	Widget _navigationBar() {
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
				children: List.generate(widget.pages.length, (int index) => Container(
					decoration: BoxDecoration(
						borderRadius: const BorderRadius.all(Radius.circular(32)),
						color: (currentIndex == index) ? const Color.fromARGB(11, 135, 135, 135) : null,
					),
					child: IconButton(
						onPressed: () => _navigateTo(index),
						color: (currentIndex == index) ? Theme.of(context).colorScheme.primary : Colors.black,
						icon: Wrap(
							direction: Axis.vertical,
							crossAxisAlignment: WrapCrossAlignment.center,
							children: [
								widget.pageIcons[index],
								Text(
									widget.pageTitles[index], 
									style: (currentIndex == index) ? TextStyle(
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

	@override
	Widget build(BuildContext context) {
		return Flex(
			direction: Axis.vertical,
			children: [
				Flexible(
					child: widget.pages[currentIndex]
				),
				_navigationBar()
			],
		);
	}
}