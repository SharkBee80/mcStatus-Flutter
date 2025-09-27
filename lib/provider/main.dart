import 'package:flutter/material.dart';
import 'package:mcstatus/models/servers.dart';
import 'package:mcstatus/hive/settings.dart';

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
  final SettingsController _settingsController = SettingsController();

  int get selectedIndex => _selectedIndex;

  PageController get pageController => _pageController;

  bool get isMovingMode => _isMovingMode;

  Servers? get selectedServer => _selectedServer;

  /// 初始化Provider，加载保存的选中服务器
  Future<void> init() async {
    final savedServer = _settingsController.getSelectedServer();
    if (savedServer != null) {
      _selectedServer = savedServer;
      notifyListeners();
    }
  }

  /// 获取设置控制器（用于其他组件访问设置）
  SettingsController get settingsController => _settingsController;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  /// 设置选中的服务器并切换到info页面
  Future<void> setSelectedServer(Servers? server) async {
    _selectedServer = server;
    // 保存到Hive
    await _settingsController.setSelectedServer(server);

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

  /// 清空选中的服务器
  Future<void> clearSelectedServer() async {
    _selectedServer = null;
    await _settingsController.clearSelectedServer();
    notifyListeners();
  }

  /// 验证选中的服务器是否还存在
  Future<void> validateSelectedServer() async {
    await _settingsController.validateSelectedServer();
    final updatedServer = _settingsController.getSelectedServer();
    if (_selectedServer != updatedServer) {
      _selectedServer = updatedServer;
      notifyListeners();
    }
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
