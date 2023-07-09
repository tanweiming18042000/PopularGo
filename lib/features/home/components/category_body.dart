import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:populargo/features/auth/services/auth_service.dart';
import 'package:populargo/features/home/components/book_details.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../../constants/error_handling.dart';
import '../../../constants/global_variables.dart';
import '../../../constants/size_config.dart';
import '../../../constants/utils.dart';
import '../../../models/book.dart';
import 'dart:io';

import '../../../models/userClickedBooks.dart';
import '../../../providers/user_provider.dart';

typedef GetBooksFunction = Future<List<Book>> Function(String genre);

Future<void> createUserClickedBook({
  required BuildContext context,
  required String user_id,
  required List<String> genreList,
}) async {
  try {
    final userClickedBook = UserClickedBooks(
      user_id: user_id,
      genreList: genreList, // Wrap genreList in a nested list
      clicked_datetime: [],
      id: '',
    );

    final response = await http.post(
      Uri.parse('$uri/api/createUserClickedBook'),
      body: jsonEncode(userClickedBook.toJson()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      // User clicked book created successfully
      // showSnackBar(context, 'User clicked book created!');
    } else {
      print('Failed to create user clicked book: ${response.body}');
      throw Exception('Failed to create user clicked book');
    }
  } catch (e) {
    showSnackBar(context, e.toString());
  }
}

Widget CategoryBody(String genre, GetBooksFunction getBooks) {
  return FutureBuilder<List<Book>>(
    future: getBooks(genre),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final bookList = snapshot.data!;
        return Container(
          padding: EdgeInsets.fromLTRB(
              getProportionateScreenWidth(15),
              getProportionateScreenHeight(20),
              getProportionateScreenWidth(15),
              getProportionateScreenHeight(20)),
          child: Column(
            children: [
              // Rest of your code to display the books in a GridView or any other desired layout
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  // the distance between rows
                  mainAxisSpacing: getProportionateScreenHeight(30),
                  // the distance between column
                  crossAxisSpacing: getProportionateScreenWidth(10),
                  mainAxisExtent: getProportionateScreenHeight(375),
                ),
                itemCount: bookList.length,
                itemBuilder: (context, index) {
                  final book = bookList[index];
                  // final truncatedTitle = book.title.length > 50
                  //     ? '${book.title.substring(0, 50)}...'
                  //     : book.title;
                  return GestureDetector(
                    onTap: () {
                      print('book genre: ${book.genre}');

                      // record into the userClickedBooks table
                      createUserClickedBook(
                        context: context,
                        user_id:
                            Provider.of<UserProvider>(context, listen: false)
                                .user
                                .id,
                        genreList: book.genre,
                      );
                      Navigator.pushNamed(context, BookDetails.routeName,
                          arguments: book);
                    },
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              '$uri\\${book.img}',
                              width: getProportionateScreenWidth(150),
                              height: getProportionateScreenHeight(240),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          width: getProportionateScreenWidth(150),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: getProportionateScreenHeight(40),
                                child: Text(
                                  book.title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize:
                                          getProportionateScreenHeight(18)),
                                ),
                              ),
                              SizedBox(
                                  height: getProportionateScreenHeight(10)),
                              Text(
                                '${book.authName}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: getProportionateScreenHeight(14)),
                              ),
                              SizedBox(
                                height: getProportionateScreenHeight(20),
                              ),
                              Container(
                                padding: EdgeInsets.all(6.0),
                                decoration: BoxDecoration(
                                    color: GlobalVariables.secondaryColor),
                                child: Text(
                                  'RM ${book.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: getProportionateScreenHeight(16),
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        // Additional book details if needed
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        );
      } else {
        return Container();
      }
    },
  );
}
