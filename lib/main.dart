import 'package:flutter/material.dart';
import 'package:multi_app/code/database_handler.dart';
import 'package:multi_app/widgets/navigation_wrap.dart';

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();

	await initDatabaseHandler();

	runApp(const MultiApp());
}

class MultiApp extends StatelessWidget {
	const MultiApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Multi App',
			theme: ThemeData(
				colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
				useMaterial3: true,
			),
			home: const NavigationWrap(),
		);
	}
}