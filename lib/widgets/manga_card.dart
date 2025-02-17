import 'package:flutter/material.dart';
import 'package:multi_app/code/classes.dart';
import 'package:multi_app/widgets/app_card.dart';
import 'package:multi_app/widgets/star_rating.dart';

class MangaCard extends StatelessWidget {
	final Manga manga;
	final int? index;
	final void Function(Manga)? onTap;

	const MangaCard({super.key, required this.manga, this.index, this.onTap});

	@override
	Widget build(BuildContext context) {
		return AppCardSplash(
			child: InkWell(
				onTap: (onTap == null) ? null : () => onTap!(manga),
				child: Row(
					children: [
						manga.img_link.isEmpty ? Ink(
							width: 96,
							height: 128,
							color: Theme.of(context).colorScheme.surfaceDim,
							child: const Center(
								child: Text("Image Not Available", textAlign: TextAlign.center),
							)
						) : Ink.image(
							width: 96,
							height: 128,
							fit: BoxFit.fill,
							image: NetworkImage(manga.img_link),
						),
						Flexible(
							child: Container(
								height: 128,
								padding: const EdgeInsets.all(8),
								child: Column(
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text((index == null) ? manga.topName() : "${index!+1}. ${manga.topName()}"),
										Row(
											mainAxisSize: MainAxisSize.max,
											mainAxisAlignment: MainAxisAlignment.spaceBetween,
											children: [
												Text("Chapters : ${manga.chapter_count}"),
												(manga.rating != -1) ? 
													StarRating(value: manga.rating) :
													const Text("No Rating")
											],
										)
									],
								),
							),
						)
					],
				),
			),
		);
	}
}