import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:populargo/common/widgets/custom_button.dart';
import 'package:populargo/common/widgets/custom_textfield.dart';
import 'package:populargo/constants/global_variables.dart';
import 'package:populargo/constants/size_config.dart';
import 'package:populargo/features/auth/screens/auth_screen_opt.dart';

import '../services/auth_service.dart';

class ResetPwdScreen extends StatefulWidget {
  // define route name
  static const String routeName = '/resetPassword';
  const ResetPwdScreen({super.key});

  @override
  State<ResetPwdScreen> createState() => _ResetPwdScreenState();
}

class _ResetPwdScreenState extends State<ResetPwdScreen> {
  // global variable
  final _emailFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  var otpCode;


  // backend connection
  final AuthService authService = AuthService();

  void resetPwdEmail() {
    authService.resetPwdEmail(
      context: context, 
      email: _emailController.text,
      otpCode: otpCode,
      );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: GlobalVariables.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Forgot Password',
          style: TextStyle(
            fontWeight: FontWeight.w400,
          ),
        ),
        elevation: 0.0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: getProportionateScreenWidth(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: getProportionateScreenHeight(20),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Enter your email',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Form(
                    key: _emailFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: getProportionateScreenHeight(10),
                        ),
                        const Text(
                          'Don\'t worry, we can help.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(
                          height: getProportionateScreenHeight(20),
                        ),
                        CustomTextField(
                            controller: _emailController,
                            hintText: 'Email Address',
                            pwdObscureText: false),
                        SizedBox(
                          height: getProportionateScreenHeight(50),
                        ),
                        Center(
                          child: Container(
                            width: 300,
                            child: const Text(
                              'Enter the email address to get verification code to reset password',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: getProportionateScreenHeight(50),
                        ),
                        CustomButton(
                            text: 'Continue',
                            btnColor: const Color(0xFF00A86B),
                            textColor: Colors.white,
                            onTap: () {
                              if (_emailFormKey.currentState!.validate()) {
                                // create the otpcode
                                otpCode = GlobalVariables.randomOTP();
                                resetPwdEmail();
                              }
                            })
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// int randomOTP() {
//   var random = new Random();
//   var next = random.nextInt(9000) + 1000;

//   return next;
// }

