import 'dart:convert';

class TransactionHistory {
  final String user_id;
  final String id;
  final String transaction_datetime;
  final double amount;
  final String transactionType;

  TransactionHistory({
    required this.user_id,
    required this.id,
    required this.transaction_datetime,
    required this.amount,
    required this.transactionType,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'id': id,
      'transaction_datetime': transaction_datetime,
      'amount': amount,
      'transactionType': transactionType,
    };
  }

  factory TransactionHistory.fromJson(Map<String, dynamic> json) {
    return TransactionHistory(
      id: json['_id'] as String,
      user_id: json['user_id'] as String,
      transaction_datetime: json['transaction_datetime'] as String,
      amount: (json['amount'] as num).toDouble(),
      transactionType: json['transactionType'] as String,
    );
  }
}

  // return Discount(
  //   id: json['_id'] as String,
  //   img: json['img'] as String,
  //   title: json['title'] as String,
  //   subtitle: json['subtitle'] as String,
  //   genre: (json['genre'] as List<dynamic>?)?.cast<String>() ?? [],
  //   maxPrice: (json['maxPrice'] as num).toDouble(),
  //   mustOverMaxPrice: json['mustOverMaxPrice'] as String,
  //   discountPercent: (json['discountPercent'] as num).toDouble(),
  //   // Add handling for other nullable fields if applicable
  // );