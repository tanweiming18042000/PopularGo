import 'dart:convert';

class UserVisit {
  final String user_id;
  final String id;
  final String start_datetime;
  final String end_datetime;
  final int duration;

  UserVisit({
    required this.user_id,
    required this.id,
    required this.start_datetime,
    required this.end_datetime,
    required this.duration,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'id': id,
      'start_datetime': start_datetime,
      'end_datetime': end_datetime,
      'duration': duration,
    };
  }

  factory UserVisit.fromJson(Map<String, dynamic> json) {
    return UserVisit(
      id: json['_id'],
      user_id: json['user_id'],
      start_datetime: json['start_datetime'],
      end_datetime: json['end_datetime'],
      duration: json['duration'],
    );
  }
}