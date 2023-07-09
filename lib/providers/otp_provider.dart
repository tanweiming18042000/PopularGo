import 'package:flutter/material.dart';

class OTPProvider extends ChangeNotifier {
  String _email = '';
  int _otpCode = 0;
  bool _timerDone = false;

  String get email => _email;
  int get otpCode => _otpCode;
  bool get timerDone => _timerDone;

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setOTP(int otpCode) {
    _otpCode = otpCode;
    notifyListeners();
  }

  void setTimerDone(bool timerDone) {
    _timerDone = timerDone;
    notifyListeners();
  }
}