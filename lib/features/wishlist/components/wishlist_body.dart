import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/utils.dart';
import '../../../models/book.dart';
import '../../../models/wishlist.dart';
import '../../../providers/user_provider.dart';
import '../../auth/services/auth_service.dart';
import '../widgets/list_item_widget.dart';

class WishlistBody extends StatefulWidget {
  static const String routeName = '/wishlistBody';
  const WishlistBody({super.key});

  @override
  State<WishlistBody> createState() => _WishlistBodyState();
}

class _WishlistBodyState extends State<WishlistBody> {
  final AuthService authService = AuthService();
  List<Wishlist> wishlists = [];
  List<Book> books = [];
  bool initialized = false;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<int> _wishlistQuantities = [];

  @override
  void initState() {
    super.initState();
    if (!initialized) {
      initializeWishlist();
    }
  }

  void _initializeWishlistQuantities() {
    // Assuming wishlists is a List<Wishlist> obtained from somewhere
    _wishlistQuantities =
        wishlists.map<int>((wishlist) => wishlist.quantity).toList();
  }

  Future<void> initializeWishlist() async {
    await getAllWishlist();
    await fetchBooksForWishlistItems();

    setState(() {
      initialized = true;
    });
  }

  // get all wishlist
  Future<void> getAllWishlist() async {
    try {
      final datas = await authService.getAllWishlist(
          context: context,
          user_id: Provider.of<UserProvider>(context, listen: false).user.id);
      setState(() {
        wishlists = datas;
      });
    } catch (error) {
      showSnackBar(context, error.toString());
    }
  }

  Future<void> fetchBooksForWishlistItems() async {
    final List<Future<Book>> bookFutures = wishlists.map((wishlist) {
      return getOneBook(wishlist.book_id);
    }).toList();

    final fetchedBooks = await Future.wait(bookFutures);
    setState(() {
      books = fetchedBooks;
    });

    _initializeWishlistQuantities();
  }

  Future<Book> getOneBook(String bookId) {
    return authService.getOneBook(
      context: context,
      bookId: bookId,
    );
  }

  // double calculateTotalPrice(List<Book> books, List<int> quantities) {
  //   double totalPrice = 0;

  //   for (int i = 0; i < books.length; i++) {
  //     double bookPrice = books[i].price;
  //     int quantity = quantities[i];
  //     totalPrice += bookPrice * quantity;
  //   }

  //   return totalPrice;
  // }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    if (!initialized) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Wishlist'),
        ),
        body: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      );
    }

    if (wishlists.isEmpty) {
      // text
      return Scaffold(
        appBar: AppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('No wishlist items'),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Wishlist'),
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedList(
                key: _listKey,
                initialItemCount: _wishlistQuantities.length,
                itemBuilder: (context, index, animation) => ListItemWidget(
                      wishlistQuantity: _wishlistQuantities[index],
                      wishlist: wishlists[index],
                      book: books[index],
                      animation: animation,
                      onClicked: () => removeItem(index),
                    )),
          ),
        ],
      ),
    );
  }

  void removeItem(int index) {
    final removedWishlist = wishlists[index];
    final removedQuantity = _wishlistQuantities[index];
    final removedBook = books[index];

    wishlists.removeAt(index);
    _wishlistQuantities.removeAt(index);
    books.removeAt(index);
    _listKey.currentState!.removeItem(
      index,
      (context, animation) => ListItemWidget(
        wishlistQuantity: removedQuantity,
        animation: animation,
        wishlist: removedWishlist,
        book: removedBook,
        onClicked: () {},
      ),
      duration: Duration(milliseconds: 600),
    );
  }
}
