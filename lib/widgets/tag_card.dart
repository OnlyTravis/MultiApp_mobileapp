import 'package:flutter/material.dart';

class TagCard extends StatelessWidget {
  final String name;
	final int count;
	final Color? color;
	final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const TagCard({
		super.key, 
		required this.name,
		required this.count,
		this.color, 
		this.onTap,
		this.onRemove, 
	});

  @override
  Widget build(BuildContext context) {
		bool tapable = onTap != null;
		bool removable = onRemove != null;

    return GestureDetector(
      onTap: tapable?onTap:null,
      child: Card(
        color: Theme.of(context).colorScheme.secondaryContainer,
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (removable) GestureDetector(
              onTap: onRemove,
              child: const Padding(
								padding: EdgeInsets.only(left: 6),
								child: Icon(
									Icons.cancel,
									size: 16,
								),
							),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              child: Text(
								name,
								style: TextStyle(
									color: color
								),
							),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              color: Theme.of(context).colorScheme.surfaceDim,
              child: Text(count.toString()),
            ),
          ],
        ),
      ),
    );
  }
}