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
		// 1. Check if all filters disabled
		if (!filter.enabledFilters.contains(true)) {
			_mangaList = _allMangaList;
			_sortMangaList();
		}

		// 2. Filter allMangaList -> mangaList
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

		// 3. Sort mangaList
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

class _MangaListToolBar extends StatefulWidget {
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

	@override
  State<_MangaListToolBar> createState() => _MangaListToolBarState();
}
class _MangaListToolBarState extends State<_MangaListToolBar> {
	bool _filterActive = false;

	Future<void> _onTapFilter(BuildContext context) async {
		if (_filterActive) {
			setState(() {
			  _filterActive = false;
			});
			widget.onApplyFilter(_MangaFilter.empty());
			return;
		}

		await showDialog(
			context: context,
			builder: (BuildContext context) => _MangaFilterDialog(
				onSubmit: (_MangaFilter filter) {
					setState(() {
					  _filterActive = filter.enabledFilters.contains(true);
					});
					widget.onApplyFilter(filter);
				},
			),
		);
	}

	@override
	void initState() {
		assert (widget.allowedSortingTypes.contains(widget.sortType));
		super.initState();
	}

	@override
  Widget build(BuildContext context) {
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
									_filterActive ? Icons.filter_alt_off : Icons.filter_alt,
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
						onChanged: (int index) => widget.onChangeSortType(widget.allowedSortingTypes[index]),
						leadingIcon: const Icon(Icons.sort),
						selectedIndex: widget.allowedSortingTypes.indexOf(widget.sortType), 
						menuItems: widget.allowedSortingTypes.map((sortType) => sortType.toString()).toList(),
					),
					const VerticalDivider(width: 0, indent: 8, endIndent: 8),
					IconButton(
						onPressed: () => widget.onChangeSortOrder(widget.sortOrder.inverse()),
						icon: Icon(
							(widget.sortOrder == SortingOrder.asc) ? Icons.arrow_upward : Icons.arrow_downward, 
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

	factory _MangaFilter.empty() {
		return const _MangaFilter(
			enabledFilters: [false, false, false], 
			ratingRange: RangeValues(0, 5),
			lengthRange: RangeValues(0, 3), 
			chapterIsLarger: true, 
			chapterCount: 0
		);
	}
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
				width: double.infinity,
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: [
						_RatingFilter(
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
class _RatingFilter extends StatefulWidget {
	final Function(bool) onToggle;
	final Function(RangeValues) onChangeEnd;
	
	const _RatingFilter({
		required this.onToggle,
		required this.onChangeEnd,
	});

	@override
  State<_RatingFilter> createState() => _RatingFilterState();
}
class _RatingFilterState extends State<_RatingFilter> {
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
					Padding(
						padding: const EdgeInsets.symmetric(horizontal: 8),
						child: Row(
							mainAxisSize: MainAxisSize.min,
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								Column(
									mainAxisSize: MainAxisSize.min,
									children: [
										StarRating(value: ratingRange.start),
										Text(ratingRange.start.toStringAsFixed(1)),
									],
								),
								const Text(" - "),
								Column(
									mainAxisSize: MainAxisSize.min,
									children: [
										StarRating(value: ratingRange.end),
										Text(ratingRange.end.toStringAsFixed(1)),
									],
								),
							],
						),
					),
					RangeSlider(
						min: 0,
						max: 5,
						labels: RangeLabels(
							ratingRange.start.toStringAsFixed(1), 
							ratingRange.end.toStringAsFixed(1),
						),
						values: ratingRange,
						onChanged: (RangeValues newRange) {
							setState(() {
								ratingRange = newRange;
							});
						},
						onChangeEnd: (_) {
							widget.onChangeEnd(
								RangeValues(
									(ratingRange.start*10).floorToDouble()/10,
									(ratingRange.end*10).floorToDouble()/10
								)
							);
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
	MangaLength _startLength = MangaLength.short;
	MangaLength _endLength = MangaLength.veryLong;

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
						spacing: 16,
						mainAxisSize: MainAxisSize.min,
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Column(
								mainAxisSize: MainAxisSize.min,
								children: [
									MangaLengthBar(mangaLength: _startLength),
									Text(_startLength.toString()),
								],
							),
							const Text("-"),
							Column(
								mainAxisSize: MainAxisSize.min,
								children: [
									MangaLengthBar(mangaLength: _endLength),
									Text(_endLength.toString()),
								],
							),
						],
					),
					RangeSlider(
						min: 0,
						max: maxValue.toDouble(),
						divisions: maxValue,
						labels: RangeLabels(
							_startLength.toString(), 
							_endLength.toString(),
						),
						values: _lengthRange,
						onChanged: (RangeValues newRange) {
							setState(() {
								_lengthRange = newRange;
								_startLength = MangaLength.fromValue(_lengthRange.start.round());
								_endLength = MangaLength.fromValue(_lengthRange.end.round());
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
	final TextEditingController _chapterCountController = TextEditingController(text: "0");

	@override
  Widget build(BuildContext context) {
		return ExpandableListTile(
			onToggle: widget.onToggle,
			trailingStyle: ExpandableListTileTrailing.toggledSwitch,
			title: const Text("Chapter Filter"),
			child: Row(
				mainAxisSize: MainAxisSize.min,
				crossAxisAlignment: CrossAxisAlignment.start,
				spacing: 32,
				children: [
					IconButton(
						onPressed: () {
							setState(() {
							  _isLarger = !_isLarger;
							});
							widget.onChange(_isLarger, int.tryParse(_chapterCountController.text) ?? 0);
						},
						style: ButtonStyle(
							backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.primaryContainer)
						),
						icon: _isLarger ? const Text(">=") : const Text("<="),
					),
					SizedBox(
						width: 80,
						height: 40,
						child: TextField(
							keyboardType: const TextInputType.numberWithOptions(decimal: false),
							inputFormatters: [
								FilteringTextInputFormatter.digitsOnly,
							],
							decoration: const InputDecoration(
								border: UnderlineInputBorder(),
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