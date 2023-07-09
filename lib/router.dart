import 'package:flutter/material.dart';
import 'package:populargo/features/account/components/payQRCodeScreen.dart';
import 'package:populargo/features/auth/screens/auth_screen.dart';
import 'package:populargo/features/auth/screens/auth_screen_opt.dart';
import 'package:populargo/features/auth/screens/auth_screen_pwd.dart';
import 'package:populargo/features/auth/screens/auth_screen_reset_pwd.dart';
import 'package:populargo/features/auth/screens/auth_screen_signup.dart';
import 'package:populargo/features/home/components/book_details.dart';
import 'package:populargo/features/receipt/receipt_screen.dart';

import 'common/widgets/bottom_bar.dart';
import 'features/account/components/changeEmail.dart';
import 'features/account/components/changeUserName.dart';
import 'features/account/components/changeUserPwd.dart';
import 'features/account/components/depositScreen.dart';
import 'features/account/components/exitPage/chooseDiscountPage.dart';
import 'features/account/components/exitPage/discountReceiptCheckoutPage.dart';
import 'features/account/components/exitPage/noDiscountReceiptCheckoutPage.dart';
import 'features/account/components/exitPage/noPurchasePage.dart';
import 'features/account/components/exitPage/paymentSuccessPage.dart';
import 'features/account/components/exitPage/receipt_checkout.dart';
import 'features/account/components/historyScreen.dart';
import 'features/account/components/validPwd.dart';
import 'features/account/screens/account_screen.dart';
import 'features/home/components/recommendationPage.dart';
import 'features/home/screens/home_screens.dart';
import 'features/key/key_screen.dart';
import 'features/receipt/components/receipt_details.dart';
import 'features/wishlist/components/wishlist_body.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case AuthScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AuthScreen(),
      );
    case AuthScreenSignUp.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AuthScreenSignUp(),
      );
    case HomeScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const HomeScreen(),
      );
    case RecommendationPage.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const RecommendationPage(),
      );
    case WishlistBody.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const WishlistBody(),
      );
    case KeyScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const KeyScreen(),
      );
    case ReceiptScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ReceiptScreen(),
      );
    case ReceiptDetails.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ReceiptDetails(),
      );
    case AccountScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const AccountScreen(),
      );
    case PayQRCodeScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const PayQRCodeScreen(),
      );
    case NoPurchasePage.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const NoPurchasePage(),
      );
    case ReceiptCheckoutPage.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ReceiptCheckoutPage(),
      );
    case PaymentSuccessPage.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const PaymentSuccessPage(),
      );
    case ChooseDiscountPage.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ChooseDiscountPage(),
      );
    case DiscountReceiptCheckoutPage.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const DiscountReceiptCheckoutPage(),
      );
    case NoDiscountReceiptCheckoutPage.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const NoDiscountReceiptCheckoutPage(),
      );
    case ChangeUserName.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ChangeUserName(),
      );
    case ChangeUserEmail.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ChangeUserEmail(),
      );
    case ValidPwd.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ValidPwd(),
      );
    case ChangeUserPwd.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ChangeUserPwd(),
      );
    case HistoryScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const HistoryScreen(),
      );
    case DepositScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const DepositScreen(),
      );
    case BottomBar.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const BottomBar(),
      );
    case BookDetails.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const BookDetails(),
      );
    case ResetPwdScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ResetPwdScreen(),
      );
    case ResetOTPScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ResetOTPScreen(),
      );
    case ResetFinalPwdScreen.routeName:
      return MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const ResetFinalPwdScreen(),
      );
    default:
      return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const Scaffold(
                body: Center(
                  child: Text('Screen does not exist'),
                ),
              ));
  }
}
