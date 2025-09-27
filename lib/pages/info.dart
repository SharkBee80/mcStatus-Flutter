import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mcstatus/provider/main.dart';
import 'package:mcstatus/models/servers.dart';
import 'package:mcstatus/core/server.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  String _lastRefreshTime = '从未刷新';
  bool _isLoading = false;
  bool _hasRegisteredCallback = false; // 标记是否已注册回调
  final Server _serverController = Server();
  Map<String, dynamic>? _serverStatus; // 服务器状态信息

  @override
  void initState() {
    super.initState();
    // 延迟注册回调，确保PageViewProvider已经初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registerRefreshCallback();
      // 注册重置标记的回调（使用页面索引 1）
      context.read<PageViewProvider>().setResetCallbackFlagCallback(
        1,
        _resetCallbackFlag,
      );
    });
  }

  @override
  void dispose() {
    // 清理注册的回调
    if (mounted) {
      context.read<PageViewProvider>().setRefreshCallback(1, null);
      context.read<PageViewProvider>().setResetCallbackFlagCallback(1, null);
    }
    super.dispose();
  }

  /// 重置注册标记
  void _resetCallbackFlag() {
    _hasRegisteredCallback = false;
  }

  /// 注册刷新回调
  void _registerRefreshCallback() {
    if (mounted && !_hasRegisteredCallback) {
      context.read<PageViewProvider>().setRefreshCallback(1, _handleRefresh);
      _hasRegisteredCallback = true;
    }
  }

  /// 处理刷新操作
  void _handleRefresh() {
    final selectedServer = context.read<PageViewProvider>().selectedServer;
    if (selectedServer != null) {
      _refreshServerInfo(selectedServer);
    } else {
      _refreshInfo();
    }
  }

  /// 刷新选中服务器信息
  Future<void> _refreshServerInfo(Servers server) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final status = await _serverController.pingServer(server.address);

      if (mounted) {
        setState(() {
          _serverStatus = {
            'name': server.name,
            'address': server.address,
            'fullAddress': server.fulladdress,
            'online': status != null && status.response != null,
            'players': status?.response != null
                ? '${status.response!.players.online} / ${status.response!.players.max}'
                : '0 / 0',
            'version': status?.response?.version.name ?? '未知版本',
            'description':
                status?.response?.description.description ??
                'A Minecraft Server',
            'latency': status?.ping?.toString() ?? '0',
            'maxPlayers': status?.response?.players.max?.toString() ?? '0',
            'onlinePlayers':
                status?.response?.players.online?.toString() ?? '0',
            'playerSample':
                status?.response?.players.sample
                    ?.map((player) => player.name)
                    .toList()
                    ?.cast<String>() ??
                <String>[],
          };
          _lastRefreshTime = DateTime.now().toString().substring(0, 19);
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('服务器信息刷新完成: ${server.name}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _serverStatus = {
            'name': server.name,
            'address': server.address,
            'fullAddress': server.fulladdress,
            'online': false,
            'players': '0 / 0',
            'version': '无法连接',
            'description': '服务器不可达',
            'latency': '0',
            'maxPlayers': '0',
            'onlinePlayers': '0',
            'playerSample': <String>[],
          };
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('刷新失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// 刷新信息页面
  Future<void> _refreshInfo() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 模拟网络请求
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _lastRefreshTime = DateTime.now().toString().substring(0, 19);
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('信息页面刷新完成'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('刷新失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PageViewProvider>(
      builder: (context, provider, child) {
        // 当页面切换到Info页且还未注册回调时，重新注册
        if (provider.selectedIndex == 1 && !_hasRegisteredCallback) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _registerRefreshCallback();
            }
          });
        }

        final selectedServer = provider.selectedServer;

        return RefreshIndicator(
          onRefresh: () => selectedServer != null
              ? _refreshServerInfo(selectedServer)
              : _refreshInfo(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: selectedServer != null
                ? _buildServerDetails(selectedServer)
                : _buildDefaultContent(),
          ),
        );
      },
    );
  }

  /// 构建默认内容（未选中服务器时）
  Widget _buildDefaultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 页面标题
        const Text(
          '服务器信息',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 40),

        // 提示信息卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.dns_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    '请选择一个服务器',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '在首页点击服务器卡片查看详细信息',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建服务器详情内容
  Widget _buildServerDetails(Servers server) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 连接状态卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _serverStatus?['online'] == true
                          ? Icons.check_circle
                          : Icons.error,
                      color: _serverStatus?['online'] == true
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '连接状态',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (_isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('最后刷新: $_lastRefreshTime'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _serverStatus?['online'] == true
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _serverStatus?['online'] == true ? '在线' : '离线',
                    style: TextStyle(
                      color: _serverStatus?['online'] == true
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 服务器信息卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      '服务器信息',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('服务器名称', server.name),
                _buildInfoRow('服务器地址', server.address),
                _buildInfoRow('完整地址', server.fulladdress),
                _buildInfoRow('添加时间', server.addtime),
                if (_serverStatus != null) ..._buildServerStatus(),
              ],
            ),
          ),
        ),

        if (_serverStatus?['online'] == true) ..._buildPlayerInfo(),
      ],
    );
  }

  /// 构建服务器状态信息
  List<Widget> _buildServerStatus() {
    return [
      const SizedBox(height: 16),
      const Divider(),
      const SizedBox(height: 12),
      Row(
        children: [
          const Icon(Icons.speed, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          const Text(
            '服务器状态',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      const SizedBox(height: 8),
      _buildInfoRow('版本', _serverStatus!['version'] ?? '未知'),
      _buildInfoRow('延迟', '${_serverStatus!['latency']} ms'),
      _buildInfoRow('描述', _serverStatus!['description'] ?? '无'),
    ];
  }

  /// 构建玩家信息
  List<Widget> _buildPlayerInfo() {
    return [
      const SizedBox(height: 16),

      // 玩家信息卡片
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.people, color: Colors.purple),
                  const SizedBox(width: 8),
                  const Text(
                    '玩家信息',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildPlayerCountCard(
                      '在线玩家',
                      _serverStatus!['onlinePlayers'] ?? '0',
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPlayerCountCard(
                      '最大玩家数',
                      _serverStatus!['maxPlayers'] ?? '0',
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              // 添加玩家列表
              if ((_serverStatus!['playerSample'] as List?)?.isNotEmpty == true)
                ..._buildPlayerList(),
            ],
          ),
        ),
      ),
    ];
  }

  /// 构建玩家数量卡片
  Widget _buildPlayerCountCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  /// 构建玩家列表
  List<Widget> _buildPlayerList() {
    final playerListRaw = _serverStatus!['playerSample'] as List?;
    final playerList = playerListRaw?.cast<String>() ?? <String>[];

    return [
      const SizedBox(height: 16),
      const Divider(),
      const SizedBox(height: 12),
      Row(
        children: [
          const Icon(Icons.person_outline, color: Colors.purple, size: 20),
          const SizedBox(width: 8),
          const Text(
            '在线玩家列表',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${playerList.length} 人',
              style: TextStyle(
                fontSize: 12,
                color: Colors.purple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: playerList
              .map((playerName) => _buildPlayerChip(playerName))
              .toList(),
        ),
      ),
    ];
  }

  /// 构建玩家名片
  Widget _buildPlayerChip(String playerName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person, size: 16, color: Colors.blue),
          const SizedBox(width: 4),
          Text(
            playerName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
