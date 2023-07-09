import 'package:flutter/material.dart';
import 'package:populargo/constants/global_variables.dart';
import 'package:populargo/constants/size_config.dart';
import 'package:populargo/features/account/screens/account_screen.dart';
import 'package:populargo/features/home/screens/home_screens.dart';
import 'package:populargo/features/key/key_screen.dart';
import 'package:populargo/features/receipt/receipt_screen.dart';

import '../../features/wishlist/components/wishlist_body.dart';

class BottomBar extends StatefulWidget {
  static const String routeName = '/nav-bar';
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _page = 0;
  // double bottomBarWidth = getScreenWidth(0.25);
  double bottomBarTop = 5;
  String iconPath = 'lib/constants/icons';

// change the page when each tab is pressed
  List<Widget> pages = [
    const HomeScreen(),
    const WishlistBody(),
    const KeyScreen(),
    const ReceiptScreen(),
    const AccountScreen(),
  ];

  void updatePage(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: pages[_page],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _page,
        selectedItemColor: GlobalVariables.selectedNavBarColor,
        unselectedItemColor: GlobalVariables.unselectedNavBarColor,
        backgroundColor: Colors.white,
        // unselectedFontSize: _page.toDouble(), 
        // selectedFontSize: _page.toDouble(),
        type: BottomNavigationBarType.fixed,
        iconSize: getProportionateScreenWidth(30),
        onTap: updatePage,
        items: [
          BottomNavigationBarItem(
              icon: Container(
            width: getScreenWidth(0.1),
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
              color: _page == 0
                  ? GlobalVariables.selectedNavBarColor
                  : Colors.white,
              width: bottomBarTop,
            ))),
            child: Icon(Icons.book_outlined),
          ),
          label: 'Books',
          ),
          BottomNavigationBarItem(
              icon: Container(
            width: getScreenWidth(0.1),
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
              color: _page == 1
                  ? GlobalVariables.selectedNavBarColor
                  : Colors.white,
              width: bottomBarTop,
            ))),
            child: Icon(Icons.bookmark_outline),
          ),
          label: 'Wishlist',
          ),
          BottomNavigationBarItem(
              icon: Container(
            width: getScreenWidth(0.1),
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
              color: _page == 2
                  ? GlobalVariables.selectedNavBarColor
                  : Colors.white,
              width: bottomBarTop,
            ))),
            child: Icon(Icons.qr_code_scanner_outlined),
          ),
          label: 'Key',
          ),
          BottomNavigationBarItem(
              icon: Container(
            width: getScreenWidth(0.1),
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
              color: _page == 3
                  ? GlobalVariables.selectedNavBarColor
                  : Colors.white,
              width: bottomBarTop,
            ))),
            child: Icon(Icons.receipt_outlined),
          ),
          label: 'Receipt',
          ),
          BottomNavigationBarItem(
              icon: Container(
            width: getScreenWidth(0.1),
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
              color: _page == 4
                  ? GlobalVariables.selectedNavBarColor
                  : Colors.white,
              width: bottomBarTop,
            ))),
            child: Icon(Icons.account_circle_outlined),
          ),
          label: 'Account',
          ),
        ],
      ),
    );
  }
}
