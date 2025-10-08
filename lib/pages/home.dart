// flutter
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mcstatus/ui/card.dart';
import 'package:mcstatus/core/server.dart';
import 'package:mcstatus/ui/bottomSheet.dart';
import 'package:mcstatus/ui/showcentraldialog.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:mcstatus/provider/main.dart';
import 'package:mcstatus/utils/debug.dart';
import 'package:mcstatus/utils/error_handler.dart';
import 'package:mcstatus/utils/concurrency_controller.dart';

import '../models/servers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final Server _serverController = Server();
  final Map<String, Map<String, dynamic>> _serverStatuses = {};
  Servers? _movingServer; // 当前移动的服务器
  bool _hasRegisteredCallback = false; // 标记是否已注册回调
  
  // 自适应并发控制
  int _optimalBatchSize = 2; // 初始批次大小
  int _successfulRequests = 0;
  int _failedRequests = 0;

  @override
  bool get wantKeepAlive => true; // 保持页面活跃状态

  @override
  void initState() {
    super.initState();
    _loadServerStatuses();
    // 延迟注册回调，确保PageViewProvider已经初始化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _registerRefreshCallback();
      // 注册重置标记的回调（使用页面索引 0）
      context.read<PageViewProvider>().setResetCallbackFlagCallback(
        0,
        _resetCallbackFlag,
      );
      // 验证选中的服务器是否还存在
      context.read<PageViewProvider>().validateSelectedServer();
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
    _serverStatuses.removeWhere(
      (key, value) => !currentServerKeys.contains(key),
    );
    
    // 如果服务器列表为空，确保UI状态正确更新
    if (newServers.isEmpty && mounted) {
      setState(() {
        // 清空所有状态
      });
    }
  }

  Future<void> _loadServerStatuses() async {
    try {
      DebugX.console('开始加载服务器状态...');
      
      final servers = _serverController.loadServers()
        ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex)); // 按sortIndex排序

      DebugX.console('找到 ${servers.length} 个服务器');

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

      if (servers.isEmpty) {
        DebugX.console('没有服务器需要刷新');
        return;
      }

      // 使用高级并发控制器
      await _loadWithAdvancedConcurrency(servers);
      
      DebugX.console('服务器状态加载完成');
    } catch (e) {
      DebugX.console('加载服务器状态失败: $e');
      
      if (mounted) {
        showToast('刷新失败: 网络连接异常');
      }
    }
  }
  
  /// 使用高级并发控制器加载
  Future<void> _loadWithAdvancedConcurrency(List<Servers> servers) async {
    // 创建任务列表
    final tasks = servers.map((server) => () async {
      return await _fetchSingleServerStatusForBatch(server);
    }).toList();
    
    // 使用并发控制器执行
    final results = await ConcurrencyController.executeBatch(
      tasks,
      batchName: '服务器状态刷新',
      timeoutSeconds: 10,
    );
    
    // 统计结果
    final successCount = results.where((r) => r != null).length;
    final failureCount = results.length - successCount;
    
    DebugX.console('批量加载完成: 成功 $successCount, 失败 $failureCount');
    
    if (mounted && failureCount > 0) {
      showToast('部分服务器状态获取失败 ($failureCount/${results.length})');
    }
  }
  
  /// 为批量处理优化的单个服务器状态获取
  Future<bool> _fetchSingleServerStatusForBatch(Servers server) async {
    try {
      DebugX.console('正在获取服务器状态: ${server.name}');
      
      final status = await _serverController.pingServer(server.address);
      
      if (!mounted) return false;
      
      setState(() {
        _serverStatuses[server.uuid.toString()] = {
          'online': status != null && status.response != null,
          'players': status?.response != null
              ? '${status.response!.players.online} / ${status.response!.players.max}'
              : '0 / 0',
          'signal': status?.response != null ? '4' : '0',
          'description': _getDescriptionFromStatus(status),
        };
      });
      
      return status != null;
    } catch (e) {
      DebugX.console('获取服务器 ${server.name} 状态异常: $e');
      
      if (mounted) {
        setState(() {
          _serverStatuses[server.uuid.toString()] = {
            'online': false,
            'players': '0 / 0',
            'signal': '0',
            'description': '连接失败: ${e.toString().contains("timeout") ? "连接超时" : "无法连接"}',
          };
        });
      }
      
      return false;
    }
  }

  /// 从状态中提取描述信息
  String _getDescriptionFromStatus(dynamic status) {
    if (status == null) {
      return '服务器离线或不存在';
    }
    
    if (status.response == null) {
      return '无法获取服务器信息';
    }
    
    final description = status.response?.description.description;
    if (description != null && description.isNotEmpty && description != 'A Minecraft Server') {
      return description;
    }
    
    return 'A Minecraft Server';
  }

  Future<void> _fetchSingleServerStatus(Servers server) async {
    try {
      DebugX.console('正在获取服务器状态: ${server.name} (${server.address})');
      
      // 添加超时控制，防止长时间卡住
      final status = await _serverController.pingServer(server.address)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              DebugX.console('服务器 ${server.name} ping超时');
              return null;
            },
          );
      
      if (!mounted) return; // 确保组件仍然存在
      
      DebugX.console('服务器 ${server.name} 状态获取完成: ${status != null ? "成功" : "失败"}');
      
      setState(() {
        _serverStatuses[server.uuid.toString()] = {
          'online': status != null && status.response != null,
          'players': status?.response != null
              ? '${status.response!.players.online} / ${status.response!.players.max}'
              : '0 / 0',
          'signal': status?.response != null ? '4' : '0', // 4表示满信号，0表示无信号
          'description': _getDescriptionFromStatus(status),
        };
      });
    } catch (e) {
      DebugX.console('获取服务器 ${server.name} 状态异常: $e');
      
      if (!mounted) return; // 确保组件仍然存在
      
      setState(() {
        _serverStatuses[server.uuid.toString()] = {
          'online': false,
          'players': '0 / 0',
          'signal': '0',
          'description': '连接失败: ${e.toString().contains("timeout") ? "连接超时" : "无法连接"}',
        };
      });
    }
  }

  Future<void> _refreshServerStatus(Servers server) async {
    // 使用并发控制器执行单个服务器刷新
    await ConcurrencyController.execute(
      () => _fetchSingleServerStatusForBatch(server),
      taskName: '刷新${server.name}',
      timeoutSeconds: 8,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 保持页面活跃状态必需的调用

    return ErrorBoundary(
      errorMessage: '服务器列表加载出错',
      child: Consumer<PageViewProvider>(
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
                    int crossAxisCount = (constraints.maxWidth / minWidth)
                        .floor();
                    if (crossAxisCount < 1) crossAxisCount = 1;
                    return ValueListenableBuilder(
                      valueListenable: Hive.box<Servers>('servers').listenable(),
                      builder: (context, Box<Servers> box, _) {
                        final servers = box.values.toList()
                          ..sort(
                            (a, b) => a.sortIndex.compareTo(b.sortIndex),
                          ); // 根据sortIndex排序

                        // 监听服务器变化并自动更新状态
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          try {
                            _onServersChanged(servers);
                          } catch (e) {
                            DebugX.console('监听服务器变化异常: $e');
                          }
                        });

                        // 修复：即使服务器列表为空也显示友好的提示信息
                        if (servers.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.cloud_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "暂无服务器",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "点击右上角添加按钮添加服务器",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    showCentralDialog(context);
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text("添加服务器"),
                                ),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () => SafeAsyncOperation.execute(
                            () => _loadServerStatuses(),
                            errorMessage: '刷新失败',
                            showToast: true,
                          ).then((_) {}),
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
                                onTap: isMovingMode
                                    ? null
                                    : () => _handleServerTap(s),
                                // 移动模式下禁用点击
                                onRefresh: isMovingMode
                                    ? null
                                    : () => _refreshServerStatus(s),
                                // 移动模式下禁用刷新
                                onLongPress: isMovingMode
                                    ? null
                                    : () => _handleServerLongPress(s),
                                // 移动模式下禁用长按
                                isMovingMode: isMovingMode,
                                isMovingTarget: _movingServer?.uuid == s.uuid,
                                onMoveToPosition: isMovingMode
                                    ? () => _handleMoveToPosition(s)
                                    : null,
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
      ),
    );
  }

  /// 处理服务器卡片点击事件
  void _handleServerTap(Servers server) async {
    // 设置选中的服务器并切换到info页面
    await context.read<PageViewProvider>().setSelectedServer(server);
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
    context.read<PageViewProvider>().setMovingMode(
      true,
      cancelCallback: _cancelMoveMode,
    );
  }

  /// 取消移动模式
  void _cancelMoveMode() {
    setState(() {
      _movingServer = null;
    });
    // 通知Provider退出移动模式
    context.read<PageViewProvider>().setMovingMode(false);
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

      print(
        '移动服务器: ${movingServer.name} (从sortIndex $movingSortIndex 到 $targetSortIndex)',
      );

      // 获取所有服务器
      final allServers = _serverController.loadServers();
      final serversToUpdate = <Servers>[];

      if (movingSortIndex < targetSortIndex) {
        // 向后移动：中间的服务器往前移动1位
        for (final server in allServers) {
          if (server.sortIndex > movingSortIndex &&
              server.sortIndex <= targetSortIndex) {
            server.sortIndex = server.sortIndex - 1;
            serversToUpdate.add(server);
          }
        }
        movingServer.sortIndex = targetSortIndex;
      } else {
        // 向前移动：中间的服务器往后移动1位
        for (final server in allServers) {
          if (server.sortIndex >= targetSortIndex &&
              server.sortIndex < movingSortIndex) {
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
        showToast('移动成功: "${movingServer.name}" 已移动到新位置');
      }
    } catch (e) {
      if (mounted) {
        showToast('移动失败: $e');
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
        showToast('已删除服务器: ${server.name}');
      }
    } catch (e) {
      if (mounted) {
        showToast('删除失败: $e');
      }
    }
  }
}
