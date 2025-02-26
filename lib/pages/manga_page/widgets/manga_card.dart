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
			margin: const EdgeInsets.symmetric(vertical: 4),
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
												Flexible(
													child: Center(
														child: Text(manga.length.toString()),
													),
												),
												Row(
													spacing: 4,
													mainAxisSize: MainAxisSize.min,
													mainAxisAlignment: MainAxisAlignment.end,
													children: [
														MangaLengthBar(mangaLength: manga.length),
														(manga.rating != -1) ? 
															StarRating(value: manga.rating) :
															const SizedBox(
																width: 120,
																child: Center(
																	child: Text("No Rating"),
																),
															)
													],
												)
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
class MangaLengthBar extends StatelessWidget {
	final MangaLength mangaLength;

	const MangaLengthBar({
		super.key,
		required this.mangaLength,
	});

	static const defaultBorderRadius = BorderRadius.all(Radius.circular(8));

	@override
  Widget build(BuildContext context) {
		final value = mangaLength.toValue();
		final Color bgColor = Theme.of(context).colorScheme.surface;
		
		return Container(
			height: 16,
			decoration: BoxDecoration(
				border: Border.all(),
				borderRadius: defaultBorderRadius,
			),
			child: ClipRRect(
				borderRadius: defaultBorderRadius,
				child: Row(
					mainAxisSize: MainAxisSize.min,
					mainAxisAlignment: MainAxisAlignment.start,
					children: [
						Container(
							width: 16,
							color: Colors.red,
						),
						const VerticalDivider(width: 1),
						Container(
							width: 16,
							color: (value > 0) ? Colors.orange : bgColor,
						),
						const VerticalDivider(width: 1),
						Container(
							width: 16,
							color: (value > 1) ? Colors.yellow : bgColor,
						),
						const VerticalDivider(width: 1),
						Container(
							width: 16,
							color: (value > 2) ? Colors.lightGreen : bgColor,
						),
					],
				),
			),
		);
  }
}