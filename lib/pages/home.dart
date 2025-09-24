// flutter
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              color: Colors.red,
              child: SizedBox(
                height: MediaQuery.widthOf(context) * 9 / 16 / 2,
                width: MediaQuery.widthOf(context) / 2,
                child: Row(children: [Column(), Column(), Column()]),
              ),
            ),
            SizedBox(height: 1000),
            ListTile(title: Text("About"), leading: Icon(Icons.info)),
          ],
        ),
    );
  }
}
