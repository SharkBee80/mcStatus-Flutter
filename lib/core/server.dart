import 'package:uuid/uuid.dart';
import 'package:mcstatus/hive/servers.dart';
import 'package:mcstatus/models/servers.dart';

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

  Future<void> update(Servers server) async {
    try {
      server.edittime = DateTime.now().toString();
      await serversController.updateServer(server);
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

  String _getFullAddress(String address) {
    final split = address.split(':');
    if (split.length == 2) {
      return address;
    } else {
      return "$address:25565";
    }
  }
}
