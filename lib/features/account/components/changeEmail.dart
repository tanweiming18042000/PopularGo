import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/custom_button.dart';
import '../../../constants/size_config.dart';
import '../../../providers/user_provider.dart';
import '../../auth/services/auth_service.dart';

class ChangeUserEmail extends StatefulWidget {
  static const String routeName = '/account/ChangeUserEmail';
  const ChangeUserEmail({super.key});

  @override
  State<ChangeUserEmail> createState() => _ChangeUserEmailState();
}

class _ChangeUserEmailState extends State<ChangeUserEmail> {
  final AuthService authService = AuthService();
  final GlobalKey<FormState> _chgUserEmailFormKey = GlobalKey<FormState>();
  final TextEditingController _userEmailController = TextEditingController();
  bool _isInvalidUserEmail = false;
  final FocusNode _userEmailFocusNode = FocusNode();

  void updateUserEmail() {
    authService.updateUserEmail(
      context: context,
      user_id: Provider.of<UserProvider>(context, listen: false).user.id,
      email: _userEmailController.text.trim(),
    );
  }

  String? validateUserEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    if (value == Provider.of<UserProvider>(context, listen: false).user.email) {
      return 'Please enter a different email';
    }
    return null;
  }

  @override
  void dispose() {
    _userEmailController.dispose();
    _userEmailFocusNode.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_userEmailFocusNode.hasFocus) {
      // Keyboard is open, so close it
      FocusManager.instance.primaryFocus?.unfocus();
      return false; // Prevent navigation
    } else {
      return true; // Allow navigation
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Change Email'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(getProportionateScreenHeight(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Email',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: getProportionateScreenHeight(30),
                ),
                Form(
                  key: _chgUserEmailFormKey,
                  child: TextFormField(
                    controller: _userEmailController,
                    focusNode: _userEmailFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Enter your new email',
                      errorText: _isInvalidUserEmail
                          ? 'Please enter a valid email'
                          : null,
                    ),
                    validator: validateUserEmail,
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
                    setState(() {
                      _isInvalidUserEmail = false;
                    });
                    if (_chgUserEmailFormKey.currentState!.validate()) {
                      if (_userEmailController.text ==
                          Provider.of<UserProvider>(context, listen: false)
                              .user
                              .name) {
                        setState(() {
                          _isInvalidUserEmail = true;
                        });
                      } else {
                        updateUserEmail();
                      }
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