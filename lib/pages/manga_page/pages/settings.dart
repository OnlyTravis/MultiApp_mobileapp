import 'package:flutter/material.dart';
import 'package:multi_app/widgets/app_card.dart';

class MangaSettingsPage extends StatefulWidget {
	const MangaSettingsPage({
		super.key
	});

	@override
  State<MangaSettingsPage> createState() => _MangaSettingsPageState();
}
class _MangaSettingsPageState extends State<MangaSettingsPage> {
	@override
  Widget build(BuildContext context) {
		return ListView(
			padding: const EdgeInsets.all(8),
			children: const [
				_ImportMangaTableCard()
			],
		);
	}
}
class _ImportMangaTableCard extends StatelessWidget {
	const _ImportMangaTableCard();

	@override
  Widget build(BuildContext context) {
		return AppCard(
			margin: const EdgeInsets.all(4),
			padding: const EdgeInsets.all(8),
			color: Theme.of(context).colorScheme.secondaryContainer,
			child: Column(
				spacing: 4,
				mainAxisSize: MainAxisSize.min,
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					const Padding(
						padding: EdgeInsets.only(left: 8),
						child: Text("Import Manga Related Tables :", textScaler: TextScaler.linear(1.3)),
					),
					Card(
						clipBehavior: Clip.antiAlias,
						child: InkWell(
							onTap: () {},
							child: Padding(
								padding: const EdgeInsets.all(10),
								child: Text(
									"Click to Import",
									style: TextStyle(
										color: Theme.of(context).colorScheme.primary
									),
								),
							),
						)
					)
				],
			),
		);
  }
}