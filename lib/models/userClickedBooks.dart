class UserClickedBooks {
  final String user_id;
  final String id;
  final List<String> genreList;
  final List<String> clicked_datetime;

  UserClickedBooks({
    required this.user_id,
    required this.id,
    required this.genreList,
    required this.clicked_datetime,
  });

  factory UserClickedBooks.fromJson(Map<String, dynamic> json) {
    return UserClickedBooks(
      user_id: json['user_id'],
      id: json['_id'],
      genreList: List<String>.from(json['genreList']),
      clicked_datetime: List<String>.from(json['clicked_datetime']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'id': id,
      'genreList': genreList,
      'clicked_datetime': clicked_datetime,
    };
  }
}