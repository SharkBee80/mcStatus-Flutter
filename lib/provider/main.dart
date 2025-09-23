import 'package:flutter/material.dart';

class Counter with ChangeNotifier {
  int _counter = 0;

  int get counter => _counter;

  void increment() {
    _counter++;
    notifyListeners();
  }
}

class PageViewProvider with ChangeNotifier {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  int get selectedIndex => _selectedIndex;

  PageController get pageController => _pageController;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
