import 'package:flutter/material.dart';

class VerticalIconButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;
  final bool isActive;

  const VerticalIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isSelected,
    this.isActive = true,
  });

  @override
  State<VerticalIconButton> createState() => _VerticalIconButtonState();
}

class _VerticalIconButtonState extends State<VerticalIconButton> {
  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.inversePrimary;

    final displayColor = widget.isActive
        ? color
        : Theme.of(context).colorScheme.primary; //Colors.grey;

    return TextButton(
      onPressed: widget.isActive
          ? () {
              widget.onPressed();
            }
          : null,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        // iconColor: Theme.of(context).colorScheme.inversePrimary,
        // textStyle: TextStyle(
        //   color: Theme.of(context).colorScheme.inversePrimary,
        // ),
      ),
      child: SizedBox(
        width: MediaQuery.widthOf(context) / 5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 28, color: displayColor),
            SizedBox(height: 2),
            Text(widget.label, style: TextStyle(color: displayColor)),
          ],
        ),
      ),
    );
  }
}

//
// class WhiteSpace extends StatelessWidget {
//   const WhiteSpace({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     double bottomBarButtonWidth = MediaQuery.widthOf(context) / 5 / 2;
//     return Container(
//       width: bottomBarButtonWidth,
//       height: kBottomNavigationBarHeight - 10,
//       padding: EdgeInsets.zero,
//     );
//   }
// }
