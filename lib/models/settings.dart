import 'package:hive/hive.dart';

// flutter packages pub run build_runner build
part 'settings.g.dart'; // 自动生成文件

@HiveType(typeId: 1)
class Settings extends HiveObject {
  // 服务器相关设置
  @HiveField(0)
  String? selectedServerUuid; // 当前选中的服务器UUID

  @HiveField(1, defaultValue: false)
  bool autoRefresh; // 是否自动刷新服务器状态

  @HiveField(2, defaultValue: 30)
  int refreshInterval; // 自动刷新间隔（秒）

  // UI相关设置
  @HiveField(3, defaultValue: 'system')
  String theme; // 主题设置 (light/dark/system)

  @HiveField(4, defaultValue: 'system')
  String language; // 语言设置 (zh/en/system)

  @HiveField(5, defaultValue: true)
  bool showServerIcon; // 是否显示服务器图标

  @HiveField(6, defaultValue: 2)
  int cardColumns; // 卡片列数（1-4）

  // 网络相关设置
  @HiveField(7, defaultValue: 5)
  int connectionTimeout; // 连接超时时间（秒）

  @HiveField(8, defaultValue: true)
  bool enableNotifications; // 是否启用通知

  @HiveField(9, defaultValue: true)
  bool notifyServerOffline; // 服务器离线时通知

  @HiveField(10, defaultValue: false)
  bool notifyPlayerCountChange; // 玩家数量变化时通知

  // 高级设置
  @HiveField(11, defaultValue: false)
  bool enableDebugMode; // 调试模式

  @HiveField(12, defaultValue: false)
  bool keepScreenOn; // 保持屏幕常亮

  @HiveField(13, defaultValue: 1.0)
  double animationSpeed; // 动画速度倍率

  Settings({
    this.selectedServerUuid,
    this.autoRefresh = false,
    this.refreshInterval = 30,
    this.theme = 'system',
    this.language = 'system',
    this.showServerIcon = true,
    this.cardColumns = 2,
    this.connectionTimeout = 5,
    this.enableNotifications = true,
    this.notifyServerOffline = true,
    this.notifyPlayerCountChange = false,
    this.enableDebugMode = false,
    this.keepScreenOn = false,
    this.animationSpeed = 1.0,
  });

  /// 重置为默认设置（保留选中的服务器）
  void resetToDefaults({bool keepSelectedServer = true}) {
    final currentSelectedServer = keepSelectedServer
        ? selectedServerUuid
        : null;

    selectedServerUuid = currentSelectedServer;
    autoRefresh = false;
    refreshInterval = 30;
    theme = 'system';
    language = 'system';
    showServerIcon = true;
    cardColumns = 2;
    connectionTimeout = 5;
    enableNotifications = true;
    notifyServerOffline = true;
    notifyPlayerCountChange = false;
    enableDebugMode = false;
    keepScreenOn = false;
    animationSpeed = 1.0;
  }

  /// 复制当前设置并可选择性修改某些字段
  Settings copyWith({
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
  }) {
    return Settings(
      selectedServerUuid: selectedServerUuid ?? this.selectedServerUuid,
      autoRefresh: autoRefresh ?? this.autoRefresh,
      refreshInterval: refreshInterval ?? this.refreshInterval,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      showServerIcon: showServerIcon ?? this.showServerIcon,
      cardColumns: cardColumns ?? this.cardColumns,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      notifyServerOffline: notifyServerOffline ?? this.notifyServerOffline,
      notifyPlayerCountChange:
          notifyPlayerCountChange ?? this.notifyPlayerCountChange,
      enableDebugMode: enableDebugMode ?? this.enableDebugMode,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      animationSpeed: animationSpeed ?? this.animationSpeed,
    );
  }

  /// 转换为Map用于调试
  Map<String, dynamic> toMap() {
    return {
      'selectedServerUuid': selectedServerUuid,
      'autoRefresh': autoRefresh,
      'refreshInterval': refreshInterval,
      'theme': theme,
      'language': language,
      'showServerIcon': showServerIcon,
      'cardColumns': cardColumns,
      'connectionTimeout': connectionTimeout,
      'enableNotifications': enableNotifications,
      'notifyServerOffline': notifyServerOffline,
      'notifyPlayerCountChange': notifyPlayerCountChange,
      'enableDebugMode': enableDebugMode,
      'keepScreenOn': keepScreenOn,
      'animationSpeed': animationSpeed,
    };
  }
}
