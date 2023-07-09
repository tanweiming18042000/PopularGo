import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:populargo/constants/size_config.dart';
import 'package:populargo/features/account/components/exitPage/noPurchasePage.dart';
import 'package:populargo/features/auth/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../constants/global_variables.dart';
import '../../../models/ProductScan/scannedProduct.dart';
import '../../../models/book.dart';
import '../../../providers/user_provider.dart';
import 'exitPage/chooseDiscountPage.dart';
import 'exitPage/receipt_checkout.dart';

class PayQRCodeScreen extends StatefulWidget {
  static const String routeName = '/account/PayQRCode';
  const PayQRCodeScreen({super.key});

  @override
  State<PayQRCodeScreen> createState() => _PayQRCodeScreenState();
}

class _PayQRCodeScreenState extends State<PayQRCodeScreen> {
  final AuthService authService = AuthService();
  late IO.Socket socket;
  int randomNum = 0;
  String hashStr = "";
  int cash = 0;
  int pennies = 0;
  late ScannedProduct scannedProduct;
  List<String> bookIdList = [];
  late List<Book> books;
  String rfid_id = '';
  List<String> discountIds = [];

  @override
  void initState() {
    super.initState();
    randomNum = generateRandomNumber();
    hashStr =
        "${Provider.of<UserProvider>(context, listen: false).user.id},${randomNum.toString()}";
    generateHashAndContinue();
    connectToSocket();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final List<int>? arguments =
        ModalRoute.of(context)!.settings.arguments as List<int>?;
    if (arguments != null && arguments.length >= 2) {
      cash = arguments[0];
      pennies = arguments[1];
    }
  }

  @override
  void dispose() {
    // socket.dispose();
    super.dispose();
  }

  int generateRandomNumber() {
    var random = Random();
    return random.nextInt(9000) + 1000;
  }

  // use SHA-256 hashing
  String generateSHA256Hash(String input) {
    var bytes = utf8.encode(input);
    var shaHash = sha256.convert(bytes);
    return shaHash.toString();
  }

  Future<void> generateHashAndContinue() async {
    hashStr = await generateSHA256Hash(hashStr);
    setState(() {});
    createPaymentQRKey(hashStr);
  }

  void createPaymentQRKey(String hashStr) {
    authService.createPaymentQRKey(
        context: context,
        user_id: Provider.of<UserProvider>(context, listen: false).user.id,
        qrStr: hashStr);
  }

  Future<String> getExitUserVisitStartDate() async {
    return await authService.getExitUserVisitStartDate(
        context: context,
        user_id: Provider.of<UserProvider>(context, listen: false).user.id);
  }

  void createExitUserVisit(String user_id, String start_datetime) {
    authService.createExitUserVisit(
        context: context, user_id: user_id, start_datetime: start_datetime);
  }

  Future<ScannedProduct> getOneScannedProduct(String rfid_id) async {
    return await authService.getOneScannedProduct(
        context: context, rfid_id: rfid_id);
  }

  Future<List<Book>> getBooks(List<String> bookIdList) async {
    return await authService.getAllPaidBooks(
        context: context, bookIds: bookIdList);
  }

  // connect to socket
  // if receive from server (scanner) --> the rfid_id, and list of unusedDiscountID
  // move to another page that display the list of unusedDiscount
  // choose one of it, go to another page that shows the receipt with discount price.
  //--> API to retrieve discountPercent with discountId.
  // if didn't choose the discount, go to page that shows the receipt with original price.
  // pressed checkout button or not
  // if pressed checkout button, check with the userBalance balance with user_id
  // if enough, do all the update to all the tables, navigate to success table. Then delete the scannedProduct with rfid_id
  // --> send a 'good' socket to the server, which will io.emit to exitScan. It received it will produce correct sound.
  // if not enough, go to a page says not enough balance, please reload. Delete the scannedProduct with rfid_id.
  //  --> send a 'bad' socket to the server, which will io.emit to exitScan. It received it will produce error sound.
  // if press don't checkout button, delete the scannedProduct with rfid_id
  //  --> send a 'bad' socket to the server, which will io.emit to exitScan. It received it will produce error sound.
  void connectToSocket() {
    socket = IO.io('$uri', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.onConnect((_) {
      print('Connected to WebSocket server');
    });

    socket.on('qrcode_response', (data) {
      print('PUPU: ${data['qrCode']}');
      final qrCode = data['qrCode'];
    });

    // received from server for customer not purchase stuff
    // update userVisit end_datetime, duration and go to thanks for purchase page
    socket.on('customer_no_purchase', (data) async {
      // straight update the userVisitEndtime
      String startDatetime = await getExitUserVisitStartDate();
      print('start date time: $startDatetime');
      createExitUserVisit(
          Provider.of<UserProvider>(context, listen: false).user.id,
          startDatetime);
      // emit socket to server, for done stuff,
      // exitScanner can produce the correct sound
      socket.emit('done_exit');
      print('yes');
      // navigate to thanks for coming page
      Navigator.pushNamedAndRemoveUntil(
        context,
        NoPurchasePage.routeName,
        (route) =>
            false, // Pass the desired initial page number as an argument (3 in this case)
      );
    });

    // erceived from server for customer with purchase but no unused discount
    // straight,straight go to receipt checkoout page
    // use the rfid_id to get everything, then use the bookIdList
    // to get the books from the database
    // display the receipt with book title, authname
    // quantity, price, subtotal, estimatedTax, total
    // like the receipt detail page
    socket.on('customer_no_unused_discounts', (data) async {
      if (data.containsKey('rfid_id') && data['rfid_id'] is String) {
        rfid_id = data['rfid_id'];
        scannedProduct = await getOneScannedProduct(rfid_id);

        bookIdList = scannedProduct.bookIdList;
        books = await getBooks(bookIdList);
        print('cello');
        // pass the books and scannedProduct to receipt page
        Navigator.pushNamed(
          context,
          ReceiptCheckoutPage.routeName,
          arguments: {
            'scannedProduct': scannedProduct,
            'books': books,
          },
        );
      } else {
        print('Invalid rfid_id format');
      }
    });

    // have unusedDiscount
    // go to discount page to choose discount
    socket.on('customer_have_unused_discounts', (data) async {
      if (data.containsKey('rfid_id') && data['rfid_id'] is String) {
        rfid_id = data['rfid_id'];
        discountIds =
            (data['unusedDiscountIds'] as List<dynamic>).cast<String>();
        print('rfid_id: $rfid_id');
        scannedProduct = await getOneScannedProduct(rfid_id);
        print('scannedProduct: $scannedProduct');
        print('scannedProduct subtotal: ${scannedProduct.subtotal}');
        print('scannedProduct estimatedTax: ${scannedProduct.estimatedTax}');
        print('scannedProduct total: ${scannedProduct.total}');

        bookIdList = scannedProduct.bookIdList;
        books = await getBooks(bookIdList);
        print('cello');
        // pass the scannedProduct, books and discountIds to the discountPage.
        Navigator.pushNamed(
          context,
          ChooseDiscountPage.routeName,
          arguments: {
            'scannedProduct': scannedProduct,
            'books': books,
            'discountIds': discountIds,
          },
        );
      } else {
        print('Invalid rfid_id format');
      }
    });

    socket.onDisconnect((_) {
      print('Disconnected from WebSocket server');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Payment QR Code'),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.only(
              bottom: getProportionateScreenHeight(kToolbarHeight)),
          child: Container(
              height: getProportionateScreenHeight(410),
              width: getProportionateScreenWidth(320),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(getProportionateScreenHeight(20)),
                border:
                    Border.all(width: 1.0, color: Colors.grey.withOpacity(0.7)),
                color: Color(0xFFFFFFFF),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: getProportionateScreenHeight(50),
                  ),
                  Text(
                    'SCAN QR CODE TO PAY',
                    style: TextStyle(
                        fontSize: getProportionateScreenHeight(16),
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: getProportionateScreenHeight(10),
                  ),
                  QrImage(
                    data: hashStr,
                    version: QrVersions.auto,
                    size: getProportionateScreenHeight(250),
                  ),
                  SizedBox(
                    height: getProportionateScreenHeight(40),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(left: getProportionateScreenWidth(20)),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Balance',
                            style: TextStyle(
                              fontSize: getProportionateScreenHeight(20),
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF818181),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                right: getProportionateScreenWidth(20)),
                            child: Text(
                              'RM ${cash}.${pennies}',
                              style: TextStyle(
                                fontSize: getProportionateScreenHeight(20),
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF000000),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
