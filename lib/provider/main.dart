import 'package:flutter/material.dart';
import 'package:mcstatus/models/servers.dart';

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
  bool _isMovingMode = false; // 移动模式状态
  VoidCallback? _cancelMoveCallback; // 取消移动的回调
  final Map<int, VoidCallback> _refreshCallbacks = {}; // 各页面的刷新回调
  final Map<int, VoidCallback> _resetCallbackFlags = {}; // 各页面的重置回调标记
  Servers? _selectedServer; // 当前选中的服务器

  int get selectedIndex => _selectedIndex;
  PageController get pageController => _pageController;
  bool get isMovingMode => _isMovingMode;
  Servers? get selectedServer => _selectedServer;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  /// 设置选中的服务器并切换到info页面
  void setSelectedServer(Servers? server) {
    _selectedServer = server;
    if (server != null) {
      // 切换到info页面（索引 1）
      setSelectedIndex(1);
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    notifyListeners();
  }

  /// 设置移动模式
  void setMovingMode(bool isMoving, {VoidCallback? cancelCallback}) {
    _isMovingMode = isMoving;
    _cancelMoveCallback = cancelCallback;
    notifyListeners();
  }

  /// 设置刷新回调
  void setRefreshCallback(int pageIndex, VoidCallback? callback) {
    if (callback != null) {
      _refreshCallbacks[pageIndex] = callback;
    } else {
      _refreshCallbacks.remove(pageIndex);
      // 如果清除回调，通知对应页面重置注册标记
      if (_resetCallbackFlags.containsKey(pageIndex)) {
        _resetCallbackFlags[pageIndex]!();
      }
    }
    
    notifyListeners();
  }

  /// 设置重置注册标记的回调
  void setResetCallbackFlagCallback(int pageIndex, VoidCallback? callback) {
    if (callback != null) {
      _resetCallbackFlags[pageIndex] = callback;
    } else {
      _resetCallbackFlags.remove(pageIndex);
    }
  }

  /// 执行取消移动
  void cancelMove() {
    if (_cancelMoveCallback != null) {
      _cancelMoveCallback!();
    }
  }

  /// 执行刷新
  void refresh() {
    // 根据当前选中的页面执行对应的刷新回调
    if (_refreshCallbacks.containsKey(_selectedIndex)) {
      _refreshCallbacks[_selectedIndex]!();
    }
  }
}
