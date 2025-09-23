import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/main.dart';

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
            color: Colors.green,
            child: Center(child: Text("Page 2")),
          ),
          Container(
            color: Colors.blue,
            child: Center(child: Text("Page 3")),
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
