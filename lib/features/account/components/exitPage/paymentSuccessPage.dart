
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../../../../common/widgets/bottom_bar.dart';
import '../../../../constants/size_config.dart';

class PaymentSuccessPage extends StatefulWidget {
  static const String routeName = '/paymentSuccessPage';
  const PaymentSuccessPage({super.key});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding:
            EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: getProportionateScreenHeight(20)),
              child: Text(
                'Payment Success',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(10)),
            Text(
              'Transferred',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            Expanded(child: Container()),
            Padding(
              padding:
                  EdgeInsets.only(bottom: getProportionateScreenHeight(30)),
              child: ElevatedButton(
                onPressed: () {
                  // Perform actions when the "Done" button is pressed
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    BottomBar.routeName,
                    (route) =>
                        false, // Pass the desired initial page number as an argument (3 in this case)
                  );
                },
                child: Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}