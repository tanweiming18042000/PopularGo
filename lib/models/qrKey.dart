import 'dart:convert';

class QRKey {
  final String user_id;
  final String id;
  final String qrStr;

  QRKey({
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

  factory QRKey.fromJson(Map<String, dynamic> json) {
    return QRKey(
      id: json['_id'],
      user_id: json['user_id'],
      qrStr: json['qrStr'],
    );
  }
}