class ReUserClickedBooks {
  final String id;
  final String userId;
  final List<List<String>> genreList;
  final List<String> clicked_datetime;

  ReUserClickedBooks({
    required this.id,
    required this.userId,
    required this.genreList,
    required this.clicked_datetime,
  });

  factory ReUserClickedBooks.fromJson(Map<String, dynamic> json) {
    return ReUserClickedBooks(
      id: json['_id'],
      userId: json['user_id'],
      genreList: List<List<String>>.from(
        json['genreList'].map<List<String>>(
          (genre) => List<String>.from(genre.map((item) => item.toString())),
        ),
      ),
      clicked_datetime: List<String>.from(json['clicked_datetime']),
    );
  }
}