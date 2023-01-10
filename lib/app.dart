import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild_flutter/core/attribute.dart';
import 'package:escape_wild_flutter/ui/hud.dart';
import 'package:escape_wild_flutter/utils/random.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
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
  void increment() {
    setState(() {
      attr = attr.copyWith(
        health: up(attr.health),
        food: up(attr.food),
        water: up(attr.water),
        energy: up(attr.energy),
      );
    });
  }

  void decrement() {
    setState(() {
      attr = attr.copyWith(
        health: down(attr.health),
        food: down(attr.food),
        water: down(attr.water),
        energy: down(attr.energy),
      );
    });
  }

  double up(double raw) {
    return (raw + Rand.float(0, 0.08)).clamp(0, 1);
  }

  double down(double raw) {
    return (raw + Rand.float(-0.08, 0)).clamp(0, 1);
  }

  var attr = const AttrModel.all(0.5);
  var isAdd = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Hud(attr: attr).padAll(12).inCard().sized(h: 240).padAll(10),
      floatingActionButton: [
        FloatingActionButton(
          onPressed: increment,
          child: const Icon(Icons.add),
        ),
        FloatingActionButton(
          onPressed: decrement,
          child: const Icon(Icons.remove),
        ),
      ].row(maa: MainAxisAlignment.center), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
