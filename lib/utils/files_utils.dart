import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FileUtils {
  // /// 根据不同平台获取应用文档目录
  // static Future<Directory> getApplicationDocumentsDirectoryByPlatform() async {
  //   // getApplicationDocumentsDirectory() 已经支持所有平台，直接返回即可
  //   return getApplicationDocumentsDirectory();
  // }

  /// 获取特定平台下的应用数据目录
  static Future<Directory> _getApplicationDataDirectory() async {
    if (kIsWeb) {
      // Web平台不支持应用数据目录
      throw UnsupportedError(
        'Web platform does not support application data directory',
      );
    } else if (Platform.isWindows) {
      // Windows平台使用ApplicationData目录
      return getApplicationSupportDirectory();
    } else if (Platform.isMacOS || Platform.isLinux) {
      // macOS和Linux平台使用ApplicationSupport目录
      return getApplicationSupportDirectory();
    } else if (Platform.isAndroid || Platform.isIOS) {
      // 移动平台使用ApplicationSupport目录
      return getApplicationSupportDirectory();
    } else {
      // return getApplicationDocumentsDirectory();
      return getApplicationSupportDirectory();
    }
  }

  /// 获取各平台的标准配置文件路径
  static Future<Directory> getDirectoryPath([String? pathName]) async {
    Directory directory = await _getApplicationDataDirectory();
    String directoryPath = directory.path;
    if (pathName == null) {
      return directory;
    }
    return Directory(path.join(directoryPath, pathName));
  }

  static Future<String> getStringPath([String? pathName]) async {
    Directory directory = await _getApplicationDataDirectory();
    String directoryPath = directory.path;
    if (pathName == null) {
      return directoryPath;
    }
    return path.join(directoryPath, pathName);
  }
}
