import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:populargo/common/widgets/custom_button.dart';
import 'package:populargo/constants/global_variables.dart';
import 'package:populargo/common/widgets/custom_textfield.dart';
import 'package:populargo/features/auth/screens/auth_screen_pwd.dart';
import 'package:populargo/features/auth/screens/auth_screen_signup.dart';
import 'package:populargo/features/auth/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  // define the route name
  static const String routeName = '/auth-screen';
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // global variable
  final _signInFormKey = GlobalKey<FormState>();
  bool _pwdObscure = true;
  bool _isChecked = false;

  // controller for sign in and sign up form
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();

  // backend connection
  final AuthService authService = AuthService();

  void signInUser() {
    authService.signInUser(
      context: context,
      email: _emailController.text,
      password: _pwdController.text,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _pwdController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Popular Sign In',
          style: TextStyle(
            fontWeight: FontWeight.w400,
          ),
        ),
        elevation: 0.0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      child: Text('Forgot password?', 
                      style: TextStyle(
                        color: Color(0xFF0080FE),
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                      ),
                      onTap: () {
                        // send an email or allow the user to change the password
                        Navigator.pushNamed(
                            context, ResetPwdScreen.routeName); 
                      },
                    ),
                  ],
                ),
                Form(
                  key: _signInFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'Email',
                        pwdObscureText: false,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextField(
                        controller: _pwdController,
                        hintText: 'Password',
                        pwdObscureText: _pwdObscure,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      PwdCheckBox(
                        label: 'Show Password',
                        value: _isChecked,
                        onChanged: (bool newValue) {
                          setState(() {
                            _isChecked = newValue;
                          });

                          if (_isChecked == true) {
                            _pwdObscure = false;
                          } else {
                            _pwdObscure = true;
                          }
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomButton(
                          text: 'Sign In',
                          btnColor: const Color(0xFF00A86B),
                          textColor: Colors.white,
                          onTap: () {
                            if (_signInFormKey.currentState!.validate()) {
                              signInUser();
                            }
                          }),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: const [
                          Expanded(
                              child: Divider(
                            thickness: 1,
                          )),
                          Text(
                            '  New to Popular?  ',
                            style: TextStyle(
                              color: Color(0xFF818181),
                              fontSize: 16,
                            ),
                          ),
                          Expanded(
                              child: Divider(
                            thickness: 1,
                          )),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomButton(
                          text: 'Create Account',
                          btnColor: const Color(0xFFE4E4E4),
                          textColor: Colors.black,
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(context,
                                AuthScreenSignUp.routeName, (route) => false);
                          }),
                      const SizedBox(height: 20),
                      const Text(
                        'By signing in you are agreeing to our Terms of Use, Conditions of Use and our Privacy Notice.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class for the customized checkbox with text
class PwdCheckBox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const PwdCheckBox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: (bool? newValue) {
            onChanged(newValue!);
          },
        ),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
