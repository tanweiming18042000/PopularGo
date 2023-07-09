import 'dart:convert';

class Payment {
  final String userVisit_id;
  final String id;
  final List<String> bookIdList;
  final List<int> quantityList;
  final List<double> priceList;
  final double subtotal;
  final double estimatedTax;
  final double total;
  final String status;

  Payment({
    required this.userVisit_id,
    required this.id,
    required this.bookIdList,
    required this.quantityList,
    required this.priceList,
    required this.subtotal,
    required this.estimatedTax,
    required this.total,
    required this.status,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      userVisit_id: json['userVisit_id'],
      id: json['_id'],
      bookIdList: List<String>.from(json['bookIdList']),
      quantityList: List<int>.from(json['quantityList']),
      priceList: List<double>.from(json['priceList']),
      subtotal: json['subtotal'].toDouble(),
      estimatedTax: json['estimatedTax'].toDouble(),
      total: json['total'].toDouble(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userVisit_id': userVisit_id,
      'id': id,
      'bookIdList': bookIdList,
      'quantityList': quantityList,
      'priceList': priceList,
      'subtotal': subtotal,
      'estimatedTax': estimatedTax,
      'total': total,
      'status': status,
    };
  }
}
