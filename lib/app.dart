import 'package:escape_wild_flutter/core/attribute.dart';
import 'package:escape_wild_flutter/ui/hud.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _incrementCounter() {
    setState(() {
      if (attr.health <= 0) {
        isAdd = true;
      } else if (attr.health >= 1) {
        isAdd = false;
      }
      attr = attr.copyWith(
        health: attr.health + (isAdd ? 0.05 : -0.05),
      );
    });
  }

  var attr = AttrModel();
  var isAdd = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Hud(attr: attr).sized(h: 180),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
