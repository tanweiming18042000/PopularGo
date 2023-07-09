import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../constants/global_variables.dart';
import '../../../constants/size_config.dart';
import '../../../models/book.dart';
import '../../../models/reUserClickedBooks.dart';
import '../../../providers/user_provider.dart';
import '../../auth/services/auth_service.dart';
import 'book_details.dart';

class RecommendationPage extends StatefulWidget {
  static const String routeName = '/recommendationPage';
  const RecommendationPage({super.key});

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  final AuthService authService = AuthService();
  late Future<ReUserClickedBooks> userClickedBooksFuture;

  @override
  void initState() {
    super.initState();
    userClickedBooksFuture = getUserClickedBooks();
  }

  Future<ReUserClickedBooks> getUserClickedBooks() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user_id = Provider.of<UserProvider>(context, listen: false).user.id;
    final authService = AuthService();

    try {
      final userClickedBooks = await authService.getUserClickedBooks(
        context: context,
        user_id: user_id,
      );

      return userClickedBooks;
    } catch (e) {
      throw Exception('Failed to get user clicked books: $e');
    }
  }

  Future<List<Book>> retrieveRecommendBookList(List<String> genreList) async {
    return await authService.retrieveRecommendBookList(
        context: context, genreList: genreList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Recommendation'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            // Trigger the refresh logic here
            userClickedBooksFuture = getUserClickedBooks();
          });
        },
        child: FutureBuilder<ReUserClickedBooks>(
          future: userClickedBooksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (snapshot.hasData && snapshot.data!.genreList.isNotEmpty) {
              final userClickedBooks = snapshot.data!;
              final genreList = userClickedBooks.genreList;
              final clickedDatetime = userClickedBooks.clicked_datetime;

              // Calculate genre weights
              final genreWeights =
                  calculateGenreWeights(genreList, clickedDatetime);

              // Sort genres by weight in ascending order
              final sortedGenres = genreWeights.entries.toList()
                ..sort((a, b) => a.value.compareTo(b.value));

              // Calculate the mean weight
              final meanWeight = genreWeights.values.reduce((a, b) => a + b) /
                  genreWeights.length;

              // Filter genres with weight below the mean
              final belowMeanGenres =
                  sortedGenres.where((entry) => entry.value < meanWeight);

              // Retrieve book lists for each genre
              final bookListFutures = belowMeanGenres.map(
                  (genreEntry) => retrieveRecommendBookList([genreEntry.key]));

              return FutureBuilder<List<List<Book>>>(
                future: Future.wait(bookListFutures),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (snapshot.hasData) {
                    final bookLists = snapshot.data!;
                    final displayedBooks = <Book>[];

                    for (final bookList in bookLists) {
                      displayedBooks.addAll(bookList.take(6));
                      if (displayedBooks.length >= 6) {
                        break;
                      }
                    }

                    return SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            getProportionateScreenWidth(15),
                            getProportionateScreenHeight(20),
                            getProportionateScreenWidth(15),
                            getProportionateScreenHeight(20)),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            // the distance between rows
                            mainAxisSpacing: getProportionateScreenHeight(30),
                            // the distance between columns
                            crossAxisSpacing: getProportionateScreenWidth(10),
                            mainAxisExtent: getProportionateScreenHeight(375),
                          ),
                          itemCount: displayedBooks.length,
                          itemBuilder: (context, index) {
                            final book = displayedBooks[index];
                            return GestureDetector(
                              onTap: () {
                                // Handle book tap
                                Navigator.pushNamed(
                                    context, BookDetails.routeName,
                                    arguments: book);
                              },
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(bottom: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        // Book cover image URL
                                        '$uri\\${book.img}',
                                        width: getProportionateScreenWidth(150),
                                        height:
                                            getProportionateScreenHeight(240),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: getProportionateScreenWidth(150),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height:
                                              getProportionateScreenHeight(40),
                                          child: Text(
                                            book.title,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize:
                                                  getProportionateScreenHeight(
                                                      18),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            height:
                                                getProportionateScreenHeight(
                                                    10)),
                                        Text(
                                          book.authName,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize:
                                                getProportionateScreenHeight(
                                                    14),
                                          ),
                                        ),
                                        SizedBox(
                                            height:
                                                getProportionateScreenHeight(
                                                    20)),
                                        Container(
                                          padding: EdgeInsets.all(6.0),
                                          decoration: BoxDecoration(
                                            color:
                                                GlobalVariables.secondaryColor,
                                          ),
                                          child: Text(
                                            'RM ${book.price.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize:
                                                  getProportionateScreenHeight(
                                                      16),
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  } else {
                    return Center(
                      child: Text('No books available'),
                    );
                  }
                },
              );
            } else {
              return Center(
                child: Text('No recommendation'),
              );
            }
          },
        ),
      ),
    );
  }

  Map<String, double> calculateGenreWeights(
      List<List<String>> genreList, List<String> clickedDatetime) {
    Map<String, double> genreWeights = {};

    // Iterate over each genre list and click datetime in reverse order
    for (int i = genreList.length - 1; i >= 0; i--) {
      List<String> genres = genreList[i];
      double weight = i.toDouble() + 1.0; // Reverse the weight calculation

      // Assign weights to genres based on genre order and click datetime
      for (int j = 0; j < genres.length; j++) {
        String genre = genres[j];
        double datetimeWeight = calculateDatetimeWeight(clickedDatetime[i]);
        genreWeights[genre] =
            (genreWeights[genre] ?? 0) + (weight * datetimeWeight);
      }
    }

    return genreWeights;
  }

  double calculateDatetimeWeight(String clickedDatetime) {
    DateTime now = DateTime.now();
    DateFormat format = DateFormat('MM/d/yyyy, h:mm:ss a');
    DateTime clickedTime = format.parse(clickedDatetime);

    // Calculate the time difference in hours
    Duration difference = now.difference(clickedTime);
    double hours = difference.inMinutes / 60.0;

    // Calculate the weight based on time decay function
    double weight = 1 / (1 + hours);

    return weight;
  }
}
