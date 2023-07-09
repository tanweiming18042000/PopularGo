import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/custom_button.dart';
import '../../../constants/size_config.dart';
import '../../../models/userBalance.dart';
import '../../../providers/user_provider.dart';
import '../../auth/services/auth_service.dart';

class DepositScreen extends StatefulWidget {
  static const String routeName = '/account/depositScreen';
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final AuthService authService = AuthService();
  final GlobalKey<FormState> _depositFormKey = GlobalKey<FormState>();
  final TextEditingController _depositController = TextEditingController();
  bool _isInvalidDeposit = false;
  final FocusNode _depositFocusNode = FocusNode();
  double newTotalBalance = 0;
  late UserBalance userBalance;

  @override
  void initState() {
    super.initState();
    runAllAwait();
    initializeNotificationChannels();
  }

  Future<void> runAllAwait() async {
    userBalance = await getUserBalance();
    newTotalBalance = userBalance.totalBalance;
  }

// get the user balance
  Future<UserBalance> getUserBalance() async {
    return await authService.getUserBalance(
        context: context,
        user_id: Provider.of<UserProvider>(context, listen: false).user.id);
  }

  Future<void> createTransactionHistory(double amount) async {
    await authService.createTransactionHistory(
        context: context,
        user_id: Provider.of<UserProvider>(context, listen: false).user.id,
        amount: amount,
        transactionType: 'Deposit');
  }

// update userBalance in database
  Future<void> updateUserBalance(double totalBalance) async {
    await authService.updateUserBalance(
        context: context,
        user_id: Provider.of<UserProvider>(context, listen: false).user.id,
        totalBalance: totalBalance);
  }

  String? validateDeposit(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a number';
    }

    final numericValue = double.tryParse(value);
    if (numericValue == null || numericValue < 10) {
      return 'Please reload over RM 10';
    }

    return null;
  }

  @override
  void dispose() {
    _depositController.dispose();
    _depositFocusNode.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_depositFocusNode.hasFocus) {
      // Keyboard is open, so close it
      FocusManager.instance.primaryFocus?.unfocus();
      return false; // Prevent navigation
    } else {
      return true; // Allow navigation
    }
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

  triggerNotification(double reloadTotal) {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 10,
            channelKey: 'basic_channel',
            title: 'Reload Successful',
            body: 'You have reload RM ${reloadTotal}'));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Reload'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(getProportionateScreenHeight(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter Amount',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: getProportionateScreenHeight(30),
                ),
                Form(
                  key: _depositFormKey,
                  child: TextFormField(
                    controller: _depositController,
                    focusNode: _depositFocusNode,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: _depositFocusNode.hasFocus
                          ? ''
                          : 'Min. reload amount is RM 10',
                      errorText:
                          _isInvalidDeposit ? 'Please reload over RM 10' : null,
                      prefix:
                          Text('RM ', style: TextStyle(color: Colors.black)),
                    ),
                    style:
                        TextStyle(fontSize: getProportionateScreenHeight(28)),
                    validator: validateDeposit,
                    onTap: () {
                      setState(() {
                        _isInvalidDeposit = false;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: getProportionateScreenHeight(50),
                ),
                CustomButton(
                  text: 'Confirm',
                  btnColor: const Color(0xFF00A86B),
                  textColor: Colors.white,
                  onTap: () async {
                    setState(() {
                      _isInvalidDeposit = false;
                    });
                    if (_depositFormKey.currentState!.validate()) {
                      final double depositAmount =
                          double.parse(_depositController.text);
                      if (depositAmount >= 10) {
                        setState(() {
                          _isInvalidDeposit = false;
                          newTotalBalance += depositAmount;
                        });
                        // Update the userBalance in the database
                        await updateUserBalance(newTotalBalance);
                        // Create the transaction history
                        await createTransactionHistory(depositAmount);
                        triggerNotification(depositAmount);
                      } else {
                        setState(() {
                          _isInvalidDeposit = true;
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
