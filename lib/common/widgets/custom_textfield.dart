import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  // if password only set to true
  final bool pwdObscureText;
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.pwdObscureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          border: const OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.grey,
          )),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.grey,
          ))),
      style: const TextStyle(fontSize: 16),
      obscureText: pwdObscureText,
      validator: (val) {
        if(val == null || val.isEmpty) {
          return ('Enter your $hintText');
        }
        return null;
      },
    );
  }
}
