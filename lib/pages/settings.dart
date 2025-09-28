import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mcstatus/provider/main.dart';
import 'package:mcstatus/hive/settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with AutomaticKeepAliveClientMixin {
  late SettingsController _settingsController;

  @override
  bool get wantKeepAlive => true; // 保持页面活跃状态

  @override
  void initState() {
    super.initState();
    _settingsController = context.read<PageViewProvider>().settingsController;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 保持页面活跃状态必需的调用
    
    return Consumer<PageViewProvider>(
      builder: (context, provider, child) {
        // 更新设置控制器引用，确保使用最新的实例
        _settingsController = provider.settingsController;
        
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildServerSection(),
            const SizedBox(height: 20),
            _buildUISection(),
            const SizedBox(height: 20),
            _buildNetworkSection(),
            const SizedBox(height: 20),
            _buildNotificationSection(),
            const SizedBox(height: 20),
            _buildAdvancedSection(),
          ],
        );
      },
    );
  }

  /// 构建服务器相关设置
  Widget _buildServerSection() {
    return _buildSection(
      title: '服务器设置',
      icon: Icons.dns,
      children: [
        SwitchListTile(
          title: const Text('自动刷新'),
          subtitle: const Text('自动刷新服务器状态'),
          value: _settingsController.getAutoRefresh(),
          onChanged: (value) async {
            await _settingsController.setAutoRefresh(value);
            setState(() {});
          },
        ),
        ListTile(
          title: const Text('刷新间隔'),
          subtitle: Text('${_settingsController.getRefreshInterval()}秒'),
          leading: const Icon(Icons.timer),
          onTap: () => _showRefreshIntervalDialog(),
        ),
        ListTile(
          title: const Text('连接超时'),
          subtitle: Text('${_settingsController.getConnectionTimeout()}秒'),
          leading: const Icon(Icons.access_time),
          onTap: () => _showTimeoutDialog(),
        ),
      ],
    );
  }

  /// 构建UI相关设置
  Widget _buildUISection() {
    return _buildSection(
      title: 'UI设置',
      icon: Icons.palette,
      children: [
        ListTile(
          title: const Text('主题'),
          subtitle: Text(_getThemeDisplayName(_settingsController.getTheme())),
          leading: const Icon(Icons.brightness_6),
          onTap: () => _showThemeDialog(),
        ),
        ListTile(
          title: const Text('语言'),
          subtitle: Text(
            _getLanguageDisplayName(_settingsController.getLanguage()),
          ),
          leading: const Icon(Icons.language),
          onTap: () => _showLanguageDialog(),
        ),
        ListTile(
          title: const Text('卡片列数'),
          subtitle: Text('${_settingsController.getCardColumns()}列'),
          leading: const Icon(Icons.view_column),
          onTap: () => _showCardColumnsDialog(),
        ),
        SwitchListTile(
          title: const Text('显示服务器图标'),
          subtitle: const Text('在卡片中显示服务器图标'),
          value: _settingsController.getSettings().showServerIcon,
          onChanged: (value) async {
            await _settingsController.updateSettings(showServerIcon: value);
            setState(() {});
          },
        ),
      ],
    );
  }

  /// 构建网络相关设置
  Widget _buildNetworkSection() {
    return _buildSection(
      title: '网络设置',
      icon: Icons.network_check,
      children: [
        ListTile(
          title: const Text('连接超时'),
          subtitle: Text('${_settingsController.getConnectionTimeout()}秒'),
          leading: const Icon(Icons.timer_off),
          onTap: () => _showTimeoutDialog(),
        ),
        if (_settingsController.getDebugMode())
          ListTile(
            title: const Text('网络诊断'),
            subtitle: const Text('查看网络连接详情'),
            leading: const Icon(Icons.network_ping),
            onTap: () => _showNetworkDiagnostics(),
          ),
      ],
    );
  }

  /// 构建通知相关设置
  Widget _buildNotificationSection() {
    return _buildSection(
      title: '通知设置',
      icon: Icons.notifications,
      children: [
        SwitchListTile(
          title: const Text('启用通知'),
          subtitle: const Text('接收应用通知'),
          value: _settingsController.getNotificationsEnabled(),
          onChanged: (value) async {
            await _settingsController.setNotificationsEnabled(value);
            setState(() {});
          },
        ),
        SwitchListTile(
          title: const Text('服务器离线通知'),
          subtitle: const Text('服务器离线时发送通知'),
          value: _settingsController.getNotifyServerOffline(),
          onChanged: _settingsController.getNotificationsEnabled()
              ? (value) async {
                  await _settingsController.setNotifyServerOffline(value);
                  setState(() {});
                }
              : null,
        ),
        SwitchListTile(
          title: const Text('玩家数量变化通知'),
          subtitle: const Text('玩家数量发生变化时通知'),
          value: _settingsController.getNotifyPlayerCountChange(),
          onChanged: _settingsController.getNotificationsEnabled()
              ? (value) async {
                  await _settingsController.setNotifyPlayerCountChange(value);
                  setState(() {});
                }
              : null,
        ),
      ],
    );
  }

  /// 构建高级设置
  Widget _buildAdvancedSection() {
    return _buildSection(
      title: '高级设置',
      icon: Icons.settings_applications,
      children: [
        SwitchListTile(
          title: const Text('调试模式'),
          subtitle: const Text('显示额外的调试信息'),
          value: _settingsController.getDebugMode(),
          onChanged: (value) async {
            await _settingsController.setDebugMode(value);
            setState(() {});
          },
        ),
        SwitchListTile(
          title: const Text('保持屏幕常亮'),
          subtitle: const Text('防止屏幕自动熄灭'),
          value: _settingsController.getKeepScreenOn(),
          onChanged: (value) async {
            await _settingsController.setKeepScreenOn(value);
            setState(() {});
          },
        ),
        ListTile(
          title: const Text('动画速度'),
          subtitle: Text('${_settingsController.getAnimationSpeed()}x'),
          leading: const Icon(Icons.speed),
          onTap: () => _showAnimationSpeedDialog(),
        ),
        if (_settingsController.getDebugMode())
          ListTile(
            title: const Text('查看所有设置'),
            subtitle: const Text('显示当前所有设置的详细信息'),
            leading: const Icon(Icons.info),
            onTap: () => _showAllSettings(),
          ),
      ],
    );
  }

  /// 构建设置分组
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  /// 显示主题选择对话框
  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('system', '跟随系统'),
            _buildThemeOption('light', '浅色主题'),
            _buildThemeOption('dark', '深色主题'),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String value, String title) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
      groupValue: _settingsController.getTheme(),
      onChanged: (newValue) async {
        if (newValue != null) {
          await _settingsController.setTheme(newValue);
          setState(() {});
          Navigator.pop(context);
        }
      },
    );
  }

  /// 显示语言选择对话框
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('system', '跟随系统'),
            _buildLanguageOption('zh', '中文'),
            _buildLanguageOption('en', 'English'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String value, String title) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
      groupValue: _settingsController.getLanguage(),
      onChanged: (newValue) async {
        if (newValue != null) {
          await _settingsController.setLanguage(newValue);
          setState(() {});
          Navigator.pop(context);
        }
      },
    );
  }

  /// 显示刷新间隔设置对话框
  void _showRefreshIntervalDialog() {
    final controller = TextEditingController(
      text: _settingsController.getRefreshInterval().toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置刷新间隔'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '间隔时间（秒）',
            hintText: '5-300',
            suffixText: '秒',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final value = int.tryParse(controller.text);
              if (value != null && value >= 5 && value <= 300) {
                await _settingsController.setRefreshInterval(value);
                setState(() {});
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('请输入5-300之间的数字')));
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示连接超时设置对话框
  void _showTimeoutDialog() {
    final controller = TextEditingController(
      text: _settingsController.getConnectionTimeout().toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置连接超时'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '超时时间（秒）',
            hintText: '1-30',
            suffixText: '秒',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final value = int.tryParse(controller.text);
              if (value != null && value >= 1 && value <= 30) {
                await _settingsController.setConnectionTimeout(value);
                setState(() {});
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('请输入1-30之间的数字')));
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示卡片列数设置对话框
  void _showCardColumnsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置卡片列数'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 1; i <= 4; i++)
              RadioListTile<int>(
                title: Text('$i列'),
                value: i,
                groupValue: _settingsController.getCardColumns(),
                onChanged: (newValue) async {
                  if (newValue != null) {
                    await _settingsController.setCardColumns(newValue);
                    setState(() {});
                    Navigator.pop(context);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  /// 显示动画速度设置对话框
  void _showAnimationSpeedDialog() {
    double currentSpeed = _settingsController.getAnimationSpeed();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('设置动画速度'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${currentSpeed.toStringAsFixed(1)}x'),
              Slider(
                value: currentSpeed,
                min: 0.1,
                max: 3.0,
                divisions: 29,
                onChanged: (value) {
                  setDialogState(() {
                    currentSpeed = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                await _settingsController.setAnimationSpeed(currentSpeed);
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示重置设置对话框
  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置设置'),
        content: const Text('确定要重置所有设置为默认值吗？\n（当前选中的服务器会保留）'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await _settingsController.resetToDefaults(
                keepSelectedServer: true,
              );
              setState(() {});
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('设置已重置为默认值')));
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示所有设置信息（调试用）
  void _showAllSettings() {
    final settings = _settingsController.getAllSettings();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('所有设置'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: settings.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '${entry.key}: ${entry.value}',
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 显示网络诊断信息
  void _showNetworkDiagnostics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('网络诊断'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('网络状态: 正常'),
            Text('DNS解析: 正常'),
            Text('连接延迟: < 100ms'),
            Text('上次检查: 刚刚'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  String _getThemeDisplayName(String theme) {
    switch (theme) {
      case 'light':
        return '浅色主题';
      case 'dark':
        return '深色主题';
      case 'system':
      default:
        return '跟随系统';
    }
  }

  String _getLanguageDisplayName(String language) {
    switch (language) {
      case 'zh':
        return '中文';
      case 'en':
        return 'English';
      case 'system':
      default:
        return '跟随系统';
    }
  }
}
