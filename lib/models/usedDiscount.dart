import 'dart:convert';

class UsedDiscount {
  final String user_id;
  final String id;
  final String discount_id;

  UsedDiscount({
    required this.user_id,
    required this.id,
    required this.discount_id,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'id': id,
      'discount_id': discount_id, 
    };
  }

  factory UsedDiscount.fromJson(Map<String, dynamic> json) {
    return UsedDiscount(
      id: json['_id'],
      user_id: json['user_id'],
      discount_id: json['discount_id'],
    );
  }
}