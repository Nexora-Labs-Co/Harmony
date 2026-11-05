import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  String _name = 'Saaarmyx';

  String get name => _name;

  void setName(String name) {
    _name = name;
    notifyListeners();
  }
}
