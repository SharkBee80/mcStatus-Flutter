import 'package:flutter/material.dart';
import 'package:mcstatus/ui/verticalIconButton.dart';

class XBottomNavigationBar extends StatelessWidget {
  final Function onTap;
  final int selectedIndex;
  final Color? color;

  const XBottomNavigationBar({
    super.key,
    required this.onTap,
    required this.selectedIndex,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => onTap(0),
            ),
            VerticalIconButton(
              icon: Icons.request_page,
              label: 'Info',
              isSelected: selectedIndex == 1,
              onPressed: () => onTap(1),
            ),
            VerticalIconButton(
              icon: Icons.person,
              label: 'Add',
              isSelected: selectedIndex == 2,
              isActive: false,
              onPressed: () => onTap(2),
            ),
            VerticalIconButton(
              icon: Icons.more_horiz,
              label: 'More',
              isSelected: selectedIndex == 3,
              onPressed: () => onTap(3),
            ),
            VerticalIconButton(
              icon: Icons.settings,
              label: 'Settings',
              isSelected: selectedIndex == 4,
              onPressed: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}
