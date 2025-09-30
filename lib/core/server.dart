import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:mcstatus/hive/servers.dart';
import 'package:mcstatus/models/servers.dart';
import 'package:mcstatus/utils/debug.dart';

/// mcstatus库
import 'package:dart_minecraft/dart_minecraft.dart';

var uuid = Uuid();
var serversController = ServersController();

class Server {
  Future<void> save(String name, String address) async {
    try {
      final server = Servers(
        name: name,
        address: address,
        fulladdress: _getFullAddress(address),
        uuid: uuid.v4().hashCode,
        // 使用hashCode将UUID转换为int
        addtime: DateTime.now().toString(),
        edittime: DateTime.now().toString(),
        sortIndex: serversController.getServerLength() + 1,
      );
      await serversController.saveServer(server);
    } catch (e) {
      // 处理保存过程中可能发生的异常
      rethrow;
    }
  }

  Future<bool> update(String name, String address, String uuidStr) async {
    try {
      // 将字符串转换为int
      int uuid = int.parse(uuidStr);
      Servers? server = serversController.getServer(uuid);
      if (server == null) {
        return false;
      }
      server.name = name;
      server.address = address;
      server.fulladdress = _getFullAddress(address);
      server.edittime = DateTime.now().toString();
      await serversController.updateServer(server);
      return true;
    } catch (e) {
      // 处理保存过程中可能发生的异常
      rethrow;
    }
  }

  int getServerLength() {
    return serversController.getServerLength();
  }

  Future<void> delete(Servers server) async {
    try {
      final deletedSortIndex = server.sortIndex;
      print('删除服务器: ${server.name}, sortIndex: $deletedSortIndex');

      // 删除服务器
      await serversController.deleteServer(server);

      // 获取所有剩余服务器
      final remainingServers = serversController.loadServers();

      // 找到所有需要调整sortIndex的服务器（sortIndex大于被删除服务器的）
      final serversToUpdate = remainingServers
          .where((s) => s.sortIndex > deletedSortIndex)
          .toList();

      if (serversToUpdate.isNotEmpty) {
        print('需要调整的服务器数量: ${serversToUpdate.length}');

        // 将这些服务器的sortIndex往前移动1位
        for (final serverToUpdate in serversToUpdate) {
          final oldIndex = serverToUpdate.sortIndex;
          serverToUpdate.sortIndex = serverToUpdate.sortIndex - 1;
          print(
            '调整服务器: ${serverToUpdate.name}, 从sortIndex $oldIndex → ${serverToUpdate.sortIndex}',
          );
        }

        // 批量更新所有受影响的服务器
        await serversController.updateServers(serversToUpdate);
        print('批量更新完成');
      } else {
        print('无需调整的服务器');
      }
    } catch (e) {
      // 处理保存过程中可能发生的异常
      print('删除服务器失败: $e');
      rethrow;
    }
  }

  List<Servers> loadServers() {
    try {
      return serversController.loadServers();
    } catch (e) {
      // 处理保存过程中可能发生的异常
      rethrow;
    }
  }

  /// 批量更新服务器
  Future<void> updateServers(List<Servers> servers) async {
    try {
      await serversController.updateServers(servers);
    } catch (e) {
      // 处理批量更新过程中可能发生的异常
      rethrow;
    }
  }

  Future<dynamic> pingServer(String address) async {
    try {
      DebugX.console('Ping服务器: $address');
      
      final fullAddress = _getFullAddress(address);
      final split = fullAddress.split(':');
      
      if (split.length != 2) {
        DebugX.console('无效的地址格式: $fullAddress');
        return null;
      }
      
      final host = split[0];
      final portStr = split[1];
      
      // 验证端口号
      final port = int.tryParse(portStr);
      if (port == null || port < 1 || port > 65535) {
        DebugX.console('无效的端口号: $portStr');
        return null;
      }
      
      // 验证主机名
      if (host.isEmpty) {
        DebugX.console('空的主机名');
        return null;
      }
      
      DebugX.console('尝试连接 $host:$port');
      
      // 添加超时和异常处理
      final response = await ping(host, port: port).timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          DebugX.console('Ping $address 超时');
          return null;
        },
      );
      
      if (response != null) {
        DebugX.console('Ping $address 成功');
      } else {
        DebugX.console('Ping $address 失败: 无响应');
      }
      
      return response;
    } catch (e, stackTrace) {
      DebugX.console('Ping $address 异常: $e');
      DebugX.console('堆栈跟踪: $stackTrace');
      return null;
    }
  }

  Future<dynamic> getServerInfo(String address) async {
    try {
      DebugX.console('获取服务器信息: $address');
      
      final fullAddress = _getFullAddress(address);
      final split = fullAddress.split(':');
      
      if (split.length != 2) {
        DebugX.console('无效的地址格式: $fullAddress');
        throw ArgumentError('无效的地址格式: $fullAddress');
      }
      
      final host = split[0];
      final portStr = split[1];
      
      final port = int.tryParse(portStr);
      if (port == null || port < 1 || port > 65535) {
        DebugX.console('无效的端口号: $portStr');
        throw ArgumentError('无效的端口号: $portStr');
      }
      
      if (host.isEmpty) {
        DebugX.console('空的主机名');
        throw ArgumentError('空的主机名');
      }
      
      DebugX.console('尝试获取服务器信息 $host:$port');
      
      final response = await ping(host, port: port).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          DebugX.console('获取服务器信息 $address 超时');
          throw TimeoutException('连接超时', const Duration(seconds: 10));
        },
      );
      
      DebugX.console('获取服务器信息 $address 成功');
      return response;
    } catch (e, stackTrace) {
      DebugX.console('获取服务器信息 $address 异常: $e');
      DebugX.console('堆栈跟踪: $stackTrace');
      rethrow;
    }
  }
}

String _getFullAddress(String address) {
  final split = address.split(':');
  if (split.length == 2) {
    return address;
  } else {
    return "$address:25565";
  }
}
