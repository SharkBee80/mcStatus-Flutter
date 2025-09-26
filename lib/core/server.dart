import 'package:uuid/uuid.dart';
import 'package:mcstatus/hive/servers.dart';
import 'package:mcstatus/models/servers.dart';

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
      await serversController.deleteServer(server);
    } catch (e) {
      // 处理保存过程中可能发生的异常
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

  Future<dynamic> pingServer(String address) async {
    try {
      final fullAddress = _getFullAddress(address);
      final split = fullAddress.split(':');
      final host = split[0];
      final port = int.parse(split[1]);
      
      final response = await ping(host, port: port);
      return response;
    } catch (e) {
      print('Error pinging $address: $e');
      return null;
    }
  }

  Future<dynamic> getServerInfo(String address) async {
    try {
      final fullAddress = _getFullAddress(address);
      final split = fullAddress.split(':');
      final host = split[0];
      final port = int.parse(split[1]);
      
      final response = await ping(host, port: port);
      return response;
    } catch (e) {
      print('Error getting server info for $address: $e');
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
