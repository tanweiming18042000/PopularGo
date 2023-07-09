import 'dart:convert';

class Wishlist {
  final String user_id;
  final String id;
  final String book_id;
  late final int quantity;
  final double price;

  Wishlist({
    required this.user_id,
    required this.id,
    required this.book_id,
    required this.quantity,
    required this.price,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'id': id,
      'book_id': book_id,
      'quantity': quantity,
      'price': price,
    };
  }

  factory Wishlist.fromJson(Map<String, dynamic> json) {
    return Wishlist(
      id: json['_id'],
      user_id: json['user_id'],
      book_id: json['book_id'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
    );
  }
}
