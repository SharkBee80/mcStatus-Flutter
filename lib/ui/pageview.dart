import 'package:flutter/material.dart';

List<Widget> PageList = [
  Text('Home'),
  Text('Info'),
  Text('Add'),
  Text('More'),
  Text('Settings'),
];

PageController pageController = PageController();

class MyPageView extends StatefulWidget {
  final int selectedIndex;
  final Function onPageChanged;

  const MyPageView({
    super.key,
    required this.selectedIndex,
    required this.onPageChanged,
  });

  @override
  State<MyPageView> createState() => _MuPageViewState();
}

class _MuPageViewState extends State<MyPageView> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          // 滑动完全结束
          final page = pageController.page?.round() ?? 0;
          if (page != _currentPage) {
            setState(() => _currentPage = page);
            print("真正停在第 ${page + 1} 页");
          }
        }
        return false;
      },
      child: PageView(
        controller: pageController,
        physics: PageScrollPhysics(),
        onPageChanged: (index) {
          widget.onPageChanged(index);
        },
        scrollDirection: Axis.horizontal,
        allowImplicitScrolling: true,
        children: [
          Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Text('You have pushed the button this many times:'),
              // Text(
              //   '$_counter',
              //   style: Theme.of(context).textTheme.headlineMedium,
              // ),
            ],
          ),
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
