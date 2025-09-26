// flutter
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mcstatus/ui/card.dart';
import 'package:mcstatus/core/server.dart';
import 'package:mcstatus/ui/bottomSheet.dart';
import 'package:mcstatus/ui/showcentraldialog.dart';
import 'package:provider/provider.dart';
import 'package:mcstatus/provider/main.dart';

import '../models/servers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Server _serverController = Server();
  final Map<String, Map<String, dynamic>> _serverStatuses = {};
  Servers? _movingServer; // 当前移动的服务器
  bool _hasRegisteredCallback = false; // 标记是否已注册回调

  @override
  void initState() {
    super.initState();
    _loadServerStatuses();
    // 延迟注册回调，确保PageViewProvider已经初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registerRefreshCallback();
      // 注册重置标记的回调（使用页面索引 0）
      context.read<PageViewProvider>().setResetCallbackFlagCallback(0, _resetCallbackFlag);
    });
  }

  @override
  void dispose() {
    // 清理注册的回调
    if (mounted) {
      context.read<PageViewProvider>().setRefreshCallback(0, null);
      context.read<PageViewProvider>().setResetCallbackFlagCallback(0, null);
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
      context.read<PageViewProvider>().setRefreshCallback(0, _handleRefresh);
      _hasRegisteredCallback = true;
    }
  }

  /// 处理刷新操作
  void _handleRefresh() {
    _loadServerStatuses();
  }

  /// 监听服务器列表变化并自动更新状态
  void _onServersChanged(List<Servers> newServers) {
    // 检查是否有新增的服务器
    for (final server in newServers) {
      final serverKey = server.uuid.toString();
      if (!_serverStatuses.containsKey(serverKey)) {
        // 新服务器，立即获取状态
        _refreshServerStatus(server);
      }
    }

    // 清理已删除服务器的状态
    final currentServerKeys = newServers.map((s) => s.uuid.toString()).toSet();
    _serverStatuses.removeWhere((key, value) => !currentServerKeys.contains(key));
  }

  Future<void> _loadServerStatuses() async {
    final servers = _serverController.loadServers()
      ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex)); // 按sortIndex排序
    
    // 先为所有服务器设置加载状态
    if (mounted) {
      setState(() {
        for (final server in servers) {
          _serverStatuses[server.uuid.toString()] = {
            'online': false,
            'players': '加载中...',
            'signal': '0',
            'description': '正在获取服务器信息...',
          };
        }
      });
    }
    
    // 然后并发获取所有服务器状态
    final futures = servers.map((server) => _fetchSingleServerStatus(server));
    await Future.wait(futures);
  }
  
  Future<void> _fetchSingleServerStatus(Servers server) async {
    try {
      final status = await _serverController.pingServer(server.address);
      if (mounted) {
        setState(() {
          _serverStatuses[server.uuid.toString()] = {
            'online': status != null && status.response != null,
            'players': status?.response != null
                ? '${status.response!.players.online} / ${status.response!.players.max}'
                : '0 / 0',
            'signal': status?.response != null ? '4' : '0', // 4表示满信号，0表示无信号
            'description':
                status?.response?.description.description ?? 'A Minecraft Server',
          };
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _serverStatuses[server.uuid.toString()] = {
            'online': false,
            'players': '0 / 0',
            'signal': '0',
            'description': 'A Minecraft Server',
          };
        });
      }
    }
  }

  Future<void> _refreshServerStatus(Servers server) async {
    await _fetchSingleServerStatus(server);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PageViewProvider>(
      builder: (context, provider, child) {
        final isMovingMode = provider.isMovingMode;
        
        // 当页面切换到Home页且还未注册回调时，重新注册
        if (provider.selectedIndex == 0 && !_hasRegisteredCallback) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _registerRefreshCallback();
            }
          });
        }
        
        return Column(
          children: [
            // 主要内容
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const minWidth = 320.0; // 规定最小宽度
                  int crossAxisCount = (constraints.maxWidth / minWidth).floor();
                  if (crossAxisCount < 1) crossAxisCount = 1;
                  return ValueListenableBuilder(
                    valueListenable: Hive.box<Servers>('servers').listenable(),
                    builder: (context, Box<Servers> box, _) {
                      final servers = box.values.toList()
                        ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex)); // 根据sortIndex排序
                      
                      // 监听服务器变化并自动更新状态
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _onServersChanged(servers);
                      });

                      if (servers.isEmpty) {
                        return const Center(child: Text("暂无服务器"));
                      }

                      return RefreshIndicator(
                        onRefresh: _loadServerStatuses,
                        child: GridView.count(
                          padding: const EdgeInsets.all(4),
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                          childAspectRatio: 8 / 3,
                          children: servers.map((s) {
                            final status =
                                _serverStatuses[s.uuid.toString()] ??
                                {
                                  'online': false,
                                  'players': '加载中...',
                                  'signal': '0',
                                  'description': '正在获取服务器信息...',
                                };

                            return XCard(
                              serverId: s.uuid.toString(),
                              title: s.name,
                              address: s.address,
                              description: status['description'] as String,
                              imagePath: "assets/img/img.png",
                              signal: status['signal'] as String,
                              players: status['players'] as String,
                              onTap: isMovingMode ? null : () => _handleServerTap(s), // 移动模式下禁用点击
                              onRefresh: isMovingMode ? null : () => _refreshServerStatus(s), // 移动模式下禁用刷新
                              onLongPress: isMovingMode ? null : () => _handleServerLongPress(s), // 移动模式下禁用长按
                              isMovingMode: isMovingMode,
                              isMovingTarget: _movingServer?.uuid == s.uuid,
                              onMoveToPosition: isMovingMode ? () => _handleMoveToPosition(s) : null,
                            );
                          }).toList(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// 处理服务器卡片点击事件
  void _handleServerTap(Servers server) {
    // 设置选中的服务器并切换到info页面
    context.read<PageViewProvider>().setSelectedServer(server);
  }

  /// 处理服务器卡片长按事件
  void _handleServerLongPress(Servers server) {
    ServerBottomSheet.show(
      context: context,
      server: server,
      onMove: () => _handleMoveServer(server),
      onEdit: () => _handleEditServer(server),
      onDelete: () => _handleDeleteServer(server),
    );
  }

  /// 处理移动服务器
  void _handleMoveServer(Servers server) {
    setState(() {
      _movingServer = server;
    });
    
    // 通知Provider进入移动模式
    context.read<PageViewProvider>().setMovingMode(true, cancelCallback: _cancelMoveMode);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('移动模式已开启，点击目标位置放置 "${server.name}"'),
        backgroundColor: Colors.blue,
        action: SnackBarAction(
          label: '取消', 
          textColor: Colors.white,
          onPressed: _cancelMoveMode,
        ),
        duration: const Duration(seconds: 10),
      ),
    );
  }

  /// 取消移动模式
  void _cancelMoveMode() {
    setState(() {
      _movingServer = null;
    });
    
    // 通知Provider退出移动模式
    context.read<PageViewProvider>().setMovingMode(false);
    
    // 隐藏SnackBar
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// 处理移动到指定位置
  Future<void> _handleMoveToPosition(Servers targetServer) async {
    if (_movingServer == null || _movingServer!.uuid == targetServer.uuid) {
      _cancelMoveMode();
      return;
    }

    try {
      final movingServer = _movingServer!;
      final targetSortIndex = targetServer.sortIndex;
      final movingSortIndex = movingServer.sortIndex;

      print('移动服务器: ${movingServer.name} (从sortIndex $movingSortIndex 到 $targetSortIndex)');

      // 获取所有服务器
      final allServers = _serverController.loadServers();
      final serversToUpdate = <Servers>[];

      if (movingSortIndex < targetSortIndex) {
        // 向后移动：中间的服务器往前移动1位
        for (final server in allServers) {
          if (server.sortIndex > movingSortIndex && server.sortIndex <= targetSortIndex) {
            server.sortIndex = server.sortIndex - 1;
            serversToUpdate.add(server);
          }
        }
        movingServer.sortIndex = targetSortIndex;
      } else {
        // 向前移动：中间的服务器往后移动1位
        for (final server in allServers) {
          if (server.sortIndex >= targetSortIndex && server.sortIndex < movingSortIndex) {
            server.sortIndex = server.sortIndex + 1;
            serversToUpdate.add(server);
          }
        }
        movingServer.sortIndex = targetSortIndex;
      }

      // 添加移动的服务器到更新列表
      serversToUpdate.add(movingServer);

      // 批量更新
      await _serverController.updateServers(serversToUpdate);

      // 取消移动模式
      _cancelMoveMode();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('移动成功: "${movingServer.name}" 已移动到新位置'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('移动失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 处理编辑服务器
  void _handleEditServer(Servers server) {
    showCentralDialog(context, server: server);
  }

  /// 处理删除服务器
  void _handleDeleteServer(Servers server) async {
    try {
      await _serverController.delete(server);
      if (mounted) {
        setState(() {
          _serverStatuses.remove(server.uuid.toString());
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已删除服务器: ${server.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
