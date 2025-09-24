// flutter
import 'package:flutter/material.dart';
import 'package:mcstatus/ui/card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const minWidth = 320.0; // 规定最小宽度
        int crossAxisCount = (constraints.maxWidth / minWidth).floor();
        if (crossAxisCount < 1) crossAxisCount = 1;

        return GridView.count(
          padding: const EdgeInsets.all(4),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          childAspectRatio: 8 / 3,
          children: <Widget>[
            XCard(title: "Hypix"),
            XCard(title: "Hypixel Network",description: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaajdjhuffifliusidhfkSNsbduefeifhauslaskdlwwofjabiwdjfhjfhjfhjfhjfhjfhjfhjfhjfhjfhjfhjfhjfhjfhjfhjfhjfhjfhjfhjfhjfhjfhjfhjfhjfhjfhjfhjfhjfhjfhjfhj',),
            XCard(title: "Hypixel Netsdfegsasdwork",players: "000000 / 0000",),
          ],
        );
      },
    );
  }
}
