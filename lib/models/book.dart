import 'dart:convert';

class Book {
  final String img;
  final String id;
  final String title;
  final String authName;
  final List<String> genre;
  final double price;
  final int pageNum;
  final String description;

  Book({
    required this.img,
    required this.id,
    required this.title,
    required this.authName,
    required this.genre,
    required this.price,
    required this.pageNum,
    required this.description,
  });
  
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id'],
      img: json['img'],
      title: json['title'],
      authName: json['authName'],
      genre: List<String>.from(json['genre']),
      price: json['price'].toDouble(),
      pageNum: json['pageNum'],
      description: json['description'],
    );
  }
}
