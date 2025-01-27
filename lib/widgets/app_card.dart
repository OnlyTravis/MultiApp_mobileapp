import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Widget? child;
  const AppCard({super.key, this.padding, this.color, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withAlpha(64),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(1, 1), // changes position of shadow
          ),
        ],
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: (color ?? Theme.of(context).colorScheme.surfaceContainerLow),
      ),
      child: child,
    );
  }
}