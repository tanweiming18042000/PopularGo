import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:populargo/constants/size_config.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../../models/book.dart';
import '../../models/payment.dart';
import '../../models/userVisit.dart';
import '../../providers/user_provider.dart';
import '../auth/services/auth_service.dart';
import 'components/receipt_details.dart';

class ReceiptScreen extends StatefulWidget {
  static const String routeName = '/receipt';
  const ReceiptScreen({super.key});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final AuthService authService = AuthService();
  List<UserVisit> userVisitList = [];
  List<String> userVisitIds = [];
  List<Payment> paymentList = [];
  String duration = '';

  @override
  void initState() {
    super.initState();
    runAllAwait();
  }

  Future<void> runAllAwait() async {
    userVisitList = await getAllUserVisit();
    userVisitIds = userVisitList.map((userVisit) => userVisit.id).toList();
    print('userVisitIds: $userVisitIds');
    paymentList = await getAllPayment(userVisitIds);
    print('payment list: $paymentList');
  }

  // get all the user visit
  Future<List<UserVisit>> getAllUserVisit() async {
    return await authService.getAllUserVisit(
        context: context,
        user_id: Provider.of<UserProvider>(context, listen: false).user.id);
  }

  // get all payment
  Future<List<Payment>> getAllPayment(List<String> userVisitIds) {
    return authService.getAllPayment(
        context: context, userVisitIds: userVisitIds);
  }

  Future<String> getUserVisitDuration(String userVisitId) {
    return authService.getUserVisitDuration(
      context: context,
      userVisit_id: userVisitId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Receipt'),
        ),
        body: FutureBuilder<List<UserVisit>>(
          future: getAllUserVisit(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('User Visit Error occurred'),
              );
            } else {
              userVisitList = snapshot.data ?? [];
              return FutureBuilder<void>(
                  future: runAllAwait(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Payment List Error occurred'),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: paymentList.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  top: getProportionateScreenHeight(20),
                                  left: getProportionateScreenWidth(14),
                                  bottom: getProportionateScreenHeight(10)),
                              child: Text(
                                'Purchases',
                                style: TextStyle(
                                  fontSize: getProportionateScreenHeight(20),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }
                          // UserVisit userVisit = userVisitList[index - 1];
                          Payment payment = paymentList[index - 1];
                          double paymentTotal = payment.total;

                          // Find the corresponding UserVisit using payment.userVisit_id
                          UserVisit? userVisit = userVisitList.firstWhereOrNull(
                            (userVisit) => userVisit.id == payment.userVisit_id,
                          );

                          if (userVisit == null) {
                            // Handle the case where the corresponding UserVisit is not found
                            return ListTile(
                              title: Text('No user visit data available'),
                            );
                          }

                          // Parse the end_datetime string manually
                          List<String> dateTimeParts =
                              userVisit.end_datetime.split(', ');
                          String datePart = dateTimeParts[0];
                          String timePart = dateTimeParts[1];

                          List<String> dateParts = datePart.split('/');
                          int month = int.parse(dateParts[0]);
                          int day = int.parse(dateParts[1]);
                          int year = int.parse(dateParts[2]);

                          List<String> timeParts = timePart.split(':');
                          int hour = int.parse(timeParts[0]);
                          int minute = int.parse(timeParts[1].split(' ')[0]);
                          int second = int.parse(timeParts[2].split(' ')[0]);
                          String meridian = timeParts[2].split(' ')[1];

                          if (meridian == 'PM') {
                            hour += 12;
                          }

                          // Construct the DateTime object
                          DateTime dateTime =
                              DateTime(year, month, day, hour, minute, second);

                          // Format the DateTime object
                          String formattedDate =
                              DateFormat('d MMMM y').format(dateTime);
                          String formattedTime =
                              DateFormat('h:mm a').format(dateTime);

                          return GestureDetector(
                            onTap: () async {
                              duration =
                                  await getUserVisitDuration(userVisit.id);
                              VisitPaymentData data = VisitPaymentData(
                                  userVisit,
                                  payment,
                                  formattedDate,
                                  formattedTime,
                                  duration);
                              Navigator.pushNamed(
                                  context, ReceiptDetails.routeName,
                                  arguments: data);
                            },
                            child: Card(
                              margin: EdgeInsets.all(0),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Colors.grey.withOpacity(0.3),
                                    width: 1.0),
                              ),
                              child: ListTile(
                                title: Text(
                                  formattedDate,
                                  style: TextStyle(
                                      fontSize:
                                          getProportionateScreenHeight(24),
                                      fontWeight: FontWeight.w500,
                                      color:
                                          Color.fromARGB(255, 105, 105, 105)),
                                ),
                                subtitle: Text(
                                  formattedTime,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                trailing: Text(
                                    'RM ${paymentTotal.toStringAsFixed(2)} >', // Assuming paymentTotal is of type double
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize:
                                            getProportionateScreenHeight(18),
                                        color: Color(0xFF59981A))),
                              ),
                            ),
                          );
                        },
                      );
                    }
                  });
            }
          },
        ));
  }
}

class VisitPaymentData {
  final UserVisit userVisit;
  final Payment payment;
  final String formattedDate;
  final String formattedTime;
  final String duration;

  VisitPaymentData(
    this.userVisit,
    this.payment,
    this.formattedDate,
    this.formattedTime,
    this.duration,
  );
}
