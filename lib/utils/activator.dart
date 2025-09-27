import 'dart:io';
import 'package:mcstatus/utils/files_utils.dart';
import 'package:mcstatus/utils/debug.dart';
import 'package:mcstatus/config.dart';

class Activator {
  static const String _activationFileName = 'activation.key';

  /// 验证激活码
  static Future<bool> validateActivationKey(String? activationKey) async {
    // 如果激活码为空或null，返回false
    if (activationKey == null || activationKey.isEmpty) {
      return false;
    }
    
    // 简单的激活码验证逻辑，实际项目中应该连接服务器验证
    if (activationKey == authKey.toString()) {
      return true;
    } else {
      return false;
    }
  }

  /// 保存激活码到本地文件
  static Future<void> saveActivationKey(String activationKey) async {
    try {
      String directory = await FileUtils.getStringPath(_activationFileName);
      final File file = File(directory);
      
      // 确保父目录存在
      final parentDir = file.parent;
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }
      
      DebugX.console('Saving activation key to: ${file.path}');
      await file.writeAsString(activationKey);
    } catch (e) {
      DebugX.console('Error saving activation key: $e');
      rethrow;
    }
  }

  /// 从本地文件读取激活码
  static Future<String?> getActivationKey() async {
    try {
      String directory = await FileUtils.getStringPath(_activationFileName);
      final File file = File(directory);
      DebugX.console('Reading activation key from: ${file.path}');
      
      if (await file.exists()) {
        final content = await file.readAsString();
        return content.trim(); // 去除可能的空白字符
      }
      DebugX.console('Activation key file does not exist');
      return null;
    } catch (e) {
      DebugX.console('Error reading activation key: $e');
      return null;
    }
  }

  /// 检查应用是否已激活
  static Future<bool> isAppActivated() async {
    try {
      final String? activationKey = await getActivationKey();
      DebugX.console('Checking activation with key: $activationKey');
      return await validateActivationKey(activationKey);
    } catch (e) {
      DebugX.console('Error checking activation: $e');
      return false; // 出现异常时返回未激活状态
    }
  }
}