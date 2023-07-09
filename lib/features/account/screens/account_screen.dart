import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:populargo/constants/global_variables.dart';
import 'package:populargo/constants/size_config.dart';
import 'package:populargo/features/account/components/changeUserName.dart';
import 'package:populargo/features/account/components/payQRCodeScreen.dart';
import 'package:populargo/features/account/components/validPwd.dart';
import 'package:provider/provider.dart';

import '../../../models/discount.dart';
import '../../../models/transactionHistory.dart';
import '../../../models/userBalance.dart';
import '../../../providers/user_provider.dart';
import '../../auth/services/auth_service.dart';
import '../components/depositScreen.dart';
import '../components/historyScreen.dart';

class AccountScreen extends StatefulWidget {
  static const String routeName = '/account';
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthService authService = AuthService();
  UserBalance userBalance = UserBalance(user_id: '', id: '', totalBalance: 0.0);
  double totalBalance = 0.0;
  int cash = 0;
  int pennies = 0;
  String penniesStr = '';
  var otpCode;
  List<String> usedDiscountIds = [];
  List<Discount> discountList = [];
  bool isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    print('hello');
    createUserBalance();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isDataLoaded) {
      runAllAwait().then((_) {
        print('All awaits completed');
        setState(() {
          isDataLoaded = true;
        });
      });
    }
  }

  Future<void> runAllAwait() async {
    userBalance = await getUserBalance();
    usedDiscountIds = await getAllUsedDiscountIds();
    discountList = await getDiscounts(usedDiscountIds);
    setState(() {
      totalBalance = userBalance.totalBalance;
      cash = totalBalance.toInt();
      pennies = ((totalBalance - cash) * 100).round();

      if(pennies < 10) {
        penniesStr = '0' + pennies.toString();
      } else {
        penniesStr = pennies.toString();
      }
    });
  }

  // post create the userBalance table with userid and total balance = 0.0
  Future<void> createUserBalance() async {
    await authService.createUserBalance(
      context: context,
      user_id: Provider.of<UserProvider>(context, listen: false).user.id,
    );
  }

  // get request to get total balance using user_id
  Future<UserBalance> getUserBalance() async {
    return await authService.getUserBalance(
        context: context,
        user_id: Provider.of<UserProvider>(context, listen: false).user.id);
  }

  // post to update the userBalance using the user_id
  // calculate the totalBalance then only pass into this API
  void updateUserBalance(double totalBalance) {
    authService.updateUserBalance(
        context: context,
        user_id: Provider.of<UserProvider>(context, listen: false).user.id,
        totalBalance: totalBalance);
  }

  // when pressed the Account Details(email), send OTP to the email
  // then go to auth_screen_otp.dart
  // the success, only allowed to change email address
  void resetPwdEmail() {
    authService.resetPwdEmail(
      context: context,
      email: Provider.of<UserProvider>(context, listen: false).user.email,
      otpCode: otpCode,
    );
  }

  void logout() {
    authService.logout(context);
  }

  // create transaction history (for Deposit button, Stripe payment done, set type == "Deposit")

  // get all usedDiscount discount_id list so that won't displayed if got used
  Future<List<String>> getAllUsedDiscountIds() async {
    return await authService.getAllUsedDiscountIds(
        context: context,
        user_id: Provider.of<UserProvider>(context, listen: false).user.id);
  }

  // get the discount object list with the used discount_id list
  Future<List<Discount>> getDiscounts(List<String> usedDiscountIds) async {
    if (usedDiscountIds.isEmpty) {
      usedDiscountIds = ['0'];
    }
    return await authService.getDiscounts(
        context: context, usedDiscountIds: usedDiscountIds);
  }

  @override
  Widget build(BuildContext context) {
    if (!isDataLoaded) {
      {}
      return Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        body: FutureBuilder<UserBalance>(
            future: getUserBalance(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error occurred'));
              } else {
                final userBalance = snapshot.data;
                final totalBalance = userBalance?.totalBalance ?? 0.0;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: getProportionateScreenHeight(370),
                          width: double.infinity,
                          color: GlobalVariables.secondaryColor,
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: getProportionateScreenHeight(50),
                                left: getProportionateScreenWidth(20),
                                right: getProportionateScreenWidth(20)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Hello, ${Provider.of<UserProvider>(context, listen: false).user.name.split(' ')[0]}',
                                      style: TextStyle(
                                        fontSize:
                                            getProportionateScreenHeight(30),
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.logout_rounded,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Logout'),
                                              content: Text(
                                                  'Are you sure you want to log out?'),
                                              actions: [
                                                TextButton(
                                                  child: Text('Cancel'),
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context); // Close the dialog
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text('Logout'),
                                                  onPressed: () {
                                                    // Perform logout operation here
                                                    logout();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: getProportionateScreenHeight(20),
                                ),
                                Container(
                                    height: getProportionateScreenHeight(110),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Color(0xFFA95C68)),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: getProportionateScreenHeight(20),
                                          left: getProportionateScreenWidth(20),
                                          right:
                                              getProportionateScreenWidth(20)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Total balance',
                                            style: TextStyle(
                                              fontSize:
                                                  getProportionateScreenHeight(
                                                      18),
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFFBEBEBE),
                                            ),
                                          ),
                                          SizedBox(
                                            height:
                                                getProportionateScreenHeight(
                                                    10),
                                          ),
                                          Text.rich(TextSpan(
                                              text: 'MYR $cash',
                                              style: TextStyle(
                                                  fontSize:
                                                      getProportionateScreenHeight(
                                                          30),
                                                  color: Color(0xFFFFFFFF),
                                                  fontWeight: FontWeight.bold),
                                              children: <InlineSpan>[
                                                if (pennies == 0)
                                                  TextSpan(
                                                    text: '.00',
                                                    style: TextStyle(
                                                      fontSize:
                                                          getProportionateScreenHeight(
                                                              20),
                                                      color: Color(0xFFFFFFFF),
                                                    ),
                                                  ),
                                                if (pennies > 0)
                                                  TextSpan(
                                                    text: '.$penniesStr',
                                                    style: TextStyle(
                                                      fontSize:
                                                          getProportionateScreenHeight(
                                                              20),
                                                      color: Color(0xFFFFFFFF),
                                                    ),
                                                  ),
                                              ])),
                                        ],
                                      ),
                                    )),
                                SizedBox(
                                  height: getProportionateScreenHeight(30),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: getProportionateScreenWidth(20),
                                      right: getProportionateScreenWidth(20)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          // Add your logic for the 'Deposit' button here
                                          Navigator.pushNamed(
                                              context, DepositScreen.routeName);
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add,
                                              size:
                                                  getProportionateScreenHeight(
                                                      50),
                                              color: Color(0xFFFFFFFF),
                                            ),
                                            SizedBox(
                                              height:
                                                  getProportionateScreenHeight(
                                                      5),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left:
                                                      getProportionateScreenWidth(
                                                          0)),
                                              child: Text(
                                                'Reload',
                                                style: TextStyle(
                                                  fontSize:
                                                      getProportionateScreenHeight(
                                                          16),
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFFFFFFFF),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          // Add your logic for the 'Pay' button here
                                          Navigator.pushNamed(context,
                                              PayQRCodeScreen.routeName,
                                              arguments: [cash, pennies]);
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.qr_code,
                                              size:
                                                  getProportionateScreenHeight(
                                                      50),
                                              color: Color(0xFFFFFFFF),
                                            ),
                                            SizedBox(
                                              height:
                                                  getProportionateScreenHeight(
                                                      5),
                                            ),
                                            Text(
                                              'Pay',
                                              style: TextStyle(
                                                fontSize:
                                                    getProportionateScreenHeight(
                                                        16),
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFFFFFFFF),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          // Add your logic for the 'History' button here
                                          Navigator.pushNamed(
                                              context, HistoryScreen.routeName);
                                        },
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.history,
                                              size:
                                                  getProportionateScreenHeight(
                                                      50),
                                              color: Color(0xFFFFFFFF),
                                            ),
                                            SizedBox(
                                              height:
                                                  getProportionateScreenHeight(
                                                      5),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left:
                                                      getProportionateScreenWidth(
                                                          6)),
                                              child: Text(
                                                'History',
                                                style: TextStyle(
                                                  fontSize:
                                                      getProportionateScreenHeight(
                                                          16),
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFFFFFFFF),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                top: getProportionateScreenHeight(20),
                                left: getProportionateScreenWidth(20),
                                right: getProportionateScreenWidth(20)),
                            child: Container(
                                child: Text(
                              'Account Details',
                              style: TextStyle(
                                  fontSize: getProportionateScreenHeight(24),
                                  fontWeight: FontWeight.bold),
                            )),
                          ),
                          SizedBox(
                            height: getProportionateScreenHeight(20),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                ChangeUserName.routeName,
                              );
                            },
                            child: Container(
                              height: getProportionateScreenHeight(70),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1.0,
                                    color: Colors.grey.withOpacity(0.7),
                                  ),
                                  color: Color(0xFFFFFFFF)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: getProportionateScreenHeight(10),
                                        bottom:
                                            getProportionateScreenHeight(10),
                                        left: getProportionateScreenWidth(20)),
                                    child: Container(
                                      height: getProportionateScreenHeight(50),
                                      width: getProportionateScreenHeight(50),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(
                                                'assets/account username.png'),
                                            fit: BoxFit.fitHeight),
                                        color: Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: getProportionateScreenWidth(20)),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Username',
                                        style: TextStyle(
                                          fontSize:
                                              getProportionateScreenHeight(22),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          right:
                                              getProportionateScreenWidth(20)),
                                      child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            '${Provider.of<UserProvider>(context, listen: false).user.name} >',
                                            style: TextStyle(
                                              fontSize:
                                                  getProportionateScreenHeight(
                                                      18),
                                              color: Color(0xFF757575),
                                            ),
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              otpCode = GlobalVariables.randomOTP();
                              resetPwdEmail();
                            },
                            child: Container(
                              height: getProportionateScreenHeight(70),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1.0,
                                    color: Colors.grey.withOpacity(0.7),
                                  ),
                                  color: Color(0xFFFFFFFF)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: getProportionateScreenHeight(10),
                                        bottom:
                                            getProportionateScreenHeight(10),
                                        left: getProportionateScreenWidth(20)),
                                    child: Container(
                                      height: getProportionateScreenHeight(50),
                                      width: getProportionateScreenHeight(50),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(
                                                'assets/account email.png'),
                                            fit: BoxFit.fitHeight),
                                        color: Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: getProportionateScreenWidth(20)),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Email',
                                        style: TextStyle(
                                          fontSize:
                                              getProportionateScreenHeight(22),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          right:
                                              getProportionateScreenWidth(20)),
                                      child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            maskEmail(Provider.of<UserProvider>(
                                                    context,
                                                    listen: false)
                                                .user
                                                .email),
                                            style: TextStyle(
                                              fontSize:
                                                  getProportionateScreenHeight(
                                                      18),
                                              color: Color(0xFF757575),
                                            ),
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // go to change password
                              Navigator.pushNamed(
                                context,
                                ValidPwd.routeName,
                              );
                            },
                            child: Container(
                              height: getProportionateScreenHeight(70),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1.0,
                                    color: Colors.grey.withOpacity(0.7),
                                  ),
                                  color: Color(0xFFFFFFFF)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: getProportionateScreenHeight(10),
                                        bottom:
                                            getProportionateScreenHeight(10),
                                        left: getProportionateScreenWidth(20)),
                                    child: Container(
                                      height: getProportionateScreenHeight(50),
                                      width: getProportionateScreenHeight(50),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                            image: AssetImage(
                                                'assets/account password.png'),
                                            fit: BoxFit.fitHeight),
                                        color: Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: getProportionateScreenWidth(20)),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Change Password',
                                        style: TextStyle(
                                          fontSize:
                                              getProportionateScreenHeight(22),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          right:
                                              getProportionateScreenWidth(20)),
                                      child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            '>',
                                            style: TextStyle(
                                              fontSize:
                                                  getProportionateScreenHeight(
                                                      18),
                                              color: Color(0xFF757575),
                                            ),
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                top: getProportionateScreenHeight(20),
                                left: getProportionateScreenWidth(20),
                                right: getProportionateScreenWidth(20)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Promo & Discount',
                                  style: TextStyle(
                                      fontSize:
                                          getProportionateScreenHeight(24),
                                      fontWeight: FontWeight.bold),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // go to see all the promotion and discount
                                  },
                                  child: Text(
                                    'See all',
                                    style: TextStyle(
                                      fontSize:
                                          getProportionateScreenHeight(18),
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFC41230),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: getProportionateScreenHeight(20),
                          ),
                          Container(
                            height: getProportionateScreenHeight(
                                180), // Adjust the height as needed
                            child: ListView.separated(
                              padding: EdgeInsets.symmetric(
                                horizontal: getProportionateScreenWidth(20),
                              ),
                              scrollDirection: Axis.horizontal,
                              itemCount: discountList.length,
                              separatorBuilder: (context, index) => SizedBox(
                                  width: getProportionateScreenWidth(10)),
                              itemBuilder: (context, index) {
                                final discount = discountList[index];
                                return Container(
                                  width: getProportionateScreenWidth(280),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.white, width: 1),
                                    image: DecorationImage(
                                      image:
                                          NetworkImage('$uri\\${discount.img}'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          discount.title,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          discount.subtitle,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: getProportionateScreenHeight(20),
                          )
                        ],
                      ),
                    ],
                  ),
                );
              }
            }),
      );
    }
  }
}

String maskEmail(String email) {
  if (email == null || email.isEmpty) {
    return '';
  }

  int atSignIndex = email.indexOf('@');
  if (atSignIndex <= 1) {
    // Email address is too short to be masked
    return email;
  }

  String maskedEmail = email.substring(0, 1) +
      ('x' * (atSignIndex - 1)) +
      email.substring(atSignIndex) + ' >';
  
  if (maskedEmail.length > 20) {
    maskedEmail = maskedEmail.substring(0, 20) + "... >";
  }
  return maskedEmail;
}
