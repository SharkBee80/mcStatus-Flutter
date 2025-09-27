import 'package:hive/hive.dart';
import 'package:mcstatus/models/settings.dart';
import 'package:mcstatus/models/servers.dart';
import 'package:mcstatus/core/server.dart';

class SettingsController {
  static const String _settingsKey = 'app_settings';
  final Box<Settings> _settingsBox = Hive.box<Settings>('settings');
  final Server _serverController = Server();

  Settings? _cachedSettings; // 缓存设置对象

  /// 获取应用设置（安全版本）
  Settings getSettings() {
    try {
      _cachedSettings ??= _settingsBox.get(_settingsKey);

      // 如果获取失败或为null，返回默认设置
      if (_cachedSettings == null) {
        _cachedSettings = Settings();
        // 异步保存默认设置
        _saveDefaultSettingsAsync();
      }

      return _cachedSettings!;
    } catch (e) {
      // 如果出现错误（比如类型不匹配），清空数据库并返回默认设置
      print('读取设置失败，清空数据库: $e');
      _clearCorruptedData();
      _cachedSettings = Settings();
      _saveDefaultSettingsAsync();
      return _cachedSettings!;
    }
  }

  /// 异步保存默认设置
  void _saveDefaultSettingsAsync() {
    Future.microtask(() async {
      try {
        await saveSettings(_cachedSettings!);
      } catch (e) {
        print('保存默认设置失败: $e');
      }
    });
  }

  /// 清空损坏的数据
  void _clearCorruptedData() {
    try {
      _settingsBox.clear();
      _cachedSettings = null;
    } catch (e) {
      print('清空损坏数据失败: $e');
    }
  }

  /// 保存应用设置
  Future<void> saveSettings(Settings settings) async {
    try {
      await _settingsBox.put(_settingsKey, settings);
      _cachedSettings = settings;
    } catch (e) {
      rethrow;
    }
  }

  /// 更新部分设置
  Future<void> updateSettings({
    String? selectedServerUuid,
    bool? autoRefresh,
    int? refreshInterval,
    String? theme,
    String? language,
    bool? showServerIcon,
    int? cardColumns,
    int? connectionTimeout,
    bool? enableNotifications,
    bool? notifyServerOffline,
    bool? notifyPlayerCountChange,
    bool? enableDebugMode,
    bool? keepScreenOn,
    double? animationSpeed,
  }) async {
    final currentSettings = getSettings();
    final updatedSettings = currentSettings.copyWith(
      selectedServerUuid: selectedServerUuid,
      autoRefresh: autoRefresh,
      refreshInterval: refreshInterval,
      theme: theme,
      language: language,
      showServerIcon: showServerIcon,
      cardColumns: cardColumns,
      connectionTimeout: connectionTimeout,
      enableNotifications: enableNotifications,
      notifyServerOffline: notifyServerOffline,
      notifyPlayerCountChange: notifyPlayerCountChange,
      enableDebugMode: enableDebugMode,
      keepScreenOn: keepScreenOn,
      animationSpeed: animationSpeed,
    );
    await saveSettings(updatedSettings);
  }

  /// 重置所有设置为默认值
  Future<void> resetToDefaults({bool keepSelectedServer = true}) async {
    final settings = getSettings();
    settings.resetToDefaults(keepSelectedServer: keepSelectedServer);
    await saveSettings(settings);
  }

  /// 刷新缓存
  void refreshCache() {
    _cachedSettings = null;
  }

  // ==========================================================
  // 服务器相关设置方法
  // ==========================================================

  /// 设置当前选中的服务器
  Future<void> setSelectedServer(Servers? server) async {
    await updateSettings(selectedServerUuid: server?.uuid.toString());
  }

  /// 获取当前选中的服务器UUID
  String? getSelectedServerUuid() {
    return getSettings().selectedServerUuid;
  }

  /// 获取当前选中的服务器对象
  Servers? getSelectedServer() {
    final selectedUuid = getSelectedServerUuid();
    if (selectedUuid == null) return null;

    try {
      final servers = _serverController.loadServers();
      return servers.firstWhere(
        (server) => server.uuid.toString() == selectedUuid,
      );
    } catch (e) {
      // 如果找不到服务器，清空选中状态
      clearSelectedServer();
      return null;
    }
  }

  /// 清空当前选中的服务器
  Future<void> clearSelectedServer() async {
    await updateSettings(selectedServerUuid: null);
  }

  /// 检查选中的服务器是否存在，如果不存在则清空
  Future<void> validateSelectedServer() async {
    final selectedUuid = getSelectedServerUuid();
    if (selectedUuid == null) return;

    try {
      final servers = _serverController.loadServers();
      final exists = servers.any(
        (server) => server.uuid.toString() == selectedUuid,
      );

      if (!exists) {
        await clearSelectedServer();
      }
    } catch (e) {
      await clearSelectedServer();
    }
  }

  // ==========================================================
  // UI相关设置方法
  // ==========================================================

  /// 设置主题
  Future<void> setTheme(String theme) async {
    if (['light', 'dark', 'system'].contains(theme)) {
      await updateSettings(theme: theme);
    }
  }

  /// 获取主题
  String getTheme() {
    return getSettings().theme;
  }

  /// 设置语言
  Future<void> setLanguage(String language) async {
    if (['zh', 'en', 'system'].contains(language)) {
      await updateSettings(language: language);
    }
  }

  /// 获取语言
  String getLanguage() {
    return getSettings().language;
  }

  /// 设置卡片列数
  Future<void> setCardColumns(int columns) async {
    if (columns >= 1 && columns <= 4) {
      await updateSettings(cardColumns: columns);
    }
  }

  /// 获取卡片列数
  int getCardColumns() {
    return getSettings().cardColumns;
  }

  // ==========================================================
  // 服务器刷新相关设置方法
  // ==========================================================

  /// 设置自动刷新
  Future<void> setAutoRefresh(bool enabled) async {
    await updateSettings(autoRefresh: enabled);
  }

  /// 获取自动刷新状态
  bool getAutoRefresh() {
    return getSettings().autoRefresh;
  }

  /// 设置刷新间隔
  Future<void> setRefreshInterval(int seconds) async {
    if (seconds >= 5 && seconds <= 300) {
      // 5秒到5分钟
      await updateSettings(refreshInterval: seconds);
    }
  }

  /// 获取刷新间隔
  int getRefreshInterval() {
    return getSettings().refreshInterval;
  }

  /// 设置连接超时
  Future<void> setConnectionTimeout(int seconds) async {
    if (seconds >= 1 && seconds <= 30) {
      await updateSettings(connectionTimeout: seconds);
    }
  }

  /// 获取连接超时
  int getConnectionTimeout() {
    return getSettings().connectionTimeout;
  }

  // ==========================================================
  // 通知相关设置方法
  // ==========================================================

  /// 设置通知状态
  Future<void> setNotificationsEnabled(bool enabled) async {
    await updateSettings(enableNotifications: enabled);
  }

  /// 获取通知状态
  bool getNotificationsEnabled() {
    return getSettings().enableNotifications;
  }

  /// 设置服务器离线通知
  Future<void> setNotifyServerOffline(bool enabled) async {
    await updateSettings(notifyServerOffline: enabled);
  }

  /// 获取服务器离线通知状态
  bool getNotifyServerOffline() {
    return getSettings().notifyServerOffline;
  }

  /// 设置玩家数量变化通知
  Future<void> setNotifyPlayerCountChange(bool enabled) async {
    await updateSettings(notifyPlayerCountChange: enabled);
  }

  /// 获取玩家数量变化通知状态
  bool getNotifyPlayerCountChange() {
    return getSettings().notifyPlayerCountChange;
  }

  // ==========================================================
  // 高级设置方法
  // ==========================================================

  /// 设置调试模式
  Future<void> setDebugMode(bool enabled) async {
    await updateSettings(enableDebugMode: enabled);
  }

  /// 获取调试模式状态
  bool getDebugMode() {
    return getSettings().enableDebugMode;
  }

  /// 设置保持屏幕常亮
  Future<void> setKeepScreenOn(bool enabled) async {
    await updateSettings(keepScreenOn: enabled);
  }

  /// 获取保持屏幕常亮状态
  bool getKeepScreenOn() {
    return getSettings().keepScreenOn;
  }

  /// 设置动画速度
  Future<void> setAnimationSpeed(double speed) async {
    if (speed >= 0.1 && speed <= 3.0) {
      await updateSettings(animationSpeed: speed);
    }
  }

  /// 获取动画速度
  double getAnimationSpeed() {
    return getSettings().animationSpeed;
  }

  // ==========================================================
  // 其他实用方法
  // ==========================================================

  /// 获取设置的所有信息（为调试目的）
  Map<String, dynamic> getAllSettings() {
    return getSettings().toMap();
  }

  /// 检查是否为默认设置
  bool isDefaultSettings() {
    final current = getSettings();
    final defaults = Settings();

    return current.toMap().toString() == defaults.toMap().toString();
  }
}
