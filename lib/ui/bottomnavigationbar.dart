import 'package:flutter/material.dart';
import 'package:mcstatus/ui/verticaliconbutton.dart';
import 'package:provider/provider.dart';

import '../provider/main.dart';

class XBottomNavigationBar extends StatelessWidget {
  final Color? color;

  const XBottomNavigationBar({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.watch<PageViewProvider>().selectedIndex;
    return BottomAppBar(
      // shape: CircularNotchedRectangle(),
      padding: EdgeInsets.zero,
      color: color,
      child: SizedBox(
        // height: kBottomNavigationBarHeight,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            VerticalIconButton(
              icon: Icons.home,
              label: 'Home',
              isSelected: selectedIndex == 0,
              onPressed: () => onTap(context, 0),
            ),
            VerticalIconButton(
              icon: Icons.request_page,
              label: 'Info',
              isSelected: selectedIndex == 1,
              onPressed: () => onTap(context, 1),
            ),
            VerticalIconButton(
              icon: Icons.add,
              label: 'Add',
              isSelected: false,
              isActive: false,
              onPressed: () => {},
            ),
            VerticalIconButton(
              icon: Icons.more_horiz,
              label: 'More',
              isSelected: selectedIndex == 2,
              onPressed: () => onTap(context, 2),
            ),
            VerticalIconButton(
              icon: Icons.settings,
              label: 'Settings',
              isSelected: selectedIndex == 3,
              onPressed: () => onTap(context, 3),
            ),
          ],
        ),
      ),
    );
  }

  void onTap(BuildContext context, int index) {
    if (index != context.read<PageViewProvider>().selectedIndex) {
      context.read<PageViewProvider>().setSelectedIndex(index);
      context.read<PageViewProvider>().pageController.jumpToPage(index);

      // 清除当前回调，由新页面重新注册
      context.read<PageViewProvider>().setRefreshCallback(index, null);
      print('底部导航点击，切换到页面: $index，已清除回调'); // 调试信息
    }
  }
}
