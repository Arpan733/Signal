import 'package:flutter/foundation.dart';

class NameProvider extends ChangeNotifier {
  String _name = 'No Nearby Signal Found';
  String get name => _name;

  setName(String n) {
    if (n != _name) {
      if (n == '') {
        _name = 'No Nearby Signal Found';
        notifyListeners();
      } else {
        _name = n;
        notifyListeners();
      }
    }
  }
}
