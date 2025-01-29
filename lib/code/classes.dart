import 'dart:convert';
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
  final int? id;

  final String? ch_name, en_name, jp_name;
  final String? ch_link, en_link, jp_link;
  final String? img_link;

  final double rating;
  final int chapter_count;
  final MangaLength length;
  final bool ended;
  final List<int> tag_list;

  Manga({
    this.ch_name,
    this.ch_link,
    this.en_name,
    this.en_link,
    this.jp_name,
    this.jp_link,
    this.img_link,
    required this.id,
    required this.chapter_count,
    required this.length,
    required this.ended,
    this.rating = -1,
    this.tag_list = const [],
  });

  factory Manga.fromMap(Map<String, dynamic> map) {
    return Manga(
      ch_name: map["ch_name"],
      ch_link: map["ch_link"],
      en_name: map["en_name"],
      en_link: map["en_link"],
      jp_name: map["jp_name"],
      jp_link: map["jp_link"],
      img_link: map["img_list"],
      id: map["id"],
      chapter_count: map["chapter_count"],
      length: MangaLength.fromValue(map["length"] as int),
      ended: map["ended"] == 1,
      rating: map["rating"] ?? -1,
      tag_list: (map["tag_list"] == null)?[]:jsonDecode(map["tag_list"] as String).cast<int>()
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      "id": id,
      "chapter_count": chapter_count,
      "length": length.index,
      "ended": ended?1:0,
    };
    if (rating != -1) map["rating"] = rating;
    if (tag_list.isNotEmpty) map["tag_list"] = jsonEncode(tag_list);
    if ((img_link ?? "").isNotEmpty) map["img_link"] = img_link;
    if ((ch_name ?? "").isNotEmpty) map["ch_name"] = ch_name;
    if ((ch_link ?? "").isNotEmpty) map["ch_link"] = ch_link;
    if ((en_name ?? "").isNotEmpty) map["en_name"] = en_name;
    if ((en_link ?? "").isNotEmpty) map["en_link"] = en_link;
    if ((jp_name ?? "").isNotEmpty) map["jp_name"] = jp_name;
    if ((jp_link ?? "").isNotEmpty) map["jp_link"] = jp_link;

    return map;
  }
}
class MangaTag {
  final String name;
  final int id;
  final int color;

  MangaTag({
    required this.name,
    required this.id,
    this.color = -1
  });

  factory MangaTag.fromMap(Map<String, dynamic> map) {
    return MangaTag(
      name: map["name"] as String, 
      id: map["id"] as int,
      color: map["color"] ?? -1
    );
  } 
}