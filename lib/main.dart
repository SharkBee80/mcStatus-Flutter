// flutter
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:mcstatus/provider/main.dart';
import 'package:oktoast/oktoast.dart';

// provider
import 'package:provider/provider.dart';

// mcstatus
import 'package:mcstatus/pages/gate.dart';
import 'package:mcstatus/utils/files_utils.dart';
import 'package:mcstatus/utils/debug.dart';

// hive
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mcstatus/models/servers.dart';
import 'package:mcstatus/models/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    DebugX.console('Initializing Hive...');
    await Hive.initFlutter(await FileUtils.getStringPath("hive"));

    DebugX.console('Registering Servers adapter...');
    Hive.registerAdapter(ServersAdapter());
    await Hive.openBox<Servers>('servers');

    // 安全初始化Settings
    try {
      DebugX.console('Registering Settings adapter...');
      Hive.registerAdapter(SettingsAdapter());
      await Hive.openBox<Settings>('settings');
      DebugX.console('Settings box opened successfully');
    } catch (e) {
      DebugX.console('设置数据初始化失败，清除旧数据: $e');
      // 删除损坏的设置文件
      try {
        await Hive.deleteBoxFromDisk('settings');
        await Hive.openBox<Settings>('settings');
        DebugX.console('Settings box recreated successfully');
      } catch (deleteError) {
        DebugX.console('Failed to recreate settings box: $deleteError');
      }
    }

    DebugX.console('Starting app...');
    runApp(MyApp());
  } catch (e) {
    DebugX.console('Critical error during app initialization: $e');
    // 如果初始化完全失败，仍然尝试启动基础应用
    runApp(ErrorApp(error: e.toString()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
      position: ToastPosition(align: Alignment.topCenter),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => Counter()),
          ChangeNotifierProvider(
            create: (context) {
              final provider = PageViewProvider();
              // 在下一个frame初始化，确保Hive已经准备好
              WidgetsBinding.instance.addPostFrameCallback((_) {
                provider.init().catchError((e) {
                  DebugX.console('PageViewProvider init error: $e');
                });
              });
              return provider;
            },
          ),
        ],
        child: MaterialApp(
          title: 'MCStatus',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          home: const GatePage(),
          scrollBehavior: MyCustomScrollBehavior(),
        ),
      ),
    );
  }
}

/// 错误处理应用
class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCStatus - Error',
      home: Scaffold(
        appBar: AppBar(title: const Text('初始化错误')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                '应用初始化失败',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                error,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // 尝试重新启动应用
                  main();
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse, // ✅ 允许鼠标拖拽
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}
