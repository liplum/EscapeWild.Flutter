import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/theme.dart';
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
        title: player.$location << (ctx, l, __) => ">> ${l?.displayName()} <<".text(),
        centerTitle: true,
      ),
      body: buildBody(),
    );
  }

  Widget buildHud(AttrModel attr) {
    return Hud(attr: attr).padAll(12).inCard().sized(h: 240);
  }

  Widget buildBody() {
    return [
      player.$attrs << (ctx, attr, __) => buildHud(attr),
      player.$journeyProgress << (ctx, p, _) => buildJourneyProgress(p),
      buildActionBtnArea().expanded(),
    ].column().padAll(10);
  }

  Widget buildJourneyProgress(double v) {
    return AttrProgress(value: v).padAll(10);
  }

  Widget buildActionBtnArea() {
    return GridView(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 180, childAspectRatio: 2),
      children: buildActions(),
    );
  }

  List<Widget> buildActions() {
    var res = <Widget>[];
    for (final action in player.getAvailableActions()) {
      res.add(buildActionBtn(action));
    }
    return res;
  }

  Widget buildActionBtn(ActionType action) {
    return InkWell(
      borderRadius: context.cardBorderRadius,
      onTap: () async {
        player.performAction(action);
      },

      child: action
          .localizedName()
          .text(
            style: context.textTheme.headlineSmall,
          )
          .center(),
    ).inCard();
  }
}
