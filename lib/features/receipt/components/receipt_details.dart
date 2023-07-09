import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:populargo/features/auth/services/auth_service.dart';
import 'package:populargo/models/userVisit.dart';

import '../../../constants/global_variables.dart';
import '../../../constants/size_config.dart';
import '../../../models/book.dart';
import '../../../models/payment.dart';
import '../receipt_screen.dart';

class ReceiptDetails extends StatefulWidget {
  static const String routeName = '/receiptDetails';
  const ReceiptDetails({super.key});

  @override
  State<ReceiptDetails> createState() => _ReceiptDetailsState();
}

class _ReceiptDetailsState extends State<ReceiptDetails> {
  final AuthService authService = AuthService();
  late UserVisit userVisit;
  late Payment payment = Payment(
      bookIdList: [],
      estimatedTax: 0,
      id: '',
      priceList: [],
      quantityList: [],
      status: '',
      subtotal: 0,
      total: 0,
      userVisit_id: '');
  late String formattedDate;
  late String formattedTime;
  late String duration;
  List<Book> paidBooks = [];

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    // Retrieve the VisitPaymentData from arguments
    final VisitPaymentData data =
        ModalRoute.of(context)?.settings.arguments as VisitPaymentData;

    // Assign userVisit and payment from VisitPaymentData
    userVisit = data.userVisit;
    payment = data.payment;
    formattedDate = data.formattedDate;
    formattedTime = data.formattedTime;
    duration = data.duration;

    await runAllAwait();
    setState(() {});
  }

  Future<void> runAllAwait() async {
    paidBooks = await getAllPaidBooks(payment.bookIdList);
  }

  // Receipt details page
  // get the bookIds list from the Payment
  // get all book details list
  Future<List<Book>> getAllPaidBooks(List<String> bookIds) {
    return authService.getAllPaidBooks(context: context, bookIds: bookIds);
  }

  @override
  Widget build(BuildContext context) {
    if (paidBooks.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(
            '${formattedDate}',
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: getProportionateScreenHeight(kToolbarHeight * 0.8),
                width: double.infinity,
                color: GlobalVariables.secondaryColor,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom:
                            getProportionateScreenHeight(kToolbarHeight * 0.1)),
                    child: Text.rich(
                      TextSpan(
                        text: 'Your trip time was ',
                        style: TextStyle(
                          color: GlobalVariables.unselectedNavBarColor,
                          fontSize: getProportionateScreenHeight(18),
                        ),
                        children: [
                          TextSpan(
                            text: '${duration}',
                            style: TextStyle(
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
                        '$formattedTime',
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
                        '${payment.quantityList.reduce((a, b) => a + b)} ITEMS',
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
                child: FutureBuilder<List<Book>>(
                  future: getAllPaidBooks(payment.bookIdList),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error loading paid books'),
                      );
                    } else {
                      paidBooks = snapshot.data ?? [];
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: paidBooks.length,
                        itemBuilder: (context, index) {
                          final book = paidBooks[index];
                          return Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.1),
                                    width: 1.0)),
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
                                              width:
                                                  getProportionateScreenWidth(
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
                                                getProportionateScreenHeight(
                                                    20),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'x ${payment.quantityList[index]}',
                                                style: TextStyle(
                                                    fontSize:
                                                        getProportionateScreenHeight(
                                                            18),
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Text(
                                                'RM ${payment.priceList[index].toStringAsFixed(2)}',
                                                style: TextStyle(
                                                    fontSize:
                                                        getProportionateScreenHeight(
                                                            18),
                                                    fontWeight:
                                                        FontWeight.w600),
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
                      );
                    }
                  },
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.only(bottom: getProportionateScreenHeight(20)),
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
                                  fontSize: getProportionateScreenHeight(18)),
                            ),
                            Text(
                              'RM ${payment.subtotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: getProportionateScreenHeight(18)),
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
                                  fontSize: getProportionateScreenHeight(18)),
                            ),
                            Text(
                              'RM ${payment.estimatedTax.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: getProportionateScreenHeight(18)),
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
                                  fontSize: getProportionateScreenHeight(22),
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'RM ${payment.total.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: getProportionateScreenHeight(22),
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
      );
    }
  }
}
