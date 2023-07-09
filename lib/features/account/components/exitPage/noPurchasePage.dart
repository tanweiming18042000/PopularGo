import 'package:flutter/material.dart';
import 'package:populargo/constants/size_config.dart';

import '../../../../common/widgets/bottom_bar.dart';

class NoPurchasePage extends StatefulWidget {
  static const String routeName = '/noPurchasePage';
  const NoPurchasePage({super.key});

  @override
  State<NoPurchasePage> createState() => _NoPurchasePageState();
}

class _NoPurchasePageState extends State<NoPurchasePage> {
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
                'Thank you for coming',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: getProportionateScreenHeight(10)),
            Text(
              'See you next time',
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
