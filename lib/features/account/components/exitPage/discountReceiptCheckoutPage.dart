import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:populargo/features/account/components/exitPage/paymentSuccessPage.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../common/widgets/bottom_bar.dart';
import '../../../../constants/global_variables.dart';
import '../../../../constants/size_config.dart';
import '../../../../models/ProductScan/scannedProduct.dart';
import '../../../../models/book.dart';
import '../../../../models/discount.dart';
import '../../../../models/userBalance.dart';
import '../../../../providers/user_provider.dart';
import '../../../auth/services/auth_service.dart';

class DiscountReceiptCheckoutPage extends StatefulWidget {
  static const String routeName = '/discountReceiptCheckoutPage';
  const DiscountReceiptCheckoutPage({super.key});

  @override
  State<DiscountReceiptCheckoutPage> createState() =>
      _DiscountReceiptCheckoutPageState();
}

// 1) when the 'Use Now' button is pressed, go to the discountedReceiptCheckoutPage
// --> pass the scannedProduct, books, Discount object
// See the mustOverMaxPrice of discount, if is 'All', apply for all book contained in the reference
// else, take the mustOverMaxPrice and turn it to number, then that is the number of book that got discount
// when the CHECKOUT button is pressed, remember to update the UsedDiscount table
// if the either CHECKOUT or PLEASE RELOAD button is pressed, will delete rfid_id also

// show receipt with discounted price
// how to calculate discount?
// create a copy of scannedProduct, named it as discountedScannedProduct
// 1) take the discount.genre, discount.mustOverMaxPrice, discount.discountPercent
// 2) check discount.mustOverMaxPrice, if it is == 'All', loop through the books.genre,
// if there is a matching between the books.genre list and the discount.genre,
// take the index
// add apply discount.discountPercent to the discountedScannedProduct.priceList[index]
// in the end, recalculate the subtotal, estimatedTax, total

// 2) if discount.mustOverMaxPrice is 1, make it to integer == mostly 1 (won't have 2 or 3)
// 3) loop through the books genre, find the books.genre that is in the discount.genre --> only 1 will do
// 4) then the on with the highest price, get the index, check the discountedScannedProduct.quantityList[index]
// 5) apply the percentage to the priceList[index], but when calculate the total,
// 6) check with scannedProduct.priceList, which index is different, for that particular index,
// the total (quantity - 1) * original price + discountedPrice, the rest is original

// final show a saved = scannedProduct.total - discountedScannedProduct.total
// then use the discountedScannedProduct price when saved to table
class _DiscountReceiptCheckoutPageState
    extends State<DiscountReceiptCheckoutPage> {
  final AuthService authService = AuthService();
  late IO.Socket socket;
  late ScannedProduct scannedProduct;
  late ScannedProduct discountedScannedProduct;
  double discountedSubtotal = 0;
  double discountedEstimatedTax = 0;
  double discountedTotal = 0;
  late List<Book> books;
  int totalQuantity = 0;
  UserBalance userBalance = UserBalance(user_id: '', id: '', totalBalance: 0.0);
  double totalBalance = 0.0;
  String startDatetime = '';
  String userVisitId = '';
  late Discount discount;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    connectToSocket();
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    scannedProduct = arguments['scannedProduct'];
    discountedScannedProduct = ScannedProduct(
      rfid_id: scannedProduct.rfid_id,
      id: scannedProduct.id,
      bookIdList: List<String>.from(scannedProduct.bookIdList),
      quantityList: List<int>.from(scannedProduct.quantityList),
      priceList: List<double>.from(scannedProduct.priceList),
      subtotal: scannedProduct.subtotal,
      estimatedTax: scannedProduct.estimatedTax,
      total: scannedProduct.total,
    );
    books = arguments['books'];
    discount = arguments['discount'];

    // Calculate the total quantity
    totalQuantity =
        scannedProduct.quantityList.fold(0, (sum, quantity) => sum + quantity);

    // calculate the discountedScannedProduct if 'All'
    if (discount.mustOverMaxPrice == 'All') {
      for (int i = 0; i < books.length; i++) {
        final Book book = books[i];
        if (book.genre.any((genre) => discount.genre.contains(genre))) {
          // Apply discount to the price
          discountedScannedProduct.priceList[i] =
              discountedScannedProduct.priceList[i] *
                  ((100 - discount.discountPercent) / 100);
        }
      }

      // Recalculate subtotal, estimatedTax, and total
      for (int i = 0; i < discountedScannedProduct.quantityList.length; i++) {
        discountedSubtotal += discountedScannedProduct.quantityList[i] *
            discountedScannedProduct.priceList[i];
      }

      discountedEstimatedTax = discountedSubtotal * 0.06;
      discountedTotal = discountedSubtotal + discountedEstimatedTax;

      discountedSubtotal = double.parse(discountedSubtotal.toStringAsFixed(2));
      discountedEstimatedTax =
          double.parse(discountedEstimatedTax.toStringAsFixed(2));
      discountedTotal = double.parse(discountedTotal.toStringAsFixed(2));
    } else if (discount.mustOverMaxPrice == '1') {
      // condition where the mustOverMaxPrice is == '1'
      double maxPrice = 0;
      int maxPriceIndex = -1;

      // Find the book with the highest price among books with matching genres
      for (int i = 0; i < books.length; i++) {
        final Book book = books[i];
        if (book.genre.any((genre) => discount.genre.contains(genre))) {
          if (discountedScannedProduct.priceList[i] > maxPrice) {
            maxPrice = discountedScannedProduct.priceList[i];
            maxPriceIndex = i;
          }
        }
      }

      // Apply discount to the book with the highest price
      if (maxPriceIndex != -1) {
        discountedScannedProduct.priceList[maxPriceIndex] =
            discountedScannedProduct.priceList[maxPriceIndex] *
                ((100 - discount.discountPercent) / 100);
      }

      // Recalculate subtotal, estimatedTax, and total
      for (int i = 0; i < discountedScannedProduct.quantityList.length; i++) {
        if (i == maxPriceIndex &&
            discountedScannedProduct.quantityList[i] > 1) {
          discountedSubtotal += (discountedScannedProduct.quantityList[i] - 1) *
                  scannedProduct.priceList[i] +
              discountedScannedProduct.priceList[i];
        } else {
          discountedSubtotal += discountedScannedProduct.quantityList[i] *
              discountedScannedProduct.priceList[i];
        }
      }

      discountedEstimatedTax = discountedSubtotal * 0.06;
      discountedTotal = discountedSubtotal + discountedEstimatedTax;

      discountedSubtotal = double.parse(discountedSubtotal.toStringAsFixed(2));
      discountedEstimatedTax =
          double.parse(discountedEstimatedTax.toStringAsFixed(2));
      discountedTotal = double.parse(discountedTotal.toStringAsFixed(2));
    }

    runAllAwait();
    initializeNotificationChannels(); 
  }

  void connectToSocket() {
    socket = IO.io('$uri', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.onConnect((_) {
      print('Connected to WebSocket server');
    });

    socket.onDisconnect((_) {
      print('Disconnected from WebSocket server');
    });
  }

  Future<void> runAllAwait() async {
    userBalance = await getUserBalance();
    startDatetime = await getExitUserVisitStartDate();
    userVisitId = await getExitUserVisitId();
    setState(() {
      totalBalance = userBalance.totalBalance;
      startDatetime = startDatetime;
      userVisitId = userVisitId;
    });
  }

  Future<UserBalance> getUserBalance() async {
    return await authService.getUserBalance(
        context: context,
        user_id: Provider.of<UserProvider>(context, listen: false).user.id);
  }

  // for update userVisit endtime and duration
  Future<String> getExitUserVisitStartDate() async {
    return await authService.getExitUserVisitStartDate(
        context: context,
        user_id: Provider.of<UserProvider>(context, listen: false).user.id);
  }

  Future<void> createExitUserVisit(
      String user_id, String start_datetime) async {
    await authService.createExitUserVisit(
        context: context, user_id: user_id, start_datetime: start_datetime);
  }

  // for payment
  Future<String> getExitUserVisitId() async {
    return await authService.getExitUserVisitId(
        context: context,
        user_id: Provider.of<UserProvider>(context, listen: false).user.id);
  }

  Future<void> createPayment(
      String userVisit_id,
      List<String> bookIdList,
      List<int> quantityList,
      List<double> priceList,
      double subtotal,
      double estimatedTax,
      double total) async {
    await authService.createPayment(
        context: context,
        userVisit_id: userVisit_id,
        bookIdList: bookIdList,
        quantityList: quantityList,
        priceList: priceList,
        subtotal: subtotal,
        estimatedTax: estimatedTax,
        total: total);
  }

  // for transaction history
  Future<void> createExitTransactionHistory(
      String user_id, double amount) async {
    await authService.createExitTransactionHistory(
        context: context,
        user_id: user_id,
        amount: amount,
        transactionType: 'Pay');
  }

  // for user balance
  Future<void> updateUserBalance(String user_id, double totalBalance) async {
    await authService.updateUserBalance(
        context: context, user_id: user_id, totalBalance: totalBalance);
  }

  // for used discount
  Future<void> createUsedDiscount(String user_id, String discount_id) async {
    await authService.createUsedDiscount(
        context: context, user_id: user_id, discount_id: discount_id);
  }

  // delete the scannedProduct with scannedProduct.rfid_id
  Future<void> deleteOneScannedProduct(String rfid_id) async {
    await authService.deleteOneScannedProduct(
        context: context, rfid_id: rfid_id);
  }

  // update and delete the wishlist
  Future<void> updateExitWishlistItem(String user_id, List<String> bookIdList,
      List<int> quantityList) async {
    await authService.updateExitWishlistItem(
        context: context,
        user_id: user_id,
        bookIdList: bookIdList,
        quantityList: quantityList);
  }

  void initializeNotificationChannels() {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
        ),
      ],
      debug: true,
    );
  }

  triggerNotification(double purchaseTotal) {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 10,
            channelKey: 'basic_channel',
            title: 'Payment Successful',
            body: 'You have paid RM ${purchaseTotal}'));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Receipt',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: getProportionateScreenHeight(kToolbarHeight * 0.8),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            left: getProportionateScreenHeight(20),
                          ),
                          child: Text(
                            'ITEM DETAILS',
                            style: TextStyle(
                              color: Color.fromARGB(255, 105, 105, 105),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            right: getProportionateScreenHeight(20),
                          ),
                          child: Text(
                            '$totalQuantity ITEMS',
                            style: TextStyle(
                              color: Color.fromARGB(255, 105, 105, 105),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: discountedScannedProduct.bookIdList.length,
                      itemBuilder: (context, index) {
                        final bookId =
                            discountedScannedProduct.bookIdList[index];
                        final book =
                            books.firstWhere((book) => book.id == bookId);
                        final quantity =
                            discountedScannedProduct.quantityList[index];
                        final price = discountedScannedProduct.priceList[index];

                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.1),
                              width: 1.0,
                            ),
                          ),
                          child: Card(
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: EdgeInsets.all(
                                  getProportionateScreenWidth(8)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.network(
                                    '$uri\\${book.img}',
                                    width: getProportionateScreenWidth(80),
                                    height: getProportionateScreenHeight(128),
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(
                                      width: getProportionateScreenWidth(20)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: getProportionateScreenHeight(
                                                10),
                                          ),
                                          child: Container(
                                            width: getProportionateScreenWidth(
                                                200),
                                            child: Text(
                                              book.title,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          book.authName,
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                              getProportionateScreenHeight(20),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'x $quantity',
                                              style: TextStyle(
                                                fontSize:
                                                    getProportionateScreenHeight(
                                                        18),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              'RM ${price.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize:
                                                    getProportionateScreenHeight(
                                                        18),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: getProportionateScreenHeight(20)),
                    child: Container(
                      height: getProportionateScreenHeight(190),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.grey.withOpacity(0.5), width: 1.0)),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                top: getProportionateScreenHeight(20),
                                bottom: getProportionateScreenHeight(20),
                                left: getProportionateScreenWidth(10),
                                right: getProportionateScreenWidth(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Subtotal',
                                  style: TextStyle(
                                      fontSize:
                                          getProportionateScreenHeight(18)),
                                ),
                                Text(
                                  'RM ${discountedSubtotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize:
                                          getProportionateScreenHeight(18)),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: getProportionateScreenHeight(20),
                                left: getProportionateScreenWidth(10),
                                right: getProportionateScreenWidth(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Estimated Tax (6%)',
                                  style: TextStyle(
                                      fontSize:
                                          getProportionateScreenHeight(18)),
                                ),
                                Text(
                                  'RM ${discountedEstimatedTax.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize:
                                          getProportionateScreenHeight(18)),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: getProportionateScreenHeight(20),
                                left: getProportionateScreenWidth(10),
                                right: getProportionateScreenWidth(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Saved',
                                  style: TextStyle(
                                      fontSize:
                                          getProportionateScreenHeight(18)),
                                ),
                                Text(
                                  'RM ${(scannedProduct.total - discountedTotal).toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize:
                                          getProportionateScreenHeight(18)),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: getProportionateScreenWidth(10),
                                right: getProportionateScreenWidth(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(
                                      fontSize:
                                          getProportionateScreenHeight(22),
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'RM ${discountedTotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize:
                                          getProportionateScreenHeight(22),
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: getProportionateScreenHeight(70),
            color: GlobalVariables.backgroundColor,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (totalBalance < discountedTotal) {
                      // Used discount
                      deleteOneScannedProduct(discountedScannedProduct.rfid_id);

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        BottomBar.routeName,
                        (route) => false,
                      );
                    } else {
                      socket.emit('done_exit');
                      // record payment
                      createPayment(
                          userVisitId,
                          discountedScannedProduct.bookIdList,
                          discountedScannedProduct.quantityList,
                          discountedScannedProduct.priceList,
                          discountedSubtotal,
                          discountedEstimatedTax,
                          discountedTotal);

                      // transaction history
                      createExitTransactionHistory(
                          Provider.of<UserProvider>(context, listen: false)
                              .user
                              .id,
                          discountedTotal);

                      // userBalance
                      updateUserBalance(
                          Provider.of<UserProvider>(context, listen: false)
                              .user
                              .id,
                          totalBalance - discountedTotal);

                      // userVisit
                      createExitUserVisit(
                          Provider.of<UserProvider>(context, listen: false)
                              .user
                              .id,
                          startDatetime);


                      // update the wishlist
                      updateExitWishlistItem(
                          Provider.of<UserProvider>(context, listen: false)
                              .user
                              .id,
                          discountedScannedProduct.bookIdList,
                          discountedScannedProduct.quantityList);

                      // notification
                      triggerNotification(discountedTotal);


                      // Used discount
                      createUsedDiscount(
                          Provider.of<UserProvider>(context, listen: false)
                              .user
                              .id,
                          discount.id);

                      // delete the scanned product
                      deleteOneScannedProduct(discountedScannedProduct.rfid_id);

                      // go to payment success page
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        PaymentSuccessPage.routeName,
                        (route) =>
                            false, // Pass the desired initial page number as an argument (3 in this case)
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      totalBalance > discountedTotal
                          ? 'CHECKOUT'
                          : 'RELOAD WALLET',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
