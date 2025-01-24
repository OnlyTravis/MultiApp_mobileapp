import 'dart:convert';

class Manga {
  final String? ch_name, en_name, jp_name;
  final String? ch_link, en_link, jp_link;
  final String? img_link;
  final int id;
  final double rating;
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
      rating: map["rating"] ?? -1,
      tag_list: (map["tagList"] == null)?[]:jsonDecode(map["tag_list"] as String).cast<int>()
    );
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