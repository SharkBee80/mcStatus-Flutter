// flutter
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:mcstatus/provider/main.dart';

// provider
import 'package:provider/provider.dart';

// mcstatus
import 'package:mcstatus/pages/gate.dart';
import 'package:mcstatus/utils/files_utils.dart';

// hive
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mcstatus/models/servers.dart';
import 'package:mcstatus/models/settings.dart';

void main() async {
  await Hive.initFlutter(await FileUtils.getStringPath("hive"));
  Hive.registerAdapter(ServersAdapter());
  await Hive.openBox<Servers>('servers');

  // 安全初始化Settings
  try {
    Hive.registerAdapter(SettingsAdapter());
    await Hive.openBox<Settings>('settings');
  } catch (e) {
    print('设置数据初始化失败，清除旧数据: $e');
    // 删除损坏的设置文件
    await Hive.deleteBoxFromDisk('settings');
    await Hive.openBox<Settings>('settings');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Counter()),
        ChangeNotifierProvider(
          create: (context) {
            final provider = PageViewProvider();
            // 在下一个frame初始化，确保Hive已经准备好
            WidgetsBinding.instance.addPostFrameCallback((_) {
              provider.init();
            });
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Flutter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const GatePage(),
        scrollBehavior: MyCustomScrollBehavior(),
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
