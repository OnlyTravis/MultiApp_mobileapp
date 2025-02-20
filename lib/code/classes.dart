import 'dart:convert';

enum SortingType {
	name,
	dateAdded,
	dateLastRead;
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

	final double rating;
	final int chapter_count;
	final MangaLength length;
	final bool ended;
	final List<int> tag_list;

	final DateTime time_added;
	final DateTime time_last_read;

	Manga({
		this.ch_name = "",
		this.ch_link = "",
		this.en_name = "",
		this.en_link = "",
		this.jp_name = "",
		this.jp_link = "",
		this.img_link = "",
		this.id = -1,
		required this.chapter_count,
		required this.length,
		required this.ended,
		this.rating = -1,
		this.tag_list = const [],
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
		if (tagList != null) {
			tagList = "[${tagList.substring(1, tagList.length-1)}]";
		}
		return Manga(
			ch_name: map["ch_name"] ?? "",
			ch_link: map["ch_link"] ?? "",
			en_name: map["en_name"] ?? "",
			en_link: map["en_link"] ?? "",
			jp_name: map["jp_name"] ?? "",
			jp_link: map["jp_link"] ?? "",
			img_link: map["img_link"] ?? "",
			id: map["id"],
			chapter_count: map["chapter_count"],
			length: (map["length"] is int) ? MangaLength.fromValue(map["length"] as int) : map["length"],
			ended: map["ended"] == 1,
			rating: map["rating"] ?? -1,
			tag_list: (tagList == null) ? [] : jsonDecode(tagList).cast<int>(),
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

		final tagArrStr = jsonEncode(tag_list);
		if (tag_list.isNotEmpty) map["tag_list"] = ",${tagArrStr.substring(1, tagArrStr.length-1)},";
		if (img_link.isNotEmpty) map["img_link"] = img_link;
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

	@override
  String toString() {
    return "MangaTag(name : $name, count : $count, id : $id)";
  }
}