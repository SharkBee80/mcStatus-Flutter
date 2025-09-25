// flutter
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mcstatus/ui/card.dart';

import '../models/servers.dart';

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
        return ValueListenableBuilder(
          valueListenable: Hive.box<Servers>('servers').listenable(),
          builder: (context, Box<Servers> box, _) {
            final servers = box.values.toList();

            if (servers.isEmpty) {
              return const Center(child: Text("暂无服务器"));
            }

            return GridView.count(
              padding: const EdgeInsets.all(4),
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              childAspectRatio: 8 / 3,
              children: servers
                  .map((s) => XCard(title: s.name, address: s.address))
                  .toList(),
            );
          },
        );
      },
    );
  }
}
