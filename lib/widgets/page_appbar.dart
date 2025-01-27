import 'package:flutter/material.dart';

class PageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  const PageAppBar({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        }, 
        icon: Icon(Icons.chevron_left),
      ),
      title: (title == null)?null:Text(title ?? ""),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}