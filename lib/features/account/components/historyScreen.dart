import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';
import 'package:populargo/features/auth/services/auth_service.dart';
import 'package:provider/provider.dart';

import '../../../constants/size_config.dart';
import '../../../models/transactionHistory.dart';
import '../../../providers/user_provider.dart';

class HistoryScreen extends StatefulWidget {
  static const String routeName = '/account/transactionHistoryScreen';

  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final AuthService authService = AuthService();
  List<TransactionHistory> transactionList = [];

  @override
  void initState() {
    super.initState();
    runAllAwait();
  }

  Future<void> runAllAwait() async {
    List<TransactionHistory> list = await getAllTransactionHistory();
    setState(() {
      transactionList = list;
    });
    print('transactionList: $transactionList');
  }

  Future<List<TransactionHistory>> getAllTransactionHistory() async {
    return await authService.getAllTransactionHistory(
        context: context,
        user_id: Provider.of<UserProvider>(context, listen: false).user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Transaction History'),
      ),
      body: FutureBuilder<List<TransactionHistory>>(
        future: getAllTransactionHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error occurred'),
            );
          } else {
            return ListView.builder(
              itemCount: transactionList.length,
              itemBuilder: (context, index) {
                TransactionHistory transactionHistory = transactionList[index];
                double transactionAmount = transactionHistory.amount;
                DateTime dateTime =
                    DateTime.parse(transactionHistory.transaction_datetime).add(
                        Duration(
                            hours:
                                8)); // Add 8 hours to adjust to Malaysia time
                String formattedDate = DateFormat('d MMMM y').format(dateTime);
                String formattedTime = DateFormat('h:mm a').format(dateTime);

                String? transactionPrefix;
                Color? transactionColor;
                
                if (transactionHistory.transactionType == 'Deposit') {
                  transactionPrefix = '+ RM';
                  transactionColor = const Color(0xFF59981A);
                } else if (transactionHistory.transactionType == 'Pay') {
                  transactionPrefix = '- RM';
                  transactionColor = const Color(0xFFD22B2B);
                }

                return Card(
                  margin: EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1.0,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: getProportionateScreenHeight(24),
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 105, 105, 105),
                      ),
                    ),
                    subtitle: Text(
                      formattedTime,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: Text(
                      '$transactionPrefix ${transactionAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: getProportionateScreenHeight(18),
                        color: transactionColor,
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
