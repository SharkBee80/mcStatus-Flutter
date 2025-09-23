import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mcstatus/pages/home.dart';
import 'package:mcstatus/utils/activator.dart';
import 'package:mcstatus/pages/activation.dart';

class GatePage extends StatefulWidget {
  const GatePage({super.key});

  @override
  State<GatePage> createState() => _GatePageState();
}

class _GatePageState extends State<GatePage> {
  bool _isChecked = false;
  bool _isActivated = false;

  @override
  void initState() {
    super.initState();
    _checkActivation();
  }

  /// 检查应用是否已激活
  Future<void> _checkActivation() async {
    try {
      final bool activated = await Activator.isAppActivated();
      if (mounted) {
        setState(() {
          _isActivated = activated;
          _isChecked = true;
        });

        if (activated) {
          _navigateToPlatformPage();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isChecked = true;
        });
      }
    }
  }

  /// 根据平台类型导航到相应页面
  void _navigateToPlatformPage() {
    // 检测是否为桌面平台
    bool isDesktop = kIsWeb
        ? false
        : (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // builder: (context) => isDesktop
          //   ? const DesktopPage()
          //   : const MobilePage(),
          builder: (context) => const MyHomePage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isChecked) {
      // 检查激活状态中
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isActivated) {
      // 未激活，导航到激活页面
      return const ActivationPage();
    }

    // 已激活，显示加载指示器并准备导航
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
