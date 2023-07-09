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
import '../../../../models/userBalance.dart';
import '../../../../providers/user_provider.dart';
import '../../../auth/services/auth_service.dart';

class NoDiscountReceiptCheckoutPage extends StatefulWidget {
  static const String routeName = '/noDiscountReceiptCheckoutPage';
  const NoDiscountReceiptCheckoutPage({super.key});

  @override
  State<NoDiscountReceiptCheckoutPage> createState() =>
      _NoDiscountReceiptCheckoutPageState();
}

class _NoDiscountReceiptCheckoutPageState
    extends State<NoDiscountReceiptCheckoutPage> {
  final AuthService authService = AuthService();
  late IO.Socket socket;
  late ScannedProduct scannedProduct;
  late List<Book> books;
  int totalQuantity = 0;
  UserBalance userBalance = UserBalance(user_id: '', id: '', totalBalance: 0.0);
  double totalBalance = 0.0;
  String startDatetime = '';
  String userVisitId = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    connectToSocket();
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    scannedProduct = arguments['scannedProduct'];
    books = arguments['books'];

    // Calculate the total quantity
    totalQuantity =
        scannedProduct.quantityList.fold(0, (sum, quantity) => sum + quantity);
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
                      itemCount: scannedProduct.bookIdList.length,
                      itemBuilder: (context, index) {
                        final bookId = scannedProduct.bookIdList[index];
                        final book =
                            books.firstWhere((book) => book.id == bookId);
                        final quantity = scannedProduct.quantityList[index];
                        final price = scannedProduct.priceList[index];

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
                      height: getProportionateScreenHeight(150),
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
                                  'RM ${scannedProduct.subtotal.toStringAsFixed(2)}',
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
                                  'RM ${scannedProduct.estimatedTax.toStringAsFixed(2)}',
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
                                  'RM ${scannedProduct.total.toStringAsFixed(2)}',
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
                    if (totalBalance < scannedProduct.total) {
                      //delete the scannedProduct
                      deleteOneScannedProduct(scannedProduct.rfid_id);

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        BottomBar.routeName,
                        (route) =>
                            false, // Pass the desired initial page number as an argument (3 in this case)
                      );
                    } else {
                      socket.emit('done_exit');
                      // record payment
                      createPayment(
                          userVisitId,
                          scannedProduct.bookIdList,
                          scannedProduct.quantityList,
                          scannedProduct.priceList,
                          scannedProduct.subtotal,
                          scannedProduct.estimatedTax,
                          scannedProduct.total);

                      // transaction history
                      createExitTransactionHistory(
                          Provider.of<UserProvider>(context, listen: false)
                              .user
                              .id,
                          scannedProduct.total);

                      // userBalance
                      updateUserBalance(
                          Provider.of<UserProvider>(context, listen: false)
                              .user
                              .id,
                          totalBalance - scannedProduct.total);

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
                          scannedProduct.bookIdList,
                          scannedProduct.quantityList);

                      // notification
                        triggerNotification(scannedProduct.total);


                      //delete the scannedProduct
                      deleteOneScannedProduct(scannedProduct.rfid_id);

                      // go to payment success page
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        PaymentSuccessPage.routeName,
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      totalBalance > scannedProduct.total
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
