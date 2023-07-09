import 'dart:convert';

class Discount {
  final String img;
  final String id;
  final String title;
  final String subtitle;
  final List<String> genre;
  final double maxPrice;
  final String mustOverMaxPrice;
  final double discountPercent;

  Discount({
    required this.img,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.genre,
    required this.maxPrice,
    required this.mustOverMaxPrice,
    required this.discountPercent,
  });

  Map<String, dynamic> toJson() {
    return {
      'img': img,
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'genre': genre,
      'maxPrice': maxPrice,
      'mustOverMaxPrice': mustOverMaxPrice,
      'discountPercent': discountPercent,
    };
  }

factory Discount.fromJson(Map<String, dynamic> json) {
  return Discount(
    id: json['_id'] as String,
    img: json['img'] as String,
    title: json['title'] as String,
    subtitle: json['subtitle'] as String,
    genre: (json['genre'] as List<dynamic>?)?.cast<String>() ?? [],
    maxPrice: (json['maxPrice'] as num).toDouble(),
    mustOverMaxPrice: json['mustOverMaxPrice'] as String,
    discountPercent: (json['discountPercent'] as num).toDouble(),
    // Add handling for other nullable fields if applicable
  );
}
}
