import 'package:flutter/material.dart';

import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user =
      User(
        id: '', 
        name: '', 
        email: '', 
        password: '', 
        address: '', 
        token: '',
      );

    User get user => _user;

    // to update user
    void setUser(String user) {
      _user = User.fromJson(user);
      notifyListeners();
    }


  // Update user's name
  void setName(String newName) {
    _user.name = newName;
    notifyListeners();
  }

  // Update user's email
  void setEmail(String newEmail) {
    _user.email = newEmail;
    notifyListeners();
  }

  // Update user's password
  void setPassword(String newPassword) {
    _user.password = newPassword;
    notifyListeners();
  }

  // Update user's address
  void setAddress(String newAddress) {
    _user.address = newAddress;
    notifyListeners();
  }
}