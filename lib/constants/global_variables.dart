import 'dart:math';

import 'package:flutter/material.dart';

// for url
String uri = 'http://192.168.0.6:3000';

class GlobalVariables {
  // COLORS
  static const appBarGradient = LinearGradient(
    colors: [
      Color.fromARGB(255, 29, 201, 192),
      Color.fromARGB(255, 125, 221, 216),
    ],
    stops: [0.5, 1.0],
  );

  static const secondaryColor = Color(0xFF9B0E27);
  static var backgroundColor = Colors.grey[100];
  static const Color greyBackgroundColor = Color(0xffebecee);
  static const selectedNavBarColor = Color(0xFF9B0E27);
  static const unselectedNavBarColor = Color.fromARGB(255, 163, 163, 163);
  static const selectedTopBarColor = Colors.white;
  static const unselectedTopBarColor = Color(0xFF8D8D8D);

  // grey text style
  final subtextStyle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.grey,
  );

  static int randomOTP() {
    var random = new Random();
    var next = random.nextInt(9000) + 1000;

    return next;
  }
}
