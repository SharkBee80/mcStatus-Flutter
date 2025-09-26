// flutter
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mcstatus/ui/card.dart';
import 'package:mcstatus/core/server.dart';
import 'package:mcstatus/ui/bottomSheet.dart';
import 'package:mcstatus/ui/showcentraldialog.dart';

import '../models/servers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Server _serverController = Server();
  final Map<String, Map<String, dynamic>> _serverStatuses = {};

  @override
  void initState() {
    super.initState();
    _loadServerStatuses();
  }

  Future<void> _loadServerStatuses() async {
    final servers = _serverController.loadServers();
    for (final server in servers) {
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
  }

  Future<void> _refreshServerStatus(Servers server) async {
    try {
      final status = await _serverController.pingServer(server.address);
      if (mounted) {
        setState(() {
          _serverStatuses[server.uuid.toString()] = {
            'online': status != null && status.response != null,
            'players': status?.response != null
                ? '${status.response!.players.online} / ${status.response!.players.max}'
                : '0 / 0',
            'signal': status?.response != null ? '4' : '0',
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const minWidth = 320.0; // 规定最小宽度
        int crossAxisCount = (constraints.maxWidth / minWidth).floor();
        if (crossAxisCount < 1) crossAxisCount = 1;
        return ValueListenableBuilder(
          valueListenable: Hive.box<Servers>('servers').listenable(),
          builder: (context, Box<Servers> box, _) {
            final servers = box.values.toList();

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
                        'players': '0 / 0',
                        'signal': '0',
                        'description': 'A Minecraft Server',
                      };

                  return XCard(
                    serverId: s.uuid.toString(),
                    title: s.name,
                    address: s.address,
                    description: status['description'] as String,
                    imagePath: "assets/img/img.png",
                    signal: status['signal'] as String,
                    players: status['players'] as String,
                    onRefresh: () => _refreshServerStatus(s),
                    onLongPress: () => _handleServerLongPress(s),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('移动服务器: ${server.name}'),
        action: SnackBarAction(label: '确定', onPressed: () {}),
      ),
    );
    // TODO: 实现服务器顺序调整逻辑
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
