import 'package:hive/hive.dart';

part 'servers.g.dart'; // 自动生成文件

@HiveType(typeId: 0)
class Servers extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String address;

  @HiveField(2)
  String fulladdress;

  @HiveField(3)
  int uuid;

  @HiveField(4)
  String addtime;

  @HiveField(5)
  String edittime;

  @HiveField(6)
  int sortIndex; // 保存顺序

  Servers({
    required this.name,
    required this.address,
    required this.fulladdress,
    required this.uuid,
    required this.addtime,
    required this.edittime,
    required this.sortIndex,
  });
}
