import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mcstatus/pages/home.dart';
import 'package:mcstatus/pages/info.dart';
import 'package:mcstatus/pages/settings.dart';
import 'package:mcstatus/provider/main.dart';

/// More页面组件（支持保活）
class _MorePage extends StatefulWidget {
  const _MorePage();

  @override
  State<_MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<_MorePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // 保持页面活跃状态

  @override
  Widget build(BuildContext context) {
    super.build(context); // 保持页面活跃状态必需的调用
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const Text('You have pushed the button this many times:'),
        Text(
          context.watch<Counter>().counter.toString(),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }
}


class MyPageView extends StatefulWidget {
  final int selectedIndex;

  const MyPageView({super.key, required this.selectedIndex});

  @override
  State<MyPageView> createState() => _MuPageViewState();
}

class _MuPageViewState extends State<MyPageView> {
  int _currentPage = 0;

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
          _MorePage(), // 使用独立的组件并支持保活
          SettingsPage(),
        ],
      ),
    );
  }
}
