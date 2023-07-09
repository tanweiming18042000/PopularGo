import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:populargo/providers/otp_provider.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/custom_button.dart';
import '../../../constants/global_variables.dart';
import '../../../constants/size_config.dart';
import '../../../providers/user_provider.dart';
import '../services/auth_service.dart';

class ResetFinalPwdScreen extends StatefulWidget {
  static const String routeName = '/resetFinalPassword';
  const ResetFinalPwdScreen({super.key});

  @override
  State<ResetFinalPwdScreen> createState() => _ResetFinalPwdScreenState();
}

class _ResetFinalPwdScreenState extends State<ResetFinalPwdScreen> {
// email can be access from Provider.of<OTPProvider>(context, listen: false).setEmail(email)
  final AuthService authService = AuthService();
  final GlobalKey<FormState> _validPwdFormKey = GlobalKey<FormState>();
  final TextEditingController _validPwdController = TextEditingController();
  bool? _isValidUserPwd;
  final FocusNode _validPwdFocusNode = FocusNode();

  String? validateUserPwd(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  @override
  void dispose() {
    _validPwdController.dispose();
    _validPwdFocusNode.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_validPwdFocusNode.hasFocus) {
      // Keyboard is open, so close it
      FocusManager.instance.primaryFocus?.unfocus();
      return false; // Prevent navigation
    } else {
      return true; // Allow navigation
    }
  }

  void resetUserPwd() {
    authService.resetUserPwd(
        context: context,
        email: Provider.of<OTPProvider>(context, listen: false).email,
        password: _validPwdController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Reset Password'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(getProportionateScreenHeight(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter New Password',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: getProportionateScreenHeight(30),
                ),
                Form(
                  key: _validPwdFormKey,
                  child: TextFormField(
                    controller: _validPwdController,
                    focusNode: _validPwdFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Enter password',
                      // errorText: _isValidUserPwd == false &&
                      //         _validPwdController.text.isNotEmpty
                      //     ? ''
                      //     : null,
                    ),
                    validator: validateUserPwd,
                  ),
                ),
                SizedBox(
                  height: getProportionateScreenHeight(50),
                ),
                CustomButton(
                  text: 'Confirm',
                  btnColor: const Color(0xFF00A86B),
                  textColor: Colors.white,
                  onTap: () {
                    if (_validPwdFormKey.currentState!.validate()) {
                      resetUserPwd();
                    } else {
                      setState(() {
                        _isValidUserPwd = false;
                      });
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
