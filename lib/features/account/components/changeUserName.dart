import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:populargo/common/widgets/custom_textfield.dart';
import 'package:populargo/constants/size_config.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/custom_button.dart';
import '../../../providers/user_provider.dart';
import '../../auth/services/auth_service.dart';

class ChangeUserName extends StatefulWidget {
  static const String routeName = '/account/ChangeUserName';

  const ChangeUserName({Key? key}) : super(key: key);

  @override
  State<ChangeUserName> createState() => _ChangeUserNameState();
}

class _ChangeUserNameState extends State<ChangeUserName> {
  final AuthService authService = AuthService();
  final GlobalKey<FormState> _chgUserNameFormKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  bool _isInvalidUsername = false;
  final FocusNode _usernameFocusNode = FocusNode();

  void updateUserName() {
    authService.updateUserName(
      context: context,
      user_id: Provider.of<UserProvider>(context, listen: false).user.id,
      name: _usernameController.text.trim(),
    );
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }
    if (value == Provider.of<UserProvider>(context, listen: false).user.name) {
      return 'Please enter a different username';
    }
    return null;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_usernameFocusNode.hasFocus) {
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
          title: Text('Change Username'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(getProportionateScreenHeight(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Username',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: getProportionateScreenHeight(30),
                ),
                Form(
                  key: _chgUserNameFormKey,
                  child: TextFormField(
                    controller: _usernameController,
                    focusNode: _usernameFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Enter your new username',
                      errorText: _isInvalidUsername
                          ? 'Please enter a valid username'
                          : null,
                    ),
                    validator: validateUsername,
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
                      _isInvalidUsername = false;
                    });
                    if (_chgUserNameFormKey.currentState!.validate()) {
                      if (_usernameController.text ==
                          Provider.of<UserProvider>(context, listen: false)
                              .user
                              .name) {
                        setState(() {
                          _isInvalidUsername = true;
                        });
                      } else {
                        updateUserName();
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
