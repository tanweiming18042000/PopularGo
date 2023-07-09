import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:populargo/constants/size_config.dart';
import 'package:populargo/features/auth/services/auth_service.dart';
import 'package:provider/provider.dart';

import '../../../constants/global_variables.dart';
import '../../../models/book.dart';
import '../../../models/wishlist.dart';
import '../../../providers/user_provider.dart';

class ListItemWidget extends StatefulWidget {
  final int wishlistQuantity;
  final Wishlist wishlist;
  final Book book;
  final Animation<double> animation;
  final VoidCallback? onClicked;

  const ListItemWidget({
    Key? key,
    required this.wishlistQuantity,
    required this.animation,
    required this.onClicked,
    required this.wishlist,
    required this.book,
  }) : super(key: key);

  @override
  _ListItemWidgetState createState() => _ListItemWidgetState();
}

class _ListItemWidgetState extends State<ListItemWidget> {
  late int wishlistQuantity;
  final AuthService authService = AuthService();

  void deleteOneWishlist(String bookId) {
    authService.deleteOneWishlist(
        context: context,
        user_id: Provider.of<UserProvider>(context, listen: false).user.id,
        book_id: bookId);
  }

  void createWishlist(Book book, int quantity) {
    authService.createWishlist(
        context: context,
        user_id: Provider.of<UserProvider>(context, listen: false).user.id,
        book_id: book.id,
        quantity: quantity,
        price: book.price);
  }

  @override
  void initState() {
    super.initState();
    wishlistQuantity = widget.wishlistQuantity;
  }

  @override
  void didUpdateWidget(ListItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    wishlistQuantity = widget.wishlistQuantity;
  }

  @override
  Widget build(BuildContext context) => SizeTransition(
        key: ValueKey(widget.book.img),
        sizeFactor: widget.animation,
        child: buildItem(),
      );

  Widget buildItem() => Container(
        margin: EdgeInsets.fromLTRB(
          getProportionateScreenHeight(10),
          getProportionateScreenHeight(10),
          getProportionateScreenHeight(10),
          0,
        ),
        child: Card(
          elevation: 0,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: getProportionateScreenHeight(10)),
                child: Container(
                  width: getProportionateScreenWidth(
                    120,
                  ),
                  height: getProportionateScreenHeight(160),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('$uri/${widget.book.img}'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: getProportionateScreenWidth(10),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: getProportionateScreenHeight(20),
                      ),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    Text(
                      widget.book.authName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFF899499),
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(10)),
                    Text(
                      'RM ${widget.book.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: getProportionateScreenHeight(20),
                        color: GlobalVariables.secondaryColor,
                      ),
                    ),
                    SizedBox(height: getProportionateScreenHeight(10)),
                    Row(
                      children: [
                        Container(
                          width: getProportionateScreenWidth(30),
                          height: getProportionateScreenHeight(30),
                          decoration: BoxDecoration(color: Color(0xFFD3D3D3)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: wishlistQuantity > 0
                                    ? () {
                                        setState(() {
                                          wishlistQuantity--;
                                          if (wishlistQuantity == 0) {
                                            widget.onClicked?.call();
                                            deleteOneWishlist(widget.book.id);
                                          } else {
                                            createWishlist(
                                                widget.book, wishlistQuantity);
                                          }
                                        });
                                      }
                                    : null,
                                child: Icon(
                                  Icons.remove,
                                  size: getProportionateScreenWidth(15),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: Container(
                            key: ValueKey<int>(wishlistQuantity),
                            width: getProportionateScreenWidth(30),
                            height: getProportionateScreenHeight(30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  wishlistQuantity.toString(),
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: getProportionateScreenWidth(30),
                              height: getProportionateScreenHeight(30),
                              decoration:
                                  BoxDecoration(color: Color(0xFFD3D3D3)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        wishlistQuantity++;
                                        createWishlist(
                                            widget.book, wishlistQuantity);
                                      });
                                    },
                                    child: Icon(Icons.add),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}


// testing (ori)

// class ListItemWidget extends StatelessWidget {
//   final int wishlistQuantity;
//   final Wishlist wishlist;
//   final Book book;
//   final Animation<double> animation;
//   final VoidCallback? onClicked;
//   const ListItemWidget(
//       {super.key,
//       required this.wishlistQuantity,
//       required this.animation,
//       required this.onClicked,
//       required this.wishlist,
//       required this.book});

//   @override
//   Widget build(BuildContext context) => SizeTransition(
//       key: ValueKey(book.img), sizeFactor: animation, child: buildItem());

//   Widget buildItem() => Container(
//         // height: getProportionateScreenHeight(180),
//         margin: EdgeInsets.fromLTRB(
//             getProportionateScreenHeight(10),
//             getProportionateScreenHeight(10),
//             getProportionateScreenHeight(10),
//             0),
//         // decoration: BoxDecoration(
//         //   border: Border.all(width: 1, color: Colors.black),
//         //   // borderRadius: BorderRadius.circular(12),
//         //   color: Colors.white,
//         // ),
//         // child: Card(
//         //   child: ListTile(
//         //     // visualDensity: VisualDensity(vertical: 4),
//         //     // contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//         //     leading: Image.network(
//         //       '$uri\\${book.img}',
//         //       height: getProportionateScreenHeight(160),
//         //       fit: BoxFit.contain,
//         //     ),

//         //     title: Text(
//         //       book.title,
//         //       style: TextStyle(
//         //           fontSize: getProportionateScreenHeight(14),
//         //           color: Colors.black),
//         //     ),
//         //     trailing: IconButton(
//         //       icon: Icon(Icons.delete, color: Colors.red, size: 32),
//         //       onPressed: onClicked,
//         //     ),
//         //   ),
//         // ),
//         child: Card(
//           child: Row(
//             children: [
//               Container(
//                 width: getProportionateScreenWidth(
//                   120,
//                 ), // Adjust the width as needed
//                 child: Image.network(
//                   '$uri\\${book.img}',
//                   height: getProportionateScreenHeight(160),
//                   // width: getProportionateScreenWidth(100),
//                   fit: BoxFit.fitHeight,
//                 ),
//               ),
//               SizedBox(
//                 width: getProportionateScreenWidth(10),
//               ), // Add spacing between the image and the text
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       book.title,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: getProportionateScreenHeight(20),
//                       ),
//                     ),
//                     SizedBox(
//                       height: getProportionateScreenHeight(10),
//                     ), // Add spacing between the title and subtitle
//                     Text(
//                       book.authName,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: Color(0xFF899499),
//                       ),
//                     ),
//                     SizedBox(height: getProportionateScreenHeight(10)),
//                     Text(
//                       'RM ${book.price.toString()}',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: getProportionateScreenHeight(20),
//                         color: GlobalVariables.secondaryColor,
//                       ),
//                     ),
//                     SizedBox(height: getProportionateScreenHeight(10)),
//                     IconButton(
//                       icon: Icon(Icons.delete, color: Colors.red, size: 32),
//                       onPressed: onClicked,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
// }
