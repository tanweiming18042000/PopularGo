import 'dart:convert';

class PaymentQRKey {
  final String user_id;
  final String id;
  final String qrStr;

  PaymentQRKey({
    required this.user_id,
    required this.id,
    required this.qrStr,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'id': id,
      'qrStr': qrStr,
    };
  }

  factory PaymentQRKey.fromJson(Map<String, dynamic> json) {
    return PaymentQRKey(
      id: json['_id'],
      user_id: json['user_id'],
      qrStr: json['qrStr'],
    );
  }
}