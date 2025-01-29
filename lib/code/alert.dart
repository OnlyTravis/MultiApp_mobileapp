import 'package:flutter/material.dart';

Future<bool> confirm(BuildContext context, String title, String text) async {
  bool confirmed = false;
  await showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text(title),
      content: Text(text),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            confirmed = true;
            Navigator.pop(context);
          },
          child: const Text('Confirm'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
  return confirmed;
}

void alert(BuildContext context, String text, {int duration = 1}) {
  final snack_bar = SnackBar(
    content: Text(text),
    duration: Duration(seconds: duration),
    action: SnackBarAction(
      label: "Dismiss", 
      onPressed: ScaffoldMessenger.of(context).hideCurrentSnackBar
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snack_bar);
}