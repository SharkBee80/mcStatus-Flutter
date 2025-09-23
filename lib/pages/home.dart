import 'package:flutter/material.dart';
import 'package:mcstatus/ui/verticalIconButton.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  int _selectedIndex = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Minecraft Servers Status"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: 80,
        height: 80,
        child: FloatingActionButton(
          onPressed: _incrementCounter,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // tooltip: 'Increment',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(90),
          ),
          child: Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        padding: EdgeInsets.zero,
        child: SizedBox(
          // height: kBottomNavigationBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              VerticalIconButton(
                icon: Icons.home,
                label: 'Home',
                isSelected: _selectedIndex == 0,
                onPressed: () => onTap(0),
              ),
              VerticalIconButton(
                icon: Icons.request_page,
                label: 'Info',
                isSelected: _selectedIndex == 1,
                onPressed: () => onTap(1),
              ),
              VerticalIconButton(
                icon: Icons.person,
                label: 'Add',
                isSelected: _selectedIndex == 2,
                isActive: false,
                onPressed: () => onTap(2),
              ),
              VerticalIconButton(
                icon: Icons.more_horiz,
                label: 'More',
                isSelected: _selectedIndex == 3,
                onPressed: () => onTap(3),
              ),
              VerticalIconButton(
                icon: Icons.settings,
                label: 'Settings',
                isSelected: _selectedIndex == 4,
                onPressed: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
