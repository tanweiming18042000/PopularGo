import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:populargo/constants/error_handling.dart';
import 'package:populargo/constants/utils.dart';
import 'package:populargo/features/auth/screens/auth_screen.dart';
import 'package:populargo/features/auth/screens/auth_screen_opt.dart';
import 'package:populargo/features/auth/screens/auth_screen_reset_pwd.dart';
import 'package:populargo/features/home/screens/home_screens.dart';
import 'package:populargo/models/qrKey.dart';
import 'package:populargo/models/transactionHistory.dart';
import 'package:populargo/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:populargo/constants/global_variables.dart';
import 'package:populargo/models/userBalance.dart';
import 'package:populargo/models/userVisit.dart';
import 'package:populargo/models/wishlist.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common/widgets/bottom_bar.dart';
import '../../../models/ProductScan/scannedProduct.dart';
import '../../../models/book.dart';
import '../../../models/discount.dart';
import '../../../models/payment.dart';
import '../../../models/paymentQRKey.dart';
import '../../../models/reUserClickedBooks.dart';
import '../../../models/usedDiscount.dart';
import '../../../models/userClickedBooks.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/otp_provider.dart';
import '../../account/components/changeEmail.dart';
import '../../account/components/changeUserPwd.dart';
import '../../account/screens/account_screen.dart';

// contain all the logic (separate from UI)
class AuthService {
  // sign up user
  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      User user = User(
        id: '',
        name: name,
        email: email,
        password: password,
        address: '',
        token: '',
      );

      http.Response res = await http.post(
        Uri.parse('$uri/api/signup'),
        body: user.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(
              context, 'Account Created! Login with the same credentials!');
          Navigator.pushNamedAndRemoveUntil(
              context, AuthScreen.routeName, (route) => false);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // sign in user
  void signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/signin'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          // to access user information everywhere
          SharedPreferences prefs = await SharedPreferences.getInstance();
          Provider.of<UserProvider>(context, listen: false).setUser(res.body);
          await prefs.setString('userToken', jsonDecode(res.body)['token']);
          Navigator.pushNamedAndRemoveUntil(
              context, BottomBar.routeName, (route) => false);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // get user data
  void getUserData({
    required BuildContext context,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('userToken');

      // user use application as the first time
      if (token == null) {
        prefs.setString('userToken', '');
      }

      var tokenRes = await http.post(
        Uri.parse('$uri/tokenIsValid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'userToken': token!
        },
      );

      var response = jsonDecode(tokenRes.body);

      if (response == true) {
        // get the user data
        http.Response userRes = await http.get(
          Uri.parse('$uri/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'userToken': token
          },
        );

        var userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(userRes.body);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // reset password email
  void resetPwdEmail({
    required BuildContext context,
    required String email,
    required int otpCode,
  }) async {
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/resetPwdEmail'),
        body: jsonEncode({
          'email': email,
          'otpCode': otpCode,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () async {
            // send to OTP page\
            Provider.of<OTPProvider>(context, listen: false).setEmail(email);
            Provider.of<OTPProvider>(context, listen: false).setOTP(otpCode);
            Navigator.pushNamed(context, ResetOTPScreen.routeName);
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void resetValidOTP({
    required BuildContext context,
    required int otpCode,
    required String pin1,
    required String pin2,
    required String pin3,
    required String pin4,
  }) async {
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/resetValidOTP'),
        body: jsonEncode({
          'otpCode': otpCode,
          'pin1': pin1,
          'pin2': pin2,
          'pin3': pin3,
          'pin4': pin4,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () async {
            // if the user provider.name is not '', then go to reset email screen
            // else send to reset password page
            if (Provider.of<UserProvider>(context, listen: false).user.name ==
                '') {
              Navigator.pushNamed(context, ResetFinalPwdScreen.routeName);
            } else {
              Navigator.pushNamed(context, ChangeUserEmail.routeName);
            }
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // reset OTP page OTP
  void resetOTP({
    required BuildContext context,
    required String email,
    required int otpCode,
  }) async {
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/resetPwdEmail'),
        body: jsonEncode({
          'email': email,
          'otpCode': otpCode,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () async {
            // change the OTP code of the current page
            // set provider for the email and the OTP
            // refresh the OTP page and set the email and password to
            // provider ones
            Provider.of<OTPProvider>(context, listen: false).setEmail(email);
            Provider.of<OTPProvider>(context, listen: false).setOTP(otpCode);
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // reset the user password
  void resetUserPwd({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/resetUserPwd'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () async {
            // go to a reset successful page
            final scaffold = ScaffoldMessenger.of(context);

            // Show the success message using a SnackBar wrapped with Center
            scaffold.showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Center(
                  child: Container(
                    color: Colors.grey[800], // Dark grey color
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Password reset successfully',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            );

            // Delay navigating to another page using a Timer
            Timer(Duration(seconds: 3), () {
              // Navigate to the other page
              Navigator.pushNamedAndRemoveUntil(
                  context, AuthScreen.routeName, (route) => false);
            });
          });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // log out
  void logout(BuildContext context) async {
    try {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.setString('userToken', '');
      User user = User(
        id: '',
        name: '',
        email: '',
        password: '',
        address: '',
        token: '',
      );
      Provider.of<UserProvider>(context, listen: false).setAddress('');
      Navigator.pushNamedAndRemoveUntil(
          context, AuthScreen.routeName, (route) => false);
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // retrieve reference book data from the database based on the Navigation-Categories
  Future<List<Book>> getBooks(
      {required BuildContext context, required String genre}) async {
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/retrieveBook/$genre'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (res.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(res.body);
        final books = jsonData.map((json) => Book.fromJson(json)).toList();
        return books;
      } else {
        throw Exception('Request failed with status: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }

// get one book with specific id
  Future<Book> getOneBook({
    required BuildContext context,
    required String bookId,
  }) async {
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/retrieveOneBook/$bookId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (res.statusCode == 200) {
        final dynamic jsonData = jsonDecode(res.body);
        final book = Book.fromJson(jsonData);
        return book;
      } else {
        return Book(
          id: '',
          img: '',
          title: '',
          authName: '',
          genre: [],
          price: 0,
          pageNum: 0,
          description: '',
        );
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }

// to create a wishlist with quantity of 1 (user_id, book_id, quantity, price)
  Future<void> createWishlist({
    required BuildContext context,
    required String user_id,
    required String book_id,
    required int quantity,
    required double price,
  }) async {
    try {
      Wishlist wishlist = Wishlist(
        id: '',
        user_id: user_id,
        book_id: book_id,
        quantity: quantity,
        price: price,
      );

      http.Response res = await http.post(
        Uri.parse('$uri/api/createWishlist'),
        body: jsonEncode(wishlist.toJson()),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // showSnackBar(context, 'Wishlist created!');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

// delete the wishlist item (user_id)
  Future<void> deleteOneWishlist({
    required BuildContext context,
    required String user_id,
    required String book_id,
  }) async {
    try {
      Wishlist wishlist = Wishlist(
        id: '',
        user_id: user_id,
        book_id: book_id,
        price: 0,
        quantity: 0,
      );

      http.Response res = await http.post(
        Uri.parse('$uri/api/deleteOneWishlist'),
        body: jsonEncode(wishlist.toJson()),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // showSnackBar(context, 'Wishlist deleted!');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

// delete multiple wishlist at once
  Future<void> deleteMultipleWishlist({
    required BuildContext context,
    required String user_id,
    required List<String> book_ids,
  }) async {
    try {
      Map<String, dynamic> requestBody = {
        'user_id': user_id,
        'book_ids': book_ids,
      };

      http.Response res = await http.post(
        Uri.parse('$uri/api/deleteOneWishlist'),
        body: jsonEncode(requestBody),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Multiple Wishlist deleted!');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

// get all wishlist item (user_id)
  Future<List<Wishlist>> getAllWishlist(
      {required BuildContext context, required String user_id}) async {
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/getAllWishlist/$user_id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (res.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(res.body);
        final wishlistItems =
            jsonData.map((json) => Wishlist.fromJson(json)).toList();
        return wishlistItems;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }

// get the specific wishlist item (book_id, user_id)
  Future<Wishlist> getOneWishlist(
      {required BuildContext context,
      required String user_id,
      required String book_id}) async {
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/getOneWishlist/$user_id/$book_id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (res.statusCode == 200) {
        final dynamic jsonData = jsonDecode(res.body);
        final wishlistItem = Wishlist.fromJson(jsonData);
        return wishlistItem;
      } else {
        return Wishlist(
          id: '',
          user_id: '',
          book_id: '',
          quantity: 0,
          price: 0,
        );
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }

  // get the latest user visit in duration (String)
  Future<String> getLatestDuration({
    required BuildContext context,
    required String user_id,
  }) async {
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/getLatestDuration/$user_id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (res.statusCode == 200) {
        final dynamic jsonData = jsonDecode(res.body);
        final String durationString = jsonData['duration'];
        return durationString;
      } else {
        return '';
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }

// create user QR
// prevent others from getting the String, then can get into Popular as the user
// then steal stuff, give black list for the victim user
// 2nd point, to prevent stealer from getting to know the user's id, which
// can be used to accessed the victim user's information
  Future<void> createQRKey({
    required BuildContext context,
    required String user_id,
    required String qrStr,
  }) async {
    try {
      QRKey qrKey = QRKey(
        id: '',
        user_id: user_id,
        qrStr: qrStr,
      );

      http.Response res = await http.post(
        Uri.parse('$uri/api/createQRKey'),
        body: jsonEncode(qrKey.toJson()),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // showSnackBar(context, 'Wishlist created!');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

// get the user QR (get request)
  Future<QRKey> getQRKey({
    required BuildContext context,
    required String user_id,
  }) async {
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/getQRKey/$user_id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (res.statusCode == 200) {
        final dynamic jsonData = jsonDecode(res.body);
        final qrKeyItem = QRKey.fromJson(jsonData);
        return qrKeyItem;
      } else {
        return QRKey(
          id: '',
          user_id: '',
          qrStr: '',
        );
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }

// get all userVisit
  Future<List<UserVisit>> getAllUserVisit(
      {required BuildContext context, required String user_id}) async {
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/getAllUserVisit/$user_id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (res.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(res.body);
        final userVisitItems =
            jsonData.map((json) => UserVisit.fromJson(json)).toList();
        return userVisitItems;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }

// get payment details with userVisitIds list
  Future<List<Payment>> getAllPayment(
      {required BuildContext context,
      required List<String> userVisitIds}) async {
    try {
      final String userVisitIdsParam = userVisitIds.join(',');

      http.Response res = await http.get(
        Uri.parse('$uri/api/getPayments/$userVisitIdsParam'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (res.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(res.body);
        final paymentItems =
            jsonData.map((json) => Payment.fromJson(json)).toList();
        return paymentItems;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }

// get the duration for specific user visit
  Future<String> getUserVisitDuration({
    required BuildContext context,
    required String userVisit_id,
  }) async {
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/getUserVisitDuration/$userVisit_id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (res.statusCode == 200) {
        final dynamic jsonData = jsonDecode(res.body);
        final String durationString = jsonData['duration'];
        return durationString;
      } else {
        return '';
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }

// when at Receipt detail page, use bookIds list
// get the book details list
  Future<List<Book>> getAllPaidBooks(
      {required BuildContext context, required List<String> bookIds}) async {
    try {
      final String bookIdsParam = bookIds.join(',');

      http.Response res = await http.get(
        Uri.parse('$uri/api/getBooks/$bookIdsParam'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (res.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(res.body);
        final bookItems = jsonData.map((json) => Book.fromJson(json)).toList();
        return bookItems;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }

// check if there is the user_id, if no create one, else, return
  Future<void> createUserBalance({
    required BuildContext context,
    required String user_id,
  }) async {
    try {
      UserBalance userBalance = UserBalance(
        id: '',
        user_id: user_id,
        totalBalance: 0.0,
      );

      http.Response res = await http.post(
        Uri.parse('$uri/api/createUserBalance'),
        body: jsonEncode(userBalance.toJson()),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // showSnackBar(context, 'New user balance created!');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

// get request to get total balance using user_id
  Future<UserBalance> getUserBalance({
    required BuildContext context,
    required String user_id,
  }) async {
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/getUserBalance/$user_id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (res.statusCode == 200) {
        final dynamic jsonData = jsonDecode(res.body);
        final userBalanceItem = UserBalance.fromJson(jsonData);
        return userBalanceItem;
      } else {
        return UserBalance(id: '', user_id: '', totalBalance: 0);
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }

// post to update the userBalance using the user_id
// calculate the totalBalance then only pass into this API
  Future<void> updateUserBalance({
    required BuildContext context,
    required String user_id,
    required double totalBalance,
  }) async {
    try {
      UserBalance userBalance = UserBalance(
        id: '',
        user_id: user_id,
        totalBalance: totalBalance,
      );

      http.Response res = await http.post(
        Uri.parse('$uri/api/updateUserBalance'),
        body: jsonEncode(userBalance.toJson()),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // showSnackBar(context, 'User balance updated!');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

// create PaymentQRKey
  Future<void> createPaymentQRKey({
    required BuildContext context,
    required String user_id,
    required String qrStr,
  }) async {
    try {
      PaymentQRKey paymentQRKey = PaymentQRKey(
        id: '',
        user_id: user_id,
        qrStr: qrStr,
      );

      http.Response res = await http.post(
        Uri.parse('$uri/api/createPaymentQRKey'),
        body: jsonEncode(paymentQRKey.toJson()),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // showSnackBar(context, 'Wishlist created!');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

// get the paymentQR (get request)
  Future<PaymentQRKey> getPaymentQRKey({
    required BuildContext context,
    required String user_id,
  }) async {
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/getPaymentQRKey/$user_id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (res.statusCode == 200) {
        final dynamic jsonData = jsonDecode(res.body);
        final paymentQRKeyItem = PaymentQRKey.fromJson(jsonData);
        return paymentQRKeyItem;
      } else {
        return PaymentQRKey(
          id: '',
          user_id: '',
          qrStr: '',
        );
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }

// update user name
  Future<void> updateUserName({
    required BuildContext context,
    required String user_id,
    required String name,
  }) async {
    try {
      Map<String, dynamic> requestBody = {
        'user_id': user_id,
        'name': name,
      };

      http.Response res = await http.post(
        Uri.parse('$uri/api/updateUserName'),
        body: jsonEncode(requestBody),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          Provider.of<UserProvider>(context, listen: false).setName(name);
          Navigator.pushNamedAndRemoveUntil(
            context,
            BottomBar.routeName,
            (route) =>
                false, // Pass the desired initial page number as an argument (3 in this case)
          );
          // showSnackBar(context, 'User name updated!');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

// update user email
  Future<void> updateUserEmail({
    required BuildContext context,
    required String user_id,
    required String email,
  }) async {
    try {
      Map<String, dynamic> requestBody = {
        'user_id': user_id,
        'email': email,
      };

      http.Response res = await http.post(
        Uri.parse('$uri/api/updateUserEmail'),
        body: jsonEncode(requestBody),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          Provider.of<UserProvider>(context, listen: false).setEmail(email);
          Navigator.pushNamedAndRemoveUntil(
            context,
            BottomBar.routeName,
            (route) =>
                false, // Pass the desired initial page number as an argument (3 in this case)
          );
          // showSnackBar(context, 'User name updated!');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

// update user pwd
  Future<void> updateUserPwd({
    required BuildContext context,
    required String user_id,
    required String password,
  }) async {
    try {
      Map<String, dynamic> requestBody = {
        'user_id': user_id,
        'password': password,
      };

      http.Response res = await http.post(
        Uri.parse('$uri/api/updateUserPwd'),
        body: jsonEncode(requestBody),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          Provider.of<UserProvider>(context, listen: false)
              .setPassword(password);
          Navigator.pushNamedAndRemoveUntil(
            context,
            BottomBar.routeName,
            (route) =>
                false, // Pass the desired initial page number as an argument (3 in this case)
          );
          // showSnackBar(context, 'User name updated!');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

// validate user pwd
  Future<void> validUserPwd({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      Map<String, dynamic> requestBody = {
        'email': email,
        'password': password,
      };

      http.Response res = await http.post(
        Uri.parse('$uri/api/validPwd'),
        body: jsonEncode(requestBody),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          Navigator.pushNamed(context, ChangeUserPwd.routeName);
          // showSnackBar(context, 'User name updated!');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

// when press the Deposit button, from hand phone run this funcction
// if got scanned for Pay button, from scanner, run this function
// create the transaction history, transaction type : "Deposit" / "Pay"
  Future<void> createTransactionHistory({
    required BuildContext context,
    required String user_id,
    required double amount,
    required String transactionType,
  }) async {
    try {
      TransactionHistory transactionHistory = TransactionHistory(
        id: '',
        user_id: user_id,
        transaction_datetime: '',
        amount: amount,
        transactionType: transactionType,
      );

      http.Response res = await http.post(
        Uri.parse('$uri/api/createTransactionHistory'),
        body: jsonEncode(transactionHistory.toJson()),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // showSnackBar(context, 'Wishlist created!');
          Navigator.pushNamedAndRemoveUntil(
            context,
            BottomBar.routeName,
            (route) =>
                false, // Pass the desired initial page number as an argument (3 in this case)
          );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

// when pressed the history button, run this (if the type is deposit, then show + and green, else - and red)
// when get the transaction history, arrange the date in descending order
  Future<List<TransactionHistory>> getAllTransactionHistory(
      {required BuildContext context, required String user_id}) async {
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/getTransactionHistory/$user_id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (res.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(res.body);
        final TransactionHistoryItems =
            jsonData.map((json) => TransactionHistory.fromJson(json)).toList();
        return TransactionHistoryItems;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }

// get the usedDiscount list of Discountid based on the userid
  Future<List<String>> getAllUsedDiscountIds(
      {required BuildContext context, required String user_id}) async {
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/getAllUsedDiscount/$user_id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (res.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(res.body);
        final List<String> discountIds = List<String>.from(jsonData);
        return discountIds;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }

// input the list of discountid,
// get the discount, only get the discount that is not in the list
  Future<List<Discount>> getDiscounts({
    required BuildContext context,
    required List<String> usedDiscountIds,
  }) async {
    try {
      final String discountIds = usedDiscountIds.join(',');
      // print('do not want discount id: $discountIds');
      final Uri url = Uri.parse('$uri/api/retrieveDiscount/$discountIds');
      // print('Request URI: $url');
      http.Response res = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      // print('Response Status Code: ${res.statusCode}');
      // print('Response Body: ${res.body}');

      if (res.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(res.body);
        final discounts = jsonData
            .map((json) => Discount.fromJson(json as Map<String, dynamic>))
            .toList();
        return discounts;
      } else {
        throw Exception('Request failed with status: ${res.statusCode}');
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }

// in payment, use user_id to get userVisit start_datetime
// where end_datetime = ''
  Future<String> getExitUserVisitStartDate({
    required BuildContext context,
    required String user_id,
  }) async {
    try {
      http.Response res = await http.get(
        Uri.parse('$uri/api/getExitUserVisitStartDate/$user_id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (res.statusCode == 200) {
        final dynamic jsonData = jsonDecode(res.body);
        final String startDatetime = jsonData['start_datetime'];
        return startDatetime;
      } else {
        return '';
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }

  // body: user_id
  // during exit, update the end_datetime and duration
  Future<void> createExitUserVisit({
    required BuildContext context,
    required String user_id,
    required String start_datetime,
  }) async {
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/createExitUserVisit'),
        body: jsonEncode({
          'user_id': user_id,
          'start_datetime': start_datetime,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Visit endDate updated!');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

// get the on going userVisit id (already enter but haven't exit)
  Future<String> getExitUserVisitId({
    required BuildContext context,
    required String user_id,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$uri/api/getExitUserVisitId/$user_id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final dynamic jsonData = jsonDecode(response.body);
        final String userVisitId = jsonData['userVisit_id'] as String;
        return userVisitId;
      } else {
        return '';
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }

  // get the discount list when Exit
  Future<List<Discount>> getExitDiscountList(
      {required BuildContext context,
      required List<String> discountIds}) async {
    try {
      final String discountIdsString = discountIds.join(",");
      http.Response res = await http.get(
        Uri.parse('$uri/api/getExitDiscountList/$discountIdsString'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (res.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(res.body);
        final discountList =
            jsonData.map((json) => Discount.fromJson(json)).toList();
        return discountList;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }

  // create a new payment
  Future<void> createPayment({
    required BuildContext context,
    required String userVisit_id,
    required List<String> bookIdList,
    required List<int> quantityList,
    required List<double> priceList,
    required double subtotal,
    required double estimatedTax,
    required double total,
  }) async {
    try {
      Payment payment = Payment(
          userVisit_id: userVisit_id,
          id: '',
          bookIdList: bookIdList,
          quantityList: quantityList,
          priceList: priceList,
          subtotal: subtotal,
          estimatedTax: estimatedTax,
          total: total,
          status: 'paid');

      http.Response res = await http.post(
        Uri.parse('$uri/api/createPayment'),
        body: jsonEncode(payment.toJson()),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // showSnackBar(context, 'Wishlist created!');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // create exit transaciton history
  Future<void> createExitTransactionHistory({
    required BuildContext context,
    required String user_id,
    required double amount,
    required String transactionType,
  }) async {
    try {
      TransactionHistory transactionHistory = TransactionHistory(
        id: '',
        user_id: user_id,
        transaction_datetime: '',
        amount: amount,
        transactionType: transactionType,
      );

      http.Response res = await http.post(
        Uri.parse('$uri/api/createTransactionHistory'),
        body: jsonEncode(transactionHistory.toJson()),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // showSnackBar(context, 'Wishlist created!');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // during the exit
  // parameter = rfid_id
  // use the rfid_id to get a ScannedProduct object
  Future<ScannedProduct> getOneScannedProduct({
    required BuildContext context,
    required String rfid_id,
  }) async {
    try {
      final http.Response res = await http.get(
        Uri.parse('$uri/api/getOneScannedProduct/$rfid_id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print('Response status code: ${res.statusCode}');
      print('Response body: ${res.body}');

      if (res.statusCode == 200) {
        final dynamic jsonData = jsonDecode(res.body);
        print('Decoded JSON data: $jsonData');

        final scannedProduct = ScannedProduct.fromJson(jsonData);
        print('Scanned Product Subtotal: ${scannedProduct.subtotal}');
        print('Scanned Product Estimated Tax: ${scannedProduct.estimatedTax}');
        print('Scanned Product Total: ${scannedProduct.total}');

        return scannedProduct;
      } else {
        return ScannedProduct(
            bookIdList: [],
            rfid_id: '',
            estimatedTax: 0,
            id: '',
            priceList: [],
            quantityList: [],
            subtotal: 0,
            total: 0);
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }

  // create the UsedDiscount when use the discount
  Future<void> createUsedDiscount({
    required BuildContext context,
    required String user_id,
    required String discount_id,
  }) async {
    try {
      UsedDiscount usedDiscount =
          UsedDiscount(user_id: user_id, id: '', discount_id: discount_id);

      http.Response res = await http.post(
        Uri.parse('$uri/api/createUsedDiscount'),
        body: jsonEncode(usedDiscount.toJson()),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // showSnackBar(context, 'Wishlist created!');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // delete scannedProduct with rfid_id
  Future<void> deleteOneScannedProduct({
    required BuildContext context,
    required String rfid_id,
  }) async {
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/deleteOneScannedProduct'),
        body: jsonEncode({
          'rfid_id': rfid_id,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // showSnackBar(context, 'Wishlist deleted!');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

// during exit, delete the wishlist item based on the user_id, bookIdList, quantityList
  Future<void> updateExitWishlistItem({
    required BuildContext context,
    required String user_id,
    required List<String> bookIdList,
    required List<int> quantityList,
  }) async {
    try {
      Map<String, dynamic> requestBody = {
        'user_id': user_id,
        'bookIdList': bookIdList,
        'quantityList': quantityList,
      };

      http.Response res = await http.post(
        Uri.parse('$uri/api/updateExitWishlistItem'),
        body: jsonEncode(requestBody),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          // showSnackBar(context, 'User name updated!');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

// get the userClickedBooks based on user_id
  Future<ReUserClickedBooks> getUserClickedBooks({
    required BuildContext context,
    required String user_id,
  }) async {
    try {
      final http.Response res = await http.get(
        Uri.parse('$uri/api/getUserClickedBooks/$user_id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (res.statusCode == 200) {
        final dynamic jsonData = jsonDecode(res.body);
        if (jsonData is List) {
          if (jsonData.isEmpty) {
            // Handle empty list response
            return ReUserClickedBooks(
              id: '',
              genreList: [],
              clicked_datetime: [],
              userId: '',
            );
          } else {
            final userClickedBooksData = jsonData.first;
            final userClickedBooks =
                ReUserClickedBooks.fromJson(userClickedBooksData);
            return userClickedBooks;
          }
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to get user clicked books');
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }

// recommendation page
// take in a list of genre
// find from book table where the book is in the genre
// return the book list
  Future<List<Book>> retrieveRecommendBookList({
    required BuildContext context,
    required List<String> genreList,
  }) async {
    try {
      final String genreListString = genreList.join(',');
      final http.Response res = await http.get(
        Uri.parse('$uri/api/retrieveRecommendBookList/$genreListString'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (res.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(res.body);
        final books = jsonData.map((json) => Book.fromJson(json)).toList();
        return books;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Exception occurred: $e');
    }
  }
}

// pass email and otp to otp screen
class PassEmailOTP {
  final String email;
  final int otp;

  PassEmailOTP(this.email, this.otp);
}
