import 'dart:convert';

class UserBalance {
  final String user_id;
  final String id;
  final double totalBalance;

  UserBalance({
    required this.user_id,
    required this.id,
    required this.totalBalance,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'id': id,
      'totalBalance': totalBalance,
    };
  }

  factory UserBalance.fromJson(Map<String, dynamic> json) {
    return UserBalance(
      id: json['_id'],
      user_id: json['user_id'],
      totalBalance: json['totalBalance'].toDouble(),
    );
  }
}
