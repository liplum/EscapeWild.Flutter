import 'package:escape_wild/core.dart';
import 'package:escape_wild/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';

import 'hud.dart';

class ActionPage extends StatefulWidget {
  const ActionPage({Key? key}) : super(key: key);

  @override
  State<ActionPage> createState() => _ActionPageState();
}

class _ActionPageState extends State<ActionPage> {
  void increment() {
    setState(() {
      attr = AttrModel(
        health: up(attr.health),
        food: up(attr.food),
        water: up(attr.water),
        energy: up(attr.energy),
      );
    });
  }

  void decrement() {
    setState(() {
      attr = AttrModel(
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

  AttrModel get attr => player.attrs;

  set attr(AttrModel v) => player.attrs = v;
  var isAdd = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: player.$location << (ctx, l, __) => ">> ${l?.localizedName()} <<".text(),
        centerTitle: true,
      ),
      body: buildBody(),
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

  Widget buildHud(AttrModel attr) {
    return Hud(attr: attr).padAll(12).inCard().sized(h: 240).padAll(10);
  }

  Widget buildBody() {
    return [
      player.$attrs << (ctx, attr, __) => buildHud(attr),
      player.$journeyProgress << (ctx, p, _) => buildJourneyProgress(p),
    ].column();
  }

  Widget buildJourneyProgress(double v) {
    return AttrProgress(value: v).padAll(10);
  }
}
