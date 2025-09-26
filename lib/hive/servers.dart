import 'package:hive/hive.dart';
import 'package:mcstatus/models/servers.dart';

class ServersController {
  final serversBox = Hive.box<Servers>('servers');

  Future<void> saveServer(Servers server) async {
    try {
      await serversBox.put(server.uuid, server);
    } catch (e) {
      // 处理保存服务器时可能发生的异常
      rethrow;
    }
  }

  Future<void> saveServerList(List<Servers> servers) async {
    try {
      final Map<dynamic, Servers> serverMap = {
        for (var server in servers) server.uuid: server,
      };
      await serversBox.putAll(serverMap);
    } catch (e) {
      // 处理批量保存服务器时可能发生的异常
      rethrow;
    }
  }

  Future<void> deleteServer(Servers server) async {
    try {
      await serversBox.delete(server.uuid);
    } catch (e) {
      // 处理删除服务器时可能发生的异常
      rethrow;
    }
  }

  Future<void> updateServer(Servers server) async {
    try {
      await serversBox.put(server.uuid, server);
    } catch (e) {
      // 处理更新服务器时可能发生的异常
      rethrow;
    }
  }

  /// 批量更新服务器，用于优化性能
  Future<void> updateServers(List<Servers> servers) async {
    try {
      final Map<dynamic, Servers> serverMap = {
        for (var server in servers) server.uuid: server,
      };
      await serversBox.putAll(serverMap);
    } catch (e) {
      // 处理批量更新服务器时可能发生的异常
      rethrow;
    }
  }

  List<Servers> loadServers() {
    try {
      final servers = serversBox.values.toList();
      // 按sortIndex排序返回
      servers.sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
      return servers;
    } catch (e) {
      // 处理加载服务器列表时可能发生的异常
      rethrow;
    }
  }

  Future<void> deleteAllServers() async {
    try {
      await serversBox.clear();
    } catch (e) {
      // 处理清空所有服务器时可能发生的异常
      rethrow;
    }
  }

  int getServerLength() {
    return serversBox.length;
  }

  Servers? getServer(int uuid) {
    return serversBox.get(uuid);
  }
}
