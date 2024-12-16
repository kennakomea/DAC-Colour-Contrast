import 'package:flutter/cupertino.dart';

import 'enums/enums.dart';

class AppProvider extends ChangeNotifier {
  AppView _currentView = AppView.home;
  bool _isEyeDropperVisible = false;

  AppView get currentView => _currentView;
  bool get isEyeDropperVisible => _isEyeDropperVisible;

  void setCurrentView(AppView view) {
    _currentView = view;
    notifyListeners();
  }

  set isEyeDropperVisible(bool value) {
    _isEyeDropperVisible = value;
    notifyListeners();
    debugPrint('isEyeDropperVisible: $_isEyeDropperVisible');
  }
}
