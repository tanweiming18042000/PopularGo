import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:populargo/features/account/components/changeUserPwd.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/custom_button.dart';
import '../../../constants/size_config.dart';
import '../../../providers/user_provider.dart';
import '../../auth/services/auth_service.dart';

class ValidPwd extends StatefulWidget {
  static const String routeName = '/account/ValidPwd';
  const ValidPwd({super.key});

  @override
  State<ValidPwd> createState() => _ValidPwdState();
}

class _ValidPwdState extends State<ValidPwd> {
  final AuthService authService = AuthService();
  final GlobalKey<FormState> _validPwdFormKey = GlobalKey<FormState>();
  final TextEditingController _validPwdController = TextEditingController();
  bool? _isValidUserPwd;
  final FocusNode _validPwdFocusNode = FocusNode();

  String? validateUserPwd(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
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

  void validUserPwd() {
    authService.validUserPwd(
        context: context,
        email: Provider.of<UserProvider>(context, listen: false).user.email,
        password: _validPwdController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Validate Password'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(getProportionateScreenHeight(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter Current Password',
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
                      errorText: _isValidUserPwd == false &&
                              _validPwdController.text.isNotEmpty
                          ? 'Please enter a valid password'
                          : null,
                    ),
                    validator: validateUserPwd,
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
                    if (_validPwdFormKey.currentState!.validate()) {
                      validUserPwd();
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
