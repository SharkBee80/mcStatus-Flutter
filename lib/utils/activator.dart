import 'dart:io';
import 'package:mcstatus/utils/files_utils.dart';
import 'package:mcstatus/utils/debug.dart';
import 'package:mcstatus/config.dart';

class Activator {
  static const String _activationFileName = 'activation.key';

  /// 验证激活码
  static Future<bool> validateActivationKey(String activationKey) async {
    // 简单的激活码验证逻辑，实际项目中应该连接服务器验证
    // 这里我们假设任何非空的激活码都是有效的
    if (activationKey == authKey.toString()) {
      return true;
    } else {
      return false;
    }
    //return activationKey.isNotEmpty;
  }

  /// 保存激活码到本地文件
  static Future<void> saveActivationKey(String activationKey) async {
    try {
      final directory = await FileUtils.getStandardConfigPath();
      final File file = File('${directory.path}/$_activationFileName');
      DebugX.console('debug ${file.path}');
      await file.writeAsString(activationKey);
    } catch (e) {
      // 在实际应用中，应该处理异常情况
      rethrow;
    }
  }

  /// 从本地文件读取激活码
  static Future<String?> getActivationKey() async {
    try {
      final directory = await FileUtils.getStandardConfigPath();
      final File file = File('${directory.path}/$_activationFileName');
      DebugX.console('debug ${file.path}');
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (e) {
      // 在实际应用中，应该处理异常情况
      return null;
    }
  }

  /// 检查应用是否已激活
  static Future<bool> isAppActivated() async {
    final String? activationKey = await getActivationKey();
    return validateActivationKey(activationKey!);
  }
}