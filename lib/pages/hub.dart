import 'package:flutter/material.dart';
import 'package:mcstatus/ui/bottomnavigationbar.dart';
import 'package:mcstatus/ui/pageview.dart';
import 'package:provider/provider.dart';

import 'package:mcstatus/provider/main.dart';

class MyHubPage extends StatefulWidget {
  const MyHubPage({super.key});

  @override
  State<MyHubPage> createState() => _MyHubPageState();
}

class _MyHubPageState extends State<MyHubPage> {
  @override
  Widget build(BuildContext context) {
    Color bottomNavigationBarColor = Colors.grey.shade200;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Minecraft Servers Status"),
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
