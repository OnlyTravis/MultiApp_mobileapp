import 'dart:convert';

enum SortingType {
	name(text: "Name"),
	count(text: "Count"),
	dateAdded(text: "Date"),
	dateLastRead(text: "LastRead"),
	chapterCount(text: "Chapters"),
	length(text: "Length");

	final String text;

	const SortingType({
		required this.text,
	});

	@override
	String toString() {
		return text;
	}
}
enum SortingOrder {
	asc(value: 1), 
	desc(value: -1);

	const SortingOrder({required this.value});

	final int value;

	SortingOrder inverse() {
		switch (this) {
			case SortingOrder.asc: return SortingOrder.desc;
			case SortingOrder.desc: return SortingOrder.asc;
		}
	}
}

enum MangaLength {
	short(0),
	medium(1),
	long(2),
	veryLong(3);

	const MangaLength(int value);

	factory MangaLength.fromValue(int value) {
		return MangaLength.values.firstWhere((val) => val.index == value);
	}

	int toValue() {
		return MangaLength.values.indexOf(this);
	}

	@override
	String toString() {
		switch (this) {
			case MangaLength.short: return "Short";
			case MangaLength.medium: return "Medium";
			case MangaLength.long: return "Long";
			case MangaLength.veryLong: return "Very Long";
		}
	}
}
class Manga {
	final int id;

	final String ch_name, en_name, jp_name;
	final String ch_link, en_link, jp_link;
	final String img_link;
	final String description;

	final double rating;
	final int chapter_count;
	final MangaLength length;
	final bool ended;
	final List<int> tag_list;
	final List<int> bookmark_list;

	final DateTime time_added;
	DateTime time_last_read;

	Manga({
		this.ch_name = "",
		this.ch_link = "",
		this.en_name = "",
		this.en_link = "",
		this.jp_name = "",
		this.jp_link = "",
		this.img_link = "",
		this.description = "",
		this.id = -1,
		required this.chapter_count,
		required this.length,
		required this.ended,
		this.rating = -1,
		this.tag_list = const [],
		this.bookmark_list = const [],
		DateTime? time_added,
		DateTime? time_last_read,
	}) :
		time_added = time_added ?? DateTime.now(),
		time_last_read = DateTime.fromMillisecondsSinceEpoch(0);

	factory Manga.placeHolder() {
		return Manga(id: -1, chapter_count: -1, length: MangaLength.short, ended: false);
	}
	factory Manga.fromMap(Map<String, dynamic> map) {
		String? tagList = map["tag_list"] as String?;
		String? bookmarkList = map["bookmark_list"] as String?;
		
		if (tagList != null) tagList = "[${tagList.substring(1, tagList.length-1)}]";
		if (bookmarkList != null) bookmarkList = "[${bookmarkList.substring(1, bookmarkList.length-1)}]";
		
		return Manga(
			ch_name: map["ch_name"],
			ch_link: map["ch_link"],
			en_name: map["en_name"],
			en_link: map["en_link"],
			jp_name: map["jp_name"],
			jp_link: map["jp_link"],
			img_link: map["img_link"],
			description: map["description"],
			id: map["id"],
			chapter_count: map["chapter_count"],
			length: (map["length"] is int) ? MangaLength.fromValue(map["length"] as int) : map["length"],
			ended: map["ended"] == 1,
			rating: map["rating"] ?? -1,
			tag_list: (tagList == null) ? [] : jsonDecode(tagList).cast<int>(),
			bookmark_list: (bookmarkList == null) ? [] : jsonDecode(bookmarkList).cast<int>(),
			time_added: DateTime.fromMillisecondsSinceEpoch((map["time_added"] as int) * 60000)
		);
	}
	Map<String, dynamic> toMap() {
		final Map<String, dynamic> map = {
			"id": id,
			"chapter_count": chapter_count,
			"length": length.index,
			"rating": rating,
			"ended": ended?1:0,
			"time_added": time_added.millisecondsSinceEpoch ~/ 60000,
			"time_last_read": time_added.millisecondsSinceEpoch ~/ 60000,
		};

		final tagListStr = jsonEncode(tag_list);
		final bookmarkListStr = jsonEncode(bookmark_list);
		if (tag_list.isNotEmpty) map["tag_list"] = ",${tagListStr.substring(1, tagListStr.length-1)},";
		if (bookmark_list.isNotEmpty) map["bookmark_list"] = ",${bookmarkListStr.substring(1, bookmarkListStr.length-1)},";
		if (img_link.isNotEmpty) map["img_link"] = img_link;
		if (description.isNotEmpty) map["description"] = description;
		if (ch_name.isNotEmpty) map["ch_name"] = ch_name;
		if (ch_link.isNotEmpty) map["ch_link"] = ch_link;
		if (en_name.isNotEmpty) map["en_name"] = en_name;
		if (en_link.isNotEmpty) map["en_link"] = en_link;
		if (jp_name.isNotEmpty) map["jp_name"] = jp_name;
		if (jp_link.isNotEmpty) map["jp_link"] = jp_link;

		return map;
	}

	String topName() {
		return ch_name.isNotEmpty ? ch_name : (en_name.isNotEmpty ? en_name : (jp_name.isNotEmpty ? jp_name : "null"));
	}

	static int Function(Manga, Manga) sortFunc(SortingType sortType, SortingOrder order) {
		switch (sortType) {
			case SortingType.name:
				return (Manga a, Manga b) => (order.value)*a.topName().compareTo(b.topName());
			case SortingType.dateAdded:
				return (Manga a, Manga b) => (order.value)*a.time_added.compareTo(b.time_added);
			case SortingType.dateLastRead:
				return (Manga a, Manga b) => (order.value)*a.time_last_read.compareTo(b.time_last_read);
			case SortingType.chapterCount:
				return (Manga a, Manga b) => (order.value)*(a.chapter_count - b.chapter_count);
			case SortingType.length:
				return (Manga a, Manga b) {
					int tmp = a.length.toValue() - b.length.toValue();
					if (tmp == 0) return (order.value)*(a.chapter_count - b.chapter_count);
					return (order.value)*(tmp);
				};
			default:
				return (a, b) => 0;
		}
	}

	@override
	String toString() {
		return "Manga(${toMap()})";
	}
}
class MangaTag {
	String name;
	int count;
	int id;

	MangaTag({
		required this.name,
		required this.count,
		required this.id,
	});

	factory MangaTag.fromMap(Map<String, dynamic> map) {
		return MangaTag(
			name: map["name"] as String, 
			count: map["count"] as int,
			id: map["id"] as int,
		);
	}
	Map<String, dynamic> toMap() {
		final Map<String, dynamic> map = {
			"name": name,
			"count": count,
			"id": id,
		};
		return map;
	}

	static int Function(MangaTag, MangaTag) sortFunc(SortingType sortType, SortingOrder sortOrder) {
		switch (sortType) {
			case SortingType.name: return (a, b) => sortOrder.value * a.name.compareTo(b.name);
			case SortingType.count: return (a, b) => sortOrder.value * (b.count - a.count);
			default: return (a, b) => 0;
		}
	}

	@override
  String toString() {
    return "MangaTag(name : $name, count : $count, id : $id)";
  }
}
class MangaBookmarks {
	final String name;
	final int id;
	final double chapter;
	final String link;

	const MangaBookmarks({
		required this.name,
		this.id = -1,
		required this.chapter,
		this.link = ""
	});

	factory MangaBookmarks.fromMap(Map<String, dynamic> map) {
		return MangaBookmarks(
			name: map["name"] as String,
			id: map["id"] as int,
			chapter: map["chapter"] as double,
			link: map["link"] ?? ""
		);
	}
	Map<String, dynamic> toMap() {
		final Map<String, dynamic> map = {
			"name": name,
			"id": id,
			"chapter": chapter,
		};
		if (link.isNotEmpty) map["link"] = link;

		return map;
	}
	
}