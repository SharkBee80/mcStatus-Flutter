import 'package:flutter/material.dart';
import 'package:mcstatus/ui/bottomnavigationbar.dart';
import 'package:mcstatus/ui/pageview.dart';
import 'package:provider/provider.dart';

import 'package:mcstatus/provider/main.dart';

import 'package:mcstatus/ui/showcentraldialog.dart';

class MyHubPage extends StatefulWidget {
  const MyHubPage({super.key});

  @override
  State<MyHubPage> createState() => _MyHubPageState();
}

class _MyHubPageState extends State<MyHubPage> {
  /// 获取刷新按钮的提示文字
  String _getRefreshTooltip(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return '刷新服务器状态';
      case 1:
        return '刷新信息页面';
      case 2:
        return '刷新More页面';
      case 3:
        return '刷新设置页面';
      default:
        return '刷新';
    }
  }
  @override
  Widget build(BuildContext context) {
    Color bottomNavigationBarColor = Colors.grey.shade200;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Minecraft Servers Status"),
        actions: [
          Consumer<PageViewProvider>(
            builder: (context, provider, child) {
              if (provider.isMovingMode) {
                // 移动模式：显示取消按钮
                return IconButton(
                  onPressed: () => provider.cancelMove(),
                  icon: const Icon(Icons.close),
                  tooltip: '取消移动',
                );
              } else {
                // 正常模式：显示刷新按钮
                return IconButton(
                  onPressed: () => provider.refresh(),
                  icon: const Icon(Icons.refresh),
                  tooltip: _getRefreshTooltip(provider.selectedIndex),
                );
              }
            },
          ),
        ],
      ),
      // body: Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.start,
      //     children: <Widget>[
      //       const Text('You have pushed the button this many times:'),
      //       Text(
      //         '$_counter',
      //         style: Theme.of(context).textTheme.headlineMedium,
      //       ),
      //     ],
      //   ),
      // ),
      body: MyPageView(
        selectedIndex: context.watch<PageViewProvider>().selectedIndex,
      ),

      floatingActionButton: Container(
        width: 80,
        height: 80,
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.fromLTRB(0, 16, 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(90),
          color: bottomNavigationBarColor,
        ),
        child: FloatingActionButton(
          // onPressed: () => Provider.of<Counter>(context, listen: false).increment(),
          onPressed: () {
            context.read<Counter>().increment();
            showCentralDialog(context);
          },
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // tooltip: 'Increment',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(90),
          ),
          child: Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: XBottomNavigationBar(
        color: bottomNavigationBarColor,
      ),
    );
  }
}
