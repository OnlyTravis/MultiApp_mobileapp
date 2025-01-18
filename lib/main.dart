import 'package:flutter/material.dart';
import 'package:multi_app/pages/home_page.dart';

void main() {
  runApp(const MultiApp());
}

class MultiApp extends StatelessWidget {
  const MultiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}