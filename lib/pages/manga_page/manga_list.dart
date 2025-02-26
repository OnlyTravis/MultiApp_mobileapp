import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_app/code/classes.dart';
import 'package:multi_app/code/database_handler.dart';
import 'package:multi_app/pages/manga_page/add_manga.dart';
import 'package:multi_app/pages/manga_page/view_manga.dart';
import 'package:multi_app/pages/manga_page/widgets/manga_card.dart';
import 'package:multi_app/widgets/app_card.dart';
import 'package:multi_app/widgets/expandable_listtile.dart';
import 'package:multi_app/widgets/pop_up_menu.dart';
import 'package:multi_app/widgets/star_rating.dart';

class MangaListPage extends StatefulWidget {
	const MangaListPage({super.key});

	@override
	State<MangaListPage> createState() => _MangaPageListState();
}
class _MangaPageListState extends State<MangaListPage> {
	late StreamSubscription _streamSubscription;
	List<Manga> _allMangaList = [];
	List<Manga> _mangaList = [];
	final List<SortingType> _allowedSortingtypes = [
		SortingType.name,
		SortingType.chapterCount,
		SortingType.length,
		SortingType.dateAdded,
		SortingType.dateLastRead,
	];
	SortingType _sortType = SortingType.name;
	SortingOrder _sortOrder = SortingOrder.asc;

	void _onViewManga(Manga manga) {
		Navigator.of(context).push(
			MaterialPageRoute(
				builder: (context) => ViewMangaPage(
					manga: manga,
				)
			)
		);
	}
	void _onChangeSortingOrder(SortingOrder newSortOrder) {
		_sortOrder = newSortOrder;
		_sortMangaList();
	}
	void _onChangeSortingType(SortingType newSortType) {
		_sortType = newSortType;
		_sortMangaList();
	}
	void _onChangeFilter(_MangaFilter filter) {
		// 1. Filter allMangaList
		_mangaList = [];
		for (final Manga manga in _allMangaList) {
			if (filter.enabledFilters[0]) {
				if (manga.rating < filter.ratingRange.start || manga.rating > filter.ratingRange.end) continue;
			}
			if (filter.enabledFilters[1]) {
				final int value = manga.length.toValue();
				if (value < filter.lengthRange.start || value > filter.lengthRange.end) continue;
			}
			if (filter.enabledFilters[2]) {
				if (filter.chapterIsLarger) {
					if (manga.chapter_count < filter.chapterCount) continue;
				} else {
					if (manga.chapter_count > filter.chapterCount) continue;
				}
			}

			_mangaList.add(manga);
		}

		// 2. Sort mangaList
		_sortMangaList();
	}

	Future<void> _updateMangaList() async {
		final db = DatabaseHandler();
		_allMangaList = await db.getAllManga();
		_mangaList = _allMangaList;
		_sortMangaList();
	}
	void _sortMangaList() {
		setState(() {
			_mangaList.sort(Manga.sortFunc(_sortType, _sortOrder));
			_sortType = _sortType;
			_sortOrder = _sortOrder;
		});
	}

	@override 
	void initState() {
		_updateMangaList();

		final db = DatabaseHandler();
		if (db.streams[DatabaseTables.mangas] != null) {
			_streamSubscription = db.streams[DatabaseTables.mangas]!.listen((_) {
				_updateMangaList();
			});
		}

		super.initState();
	}
	
	@override 
	void dispose() {
		_streamSubscription.cancel();
		super.dispose();
	}

	@override 
	Widget build(BuildContext context) {
		return Column(
			mainAxisSize: MainAxisSize.min,
			children: [
				_MangaListToolBar(
					allowedSortingTypes: _allowedSortingtypes,
					sortOrder: _sortOrder,
					sortType: _sortType,
					onChangeSortOrder: _onChangeSortingOrder,
					onChangeSortType: _onChangeSortingType,
					onApplyFilter: _onChangeFilter,
				),
				Flexible(
					child: Container(
						color: Theme.of(context).colorScheme.primaryContainer,
						child: Container(
							padding: const EdgeInsets.only(top: 8),
							decoration: BoxDecoration(
								borderRadius: BorderRadius.vertical(
									top: Radius.elliptical(MediaQuery.sizeOf(context).width, 30),
								),
								color: Theme.of(context).colorScheme.surface,
							),
							child: ListView(
								padding: const EdgeInsets.all(12),
								children: [
									..._mangaList.asMap().entries.map((entry) => MangaCard(
										index: entry.key,
										manga: entry.value,
										onTap: _onViewManga,
									))
								],
							),
						),
					),
				),
			],
		);
	}
}

class _MangaListToolBar extends StatelessWidget {
	final List<SortingType> allowedSortingTypes;
	final SortingType sortType;
	final SortingOrder sortOrder;
	final Function(SortingType) onChangeSortType;
	final Function(SortingOrder) onChangeSortOrder;
	final Function(_MangaFilter) onApplyFilter;

	const _MangaListToolBar({
		required this.allowedSortingTypes,
		required this.sortType,
		required this.sortOrder,
		required this.onChangeSortType,
		required this.onChangeSortOrder,
		required this.onApplyFilter,
	});

	Future<void> _onTapFilter(BuildContext context) async {
		await showDialog(
			context: context,
			builder: (BuildContext context) => _MangaFilterDialog(
				onSubmit: (_MangaFilter filter) {
					onApplyFilter(filter);
				},
			),
		);
	}

	@override
  Widget build(BuildContext context) {
		assert (allowedSortingTypes.contains(sortType));

    return Container(
			color: Theme.of(context).colorScheme.primaryContainer,
			height: 40,
			child: Row(
				mainAxisAlignment: MainAxisAlignment.end,
				children: [
					IconButton(
						onPressed: () => _onTapFilter(context), 
						icon: Row(
							mainAxisSize: MainAxisSize.min,
							children: [
								Icon(
									Icons.filter_alt,
									color: Theme.of(context).colorScheme.primary,
								),
								Text(
									"Filter",
									style: TextStyle(
										color: Theme.of(context).colorScheme.primary,
									),
								),
							],
						),
					),
					const VerticalDivider(width: 0, indent: 8, endIndent: 8),
					PopUpSelectMenu(
						onChanged: (int index) => onChangeSortType(allowedSortingTypes[index]),
						leadingIcon: const Icon(Icons.sort),
						selectedIndex: allowedSortingTypes.indexOf(sortType), 
						menuItems: allowedSortingTypes.map((sortType) => sortType.toString()).toList(),
					),
					const VerticalDivider(width: 0, indent: 8, endIndent: 8),
					IconButton(
						onPressed: () => onChangeSortOrder(sortOrder.inverse()),
						icon: Icon(
							(sortOrder == SortingOrder.asc) ? Icons.arrow_upward : Icons.arrow_downward, 
							size: 20,
							color: Theme.of(context).colorScheme.primary,
						),
					),
					const VerticalDivider(width: 0, indent: 8, endIndent: 8),
					IconButton(
						padding: EdgeInsets.zero,
						onPressed: () {
							Navigator.of(context).push(
								MaterialPageRoute(
									builder: (context) => const AddMangaPage()
								)
							);
						},
						icon: Icon(Icons.add, size: 20, color: Theme.of(context).colorScheme.primary),
					),
				],
			),
		);
  }
}
class _MangaFilter {
	final List<bool> enabledFilters;
	final RangeValues ratingRange;
	final RangeValues lengthRange;
	final bool chapterIsLarger;
	final int chapterCount;

	const _MangaFilter({
		required this.enabledFilters,
		required this.ratingRange,
		required this.lengthRange,
		required this.chapterIsLarger,
		required this.chapterCount,
	});
}
class _MangaFilterDialog extends StatefulWidget {
	final Function(_MangaFilter) onSubmit;

	const _MangaFilterDialog({
		required this.onSubmit
	});

	@override
  State<_MangaFilterDialog> createState() => _MangaFilterDialogState();
}
class _MangaFilterDialogState extends State<_MangaFilterDialog> {
	final List<bool> _toggledFilters = [false, false, false];

	RangeValues _ratingRange = const RangeValues(0, 5);
	RangeValues _lengthRange = RangeValues(0, (MangaLength.values.length-1).toDouble());
	bool _chapterIsLarger = true;
	int _chapterCount = 0;

	void _onSubmit() {
		widget.onSubmit(
			_MangaFilter(
				enabledFilters: _toggledFilters,
				ratingRange: _ratingRange,
				lengthRange: _lengthRange,
				chapterIsLarger: _chapterIsLarger,
				chapterCount: _chapterCount,
			)
		);
		Navigator.pop(context);
	}
	void _onToggleFilter(int index, bool value) {
		_toggledFilters[index] = value;
	}

	@override
  Widget build(BuildContext context) {
		return AlertDialog(
			title: const Text("Select Filter"),
			content: AppCardSplash(
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: [
						_RangeFilter(
							onToggle: (bool value) => _onToggleFilter(0, value),
							onChangeEnd: (newRange) {
								_ratingRange = newRange;
							},
						),
						const Divider(height: 0),
						_LengthFilter(
							onToggle: (bool value) => _onToggleFilter(1, value),
							onChangeEnd: (newRange) {
								_lengthRange = newRange;
							},
						),
						const Divider(height: 0),
						_ChapterFilter(
							onToggle: (bool value) => _onToggleFilter(2, value),
							onChange: (bool isLarger, int chapterCount) {
								_chapterIsLarger = isLarger;
								_chapterCount = chapterCount;
							}
						),
					],
				),
			),
			actions: [
				TextButton(
					onPressed: _onSubmit,
					child: const Text('Confirm'),
				),
				TextButton(
					onPressed: () {
						Navigator.pop(context);
					},
					child: const Text('Cancel'),
				),
			],
		);
  }
}
class _RangeFilter extends StatefulWidget {
	final Function(bool) onToggle;
	final Function(RangeValues) onChangeEnd;
	
	const _RangeFilter({
		required this.onToggle,
		required this.onChangeEnd,
	});

	@override
  State<_RangeFilter> createState() => _RangeFilterState();
}
class _RangeFilterState extends State<_RangeFilter> {
	RangeValues ratingRange = const RangeValues(0, 5);

	@override
  Widget build(BuildContext context) {
		return ExpandableListTile(
			onToggle: (bool value) => widget.onToggle(value),
			title: const Text("Rating Filter"),
			trailingStyle: ExpandableListTileTrailing.toggledSwitch,
			child: Column(
				mainAxisSize: MainAxisSize.min,
				children: [
					Row(
						mainAxisSize: MainAxisSize.min,
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							StarRating(value: ratingRange.start),
							const Text(" - "),
							StarRating(value: ratingRange.end),
						],
					),
					Padding(
						padding: const EdgeInsets.symmetric(horizontal: 8),
						child: Row(
							mainAxisAlignment: MainAxisAlignment.spaceBetween,
							children: [
								Text(ratingRange.start.toStringAsFixed(2)),
								Text(ratingRange.end.toStringAsFixed(2))
							],
						),
					),
					RangeSlider(
						min: 0,
						max: 5,
						values: ratingRange,
						onChanged: (RangeValues newRange) {
							setState(() {
								ratingRange = newRange;
							});
						},
						onChangeEnd: (_) {
							widget.onChangeEnd(ratingRange);
						},
					),
				],
			),
		);
	}
}
class _LengthFilter extends StatefulWidget {
	final Function(bool) onToggle;
	final Function(RangeValues) onChangeEnd;
	
	const _LengthFilter({
		required this.onToggle,
		required this.onChangeEnd,
	});

	@override
  State<_LengthFilter> createState() => _LengthFilterState();
}
class _LengthFilterState extends State<_LengthFilter> {
	final int maxValue = MangaLength.values.length - 1;
	RangeValues _lengthRange = RangeValues(0, (MangaLength.values.length - 1).toDouble());

	@override
  Widget build(BuildContext context) {
		return ExpandableListTile(
			onToggle: widget.onToggle,
			title: const Text("Length Filter"),
			trailingStyle: ExpandableListTileTrailing.toggledSwitch,
			child: Column(
				mainAxisSize: MainAxisSize.min,
				children: [
					Row(
						mainAxisSize: MainAxisSize.min,
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Text(MangaLength.fromValue(_lengthRange.start.round()).toString()),
							const Text(" - "),
							Text(MangaLength.fromValue(_lengthRange.end.round()).toString())
						],
					),
					RangeSlider(
						min: 0,
						max: maxValue.toDouble(),
						divisions: maxValue,
						labels: RangeLabels(
							MangaLength.fromValue(_lengthRange.start.round()).toString(), 
							MangaLength.fromValue(_lengthRange.end.round()).toString(),
						),
						values: _lengthRange,
						onChanged: (RangeValues newRange) {
							setState(() {
								_lengthRange = newRange;
							});
						},
						onChangeEnd: (_) {
							widget.onChangeEnd(
								RangeValues(_lengthRange.start.roundToDouble(), _lengthRange.end.roundToDouble())
							);
						},
					),
				],
			),
		);
  }
}
class _ChapterFilter extends StatefulWidget {
	final Function(bool) onToggle;
	final Function(bool, int) onChange;
	
	const _ChapterFilter({
		required this.onToggle,
		required this.onChange,
	});

	@override
  State<_ChapterFilter> createState() => _ChapterFilterState();
}
class _ChapterFilterState extends State<_ChapterFilter> {
	bool _isLarger = true;
	final TextEditingController _chapterCountController = TextEditingController();

	@override
  Widget build(BuildContext context) {
		return ExpandableListTile(
			onToggle: widget.onToggle,
			trailingStyle: ExpandableListTileTrailing.toggledSwitch,
			title: const Text("Chapter Filter"),
			child: Row(
				mainAxisSize: MainAxisSize.min,
				spacing: 12,
				children: [
					IconButton(
						onPressed: () {
							setState(() {
							  _isLarger = !_isLarger;
							});
							widget.onChange(_isLarger, int.tryParse(_chapterCountController.text) ?? 0);
						},
						icon: _isLarger ? const Text(">=") : const Text("<="),
					),
					SizedBox(
						width: 128,
						child: TextField(
							keyboardType: const TextInputType.numberWithOptions(decimal: false),
							inputFormatters: [
								FilteringTextInputFormatter.digitsOnly,
							],
							decoration: const InputDecoration(
								border: OutlineInputBorder(),
							),
							onChanged: (_) {
								widget.onChange(_isLarger, int.tryParse(_chapterCountController.text) ?? 0);
							},
							controller: _chapterCountController,
						),
					),
				],
			),
		);
	}
}