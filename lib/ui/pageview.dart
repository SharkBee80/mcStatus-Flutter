import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mcstatus/pages/home.dart';
import 'package:mcstatus/pages/info.dart';
import 'package:mcstatus/provider/main.dart';

class MyPageView extends StatefulWidget {
  final int selectedIndex;

  const MyPageView({super.key, required this.selectedIndex});

  @override
  State<MyPageView> createState() => _MuPageViewState();
}

class _MuPageViewState extends State<MyPageView> {
  int _currentPage = 0;

  /// 触发页面刷新回调注册
  void _triggerPageRefreshRegistration(BuildContext context, int pageIndex) {
    print('触发页面 $pageIndex 的刷新回调注册'); // 调试信息

    // 通知当前页面重新注册刷新回调
    switch (pageIndex) {
      case 0: // Home页面
        // Home页面会在自己的initState中注册
        break;
      case 1: // Info页面
        // Info页面会在自己的initState中注册
        break;
      default:
        // 其他页面暂无刷新功能
        // 不需要做任何操作
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageController = context.watch<PageViewProvider>().pageController;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          // 滑动完全结束
          final page = pageController.page?.round() ?? 0;
          if (page != _currentPage) {
            _currentPage = page;
          }
        }
        return false;
      },
      child: PageView(
        controller: pageController,
        physics: PageScrollPhysics(),
        onPageChanged: (index) {
          context.read<PageViewProvider>().setSelectedIndex(index);
          pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        },
        scrollDirection: Axis.horizontal,
        allowImplicitScrolling: true,
        children: [
          HomePage(),
          InfoPage(),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Text('You have pushed the button this many times:'),
              Text(
                context.watch<Counter>().counter.toString(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          Container(
            color: Colors.yellow,
            child: Center(child: Text("Page 4")),
          ),
        ],
      ),
    );
  }
}
