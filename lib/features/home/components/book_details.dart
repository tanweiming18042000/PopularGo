import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:populargo/constants/size_config.dart';
import 'package:populargo/features/auth/services/auth_service.dart';
import 'package:populargo/models/wishlist.dart';
import 'package:provider/provider.dart';

import '../../../constants/global_variables.dart';
import '../../../constants/utils.dart';
import '../../../models/book.dart';
import '../../../providers/user_provider.dart';

class BookDetails extends StatefulWidget {
  static const String routeName = '/home/bookDetails';
  const BookDetails({super.key});

  @override
  State<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  // variable
  bool iconClick = false;
  Wishlist wishlistItem =
      new Wishlist(user_id: '', id: '', book_id: '', quantity: 0, price: 0);
  final AuthService authService = AuthService();

  // create wishlist
  void createWishlist() {
    // access the arguments
    final Book book = ModalRoute.of(context)?.settings.arguments as Book;

    authService.createWishlist(
        context: context,
        user_id: Provider.of<UserProvider>(context, listen: false).user.id,
        book_id: book.id,
        quantity: 1,
        price: book.price);
  }

  void deleteOneWishlist() {
    // access the arguments
    final Book book = ModalRoute.of(context)?.settings.arguments as Book;

    authService.deleteOneWishlist(
        context: context,
        user_id: Provider.of<UserProvider>(context, listen: false).user.id,
        book_id: book.id);
  }

  // check book in wishlist or not
  void getOneWishlist() {
    // access the arguments
    final Book book = ModalRoute.of(context)?.settings.arguments as Book;

    authService
        .getOneWishlist(
      context: context,
      user_id: Provider.of<UserProvider>(context, listen: false).user.id,
      book_id: book.id,
    )
        .then((wishlist) {
      // Wishlist retrieval succeeded
      // Handle the wishlist item (wishlist)
      setState(() {
        // Update the state with the retrieved wishlist
        // Example: assign the wishlist item to a variable
        wishlistItem = wishlist;
      });
    }).catchError((error) {
      // Error occurred during wishlist retrieval
      // Handle the error case
      showSnackBar(context, error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final book = ModalRoute.of(context)?.settings.arguments as Book?;

    if (book == null) {
      return Scaffold(
        appBar: AppBar(),
      );
    }

    // when open the detail page, use the book id to check for the book
    // if the book is in the wishlist table,
    // set the icon to the pressed icon
    // else, is the no pressed icon
    getOneWishlist();
    if (wishlistItem.book_id == book.id) {
      iconClick = true;
    } else {
      iconClick = false;
    }

    // inplement the details UI
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Book Details'),
          elevation: 0,
          actions: <Widget>[
            IconButton(
              icon: iconClick
                  ? Icon(Icons.bookmark_add_rounded)
                  : Icon(Icons.bookmark_add_outlined),
              onPressed: () {
                // run the createWishlist function
                // change the icon if success
                if(iconClick == false) {
                  createWishlist();
                } else {
                  deleteOneWishlist();
                }

                setState(() {
                  iconClick = !iconClick;
                });
              },
            ),
            SizedBox(
              width: getProportionateScreenWidth(10),
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                '$uri\\${book.img}',
                fit: BoxFit.cover,
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            Positioned(
              top: getProportionateScreenHeight(192),
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Expanded(
                        child: SizedBox(),
                      ),
                      Material(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: GlobalVariables.secondaryColor,
                            border: Border.all(
                                color: Colors.grey.withOpacity(0.2), width: 1),
                            // borderRadius: BorderRadius.only(
                            //   topLeft: Radius.circular(20),
                            //   topRight: Radius.circular(20),
                            // ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: getProportionateScreenWidth(20),
                              vertical: getProportionateScreenHeight(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Add your additional content here
                                Center(
                                  child: Text(
                                    'RM ${book.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          getProportionateScreenHeight(18),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 10.0),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          '$uri\\${book.img}',
                          width: getProportionateScreenWidth(140),
                          height: getProportionateScreenHeight(224),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(book.genre.length - 1, (index) {
                      final genre = book.genre[index + 1];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Row(
                          children: [
                            Text(
                              '${genre}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: getProportionateScreenHeight(16),
                                  color: Color(0XFFda6a5a)),
                            ),
                            if (index < book.genre.length - 2) Text(' . '),
                          ],
                        ),
                      );
                    })),
                SizedBox(
                  height: getProportionateScreenHeight(5),
                ),
                Container(
                  height: getProportionateScreenHeight(50),
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: AutoSizeText(
                    '${book.title}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: getProportionateScreenHeight(20)),
                  ),
                ),
                SizedBox(
                  height: getProportionateScreenHeight(10),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                          text: 'by ',
                          style: TextStyle(
                              fontSize: getProportionateScreenHeight(14),
                              color: Color(0XFFa5a299)),
                          children: [
                            TextSpan(
                                text: book.authName,
                                style: TextStyle(
                                  fontSize: getProportionateScreenHeight(14),
                                  color: Color(0XFF809C90),
                                )),
                            TextSpan(
                                text: ' | ',
                                style: TextStyle(
                                    fontSize:
                                        getProportionateScreenHeight(14))),
                            TextSpan(
                                text: '${book.pageNum} pages',
                                style: TextStyle(
                                    fontSize: getProportionateScreenHeight(14)))
                          ]),
                    )
                  ],
                ),
                SizedBox(
                  height: getProportionateScreenHeight(15),
                ),
                Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Divider(
                      thickness: 1,
                    )),
                SizedBox(
                  height: getProportionateScreenHeight(10),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: [
                      Text(
                        'Overview',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: getProportionateScreenHeight(15),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: 180,
                  child: ShaderMask(
                    shaderCallback: (Rect rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Colors.transparent],
                        stops: [0.9, 1.0],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Scrollbar(
                      thickness: 1,
                      thumbVisibility: true,
                      scrollbarOrientation: ScrollbarOrientation.left,
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Text(
                            '${book.description}',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
