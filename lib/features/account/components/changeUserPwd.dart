import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/custom_button.dart';
import '../../../constants/size_config.dart';
import '../../../providers/user_provider.dart';
import '../../auth/services/auth_service.dart';

class ChangeUserPwd extends StatefulWidget {
  static const String routeName = '/account/ChangeUserPwd';
  const ChangeUserPwd({super.key});

  @override
  State<ChangeUserPwd> createState() => _ChangeUserPwdState();
}

class _ChangeUserPwdState extends State<ChangeUserPwd> {
  final AuthService authService = AuthService();
  final GlobalKey<FormState> _chgUserPwdFormKey = GlobalKey<FormState>();
  final TextEditingController _chgUserPwdController = TextEditingController();
  bool? _isValidUserPwd;
  final FocusNode _chgUserPwdFocusNode = FocusNode();

  String? validateUserPwd(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    return null;
  }

  @override
  void dispose() {
    _chgUserPwdController.dispose();
    _chgUserPwdFocusNode.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_chgUserPwdFocusNode.hasFocus) {
      // Keyboard is open, so close it
      FocusManager.instance.primaryFocus?.unfocus();
      return false; // Prevent navigation
    } else {
      return true; // Allow navigation
    }
  }

  void updateUserPwd() {
    authService.updateUserPwd(
      context: context,
      user_id: Provider.of<UserProvider>(context, listen: false).user.id,
      password: _chgUserPwdController.text.trim(),
    );
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Change Password'),
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
                  key: _chgUserPwdFormKey,
                  child: TextFormField(
                    controller: _chgUserPwdController,
                    focusNode: _chgUserPwdFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Enter password',
                      errorText: _isValidUserPwd == false &&
                              _chgUserPwdController.text.isNotEmpty
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
                  text: 'Confirm',
                  btnColor: const Color(0xFF00A86B),
                  textColor: Colors.white,
                  onTap: () {
                    if (_chgUserPwdFormKey.currentState!.validate()) {
                      updateUserPwd();
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