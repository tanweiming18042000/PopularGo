import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../../../../constants/global_variables.dart';
import '../../../../constants/size_config.dart';
import '../../../../models/ProductScan/scannedProduct.dart';
import '../../../../models/book.dart';
import '../../../../models/discount.dart';
import '../../../auth/services/auth_service.dart';
import 'discountReceiptCheckoutPage.dart';
import 'noDiscountReceiptCheckoutPage.dart';

class ChooseDiscountPage extends StatefulWidget {
  static const String routeName = '/chooseDiscountPage';
  const ChooseDiscountPage({super.key});

  @override
  State<ChooseDiscountPage> createState() => _ChooseDiscountPageState();
}

// 1) when the 'Use Now' button is pressed, go to the discountedReceiptCheckoutPage
// --> pass the scannedProduct, books, Discount object
// See the mustOverMaxPrice of discount, if is 'All', apply for all book contained in the reference
// else, take the mustOverMaxPrice and turn it to number, then that is the number of book that got discount
// when the CHECKOUT button is pressed, remember to update the UsedDiscount table
// only apply it to the max price book
// 2) when 'Proceed to Receipt' button is pressed, go to the noDiscountReceiptCheckoutPage
// --> pass scannedProduct, books
// for both page, if the either CHECKOUT or PLEASE RELOAD button is pressed, will delete rfid_id also

class _ChooseDiscountPageState extends State<ChooseDiscountPage> {
  // get the scannedProduct, books and discountIds from the payQRCOdeScreen
  final AuthService authService = AuthService();
  late ScannedProduct scannedProduct;
  late List<Book> books;
  List<String> discountIds = [];
  List<Discount> discountList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Access the passed arguments
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    scannedProduct = args['scannedProduct'];
    books = args['books'];
    discountIds = args['discountIds'];
    runAllAwait();
  }

  // get all the discount details with the discountIds
  Future<List<Discount>> getExitDiscountList() async {
    return await authService.getExitDiscountList(
        context: context, discountIds: discountIds);
  }

  Future<void> runAllAwait() async {
    discountList = await getExitDiscountList();
  }

  // delete the scannedProduct with scannedProduct.rfid_id
  Future<void> deleteOneScannedProduct(String rfid_id) async {
    await authService.deleteOneScannedProduct(
        context: context, rfid_id: rfid_id);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          deleteOneScannedProduct(scannedProduct.rfid_id);
          return true; // Allow the back navigation
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            title: Text('Voucher Box'),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height:
                            getProportionateScreenHeight(kToolbarHeight * 0.8),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: getProportionateScreenHeight(20),
                              ),
                              child: Text(
                                'AVAILABLE VOUCHER',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 105, 105, 105),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder<List<Discount>>(
                        future: getExitDiscountList(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<Discount>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error loading discounts'));
                          } else {
                            discountList = snapshot.data!;
                            return Container(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: discountList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final Discount discount = discountList[index];
                                  return Container(
                                    margin: EdgeInsets.only(
                                        top: getProportionateScreenHeight(8),
                                        bottom: getProportionateScreenHeight(8),
                                        left: getProportionateScreenWidth(16),
                                        right:
                                            getProportionateScreenHeight(16)),
                                    padding: EdgeInsets.only(
                                      top: getProportionateScreenHeight(16),
                                      left: getProportionateScreenWidth(16),
                                      right: getProportionateScreenWidth(16),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color.fromARGB(255, 60, 60, 60)
                                              .withOpacity(0.2),
                                          blurRadius: 3,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width:
                                                  getProportionateScreenWidth(
                                                      80),
                                              height:
                                                  getProportionateScreenHeight(
                                                      128),
                                              color: Color.fromARGB(
                                                  255, 227, 227, 227),
                                              child: Image.network(
                                                '$uri\\${discount.img}',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            SizedBox(
                                                width:
                                                    getProportionateScreenWidth(
                                                        20)),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    discount.title,
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        getProportionateScreenHeight(
                                                            10),
                                                  ),
                                                  Text(
                                                    discount.subtitle,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        getProportionateScreenHeight(
                                                            30),
                                                  ),
                                                  Text(
                                                    '* ${discount.mustOverMaxPrice} ${discount.mustOverMaxPrice == '1' ? 'book' : 'books'} that is in genre list',
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 105, 105, 105),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          thickness: 1,
                                          color: Colors.grey,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              discount.genre.length > 1
                                                  ? discount.genre.join(' . ')
                                                  : discount.genre.first,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 105, 105, 105),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                // Add your button click logic here
                                                // --> pass the scannedProduct, books, Discount object
                                                Navigator.pushNamed(
                                                  context,
                                                  DiscountReceiptCheckoutPage
                                                      .routeName,
                                                  arguments: {
                                                    'scannedProduct':
                                                        scannedProduct,
                                                    'books': books,
                                                    'discount': discount,
                                                  },
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color.fromARGB(
                                                    255, 255, 201, 192),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                minimumSize: Size(
                                                  getProportionateScreenWidth(
                                                      60),
                                                  getProportionateScreenHeight(
                                                      40),
                                                ),
                                              ),
                                              child: Text(
                                                'Use Now',
                                                style: TextStyle(
                                                  color: Color(0XFFda6a5a),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height:
                                              getProportionateScreenHeight(10),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        },
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
                        // go to noDiscountReceiptCheckoutPage.dart
                        Navigator.pushNamed(
                          context,
                          NoDiscountReceiptCheckoutPage.routeName,
                          arguments: {
                            'scannedProduct': scannedProduct,
                            'books': books,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Color(0xFF36454F),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'PROCEED TO RECEIPT',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
