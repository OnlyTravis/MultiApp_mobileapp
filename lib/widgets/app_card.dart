import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
	final EdgeInsetsGeometry? padding;
	final EdgeInsetsGeometry? margin;
	final Color? color;
	final Widget? child;
	const AppCard({super.key, this.color, this.padding, this.margin, this.child});

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: padding,
			margin: margin,
			decoration: BoxDecoration(
				boxShadow: [
					BoxShadow(
						color: const Color.fromARGB(255, 0, 0, 0).withAlpha(32),
						spreadRadius: 1,
						blurRadius: 1,
						offset: const Offset(1, 1), // changes position of shadow
					),
				],
				borderRadius: const BorderRadius.all(Radius.circular(10)),
				color: (color ?? Theme.of(context).colorScheme.surfaceContainerLow)
			),
			child: child,
		);
	}
}
class AppCardSplash extends StatelessWidget {
	final EdgeInsetsGeometry? padding;
	final EdgeInsetsGeometry? margin;
	final Color? color;
	final Widget? child;
	const AppCardSplash({super.key, this.color, this.padding, this.margin, this.child});

	@override
	Widget build(BuildContext context) {
		return Container(
			clipBehavior: Clip.antiAlias,
			padding: padding,
			margin: margin,
			decoration: BoxDecoration(
				boxShadow: [
					BoxShadow(
						color: const Color.fromARGB(255, 0, 0, 0).withAlpha(32),
						spreadRadius: 1,
						blurRadius: 1,
						offset: const Offset(1, 1), // changes position of shadow
					),
				],
				borderRadius: const BorderRadius.all(Radius.circular(10)),
			),
			child: Material(
				color: (color ?? Theme.of(context).colorScheme.surfaceContainerLow),
				child: (padding == null) ? 
					child
					: Padding(padding: padding ?? const EdgeInsets.all(0), child: child) 
			),
		);
	}
}