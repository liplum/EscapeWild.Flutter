import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/extension.dart';
import 'package:escape_wild/ui/game/ingame_menu.dart';
import 'package:escape_wild/ui/game/shared.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';

import 'hud.dart';

class ActionPage extends StatefulWidget {
  const ActionPage({Key? key}) : super(key: key);

  @override
  State<ActionPage> createState() => _ActionPageState();
}

class _ActionPageState extends State<ActionPage> {
  @override
  Widget build(BuildContext context) {
    return context.isPortrait ? buildPortrait() : buildLandscape();
  }

  Widget buildLandscape() {
    return [
      Scaffold(
        appBar: AppBar(
          title: player.$location <<
              (ctx, l, __) => "${l?.displayName()}".text(
                    style: ctx.textTheme.headlineMedium,
                  ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        body: [
          player.$journeyProgress << (ctx, p, _) => buildJourneyProgress(p),
          (player.$attrs << (ctx, attr, __) => buildHud(attr)).expanded(),
        ].column(maa: MainAxisAlignment.center),
      ).expanded(),
      const ActionButtonArea().expanded(),
    ].row(maa: MainAxisAlignment.spaceEvenly).safeArea().padAll(5);
  }

  Widget buildPortrait() {
    return Scaffold(
      appBar: AppBar(
        title: player.$location <<
            (ctx, l, __) => "${l?.displayName()}".text(
                  style: ctx.textTheme.headlineMedium,
                ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await context.showIngameMenuDialog();
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: [
        player.$attrs << (ctx, attr, __) => buildHud(attr),
        player.$journeyProgress << (ctx, p, _) => buildJourneyProgress(p),
        const ActionButtonArea().expanded(),
      ].column().padAll(5),
    );
  }

  Widget buildHud(AttrModel attr) {
    return Hud(
      attrs: attr,
      textStyle: context.textTheme.headlineMedium,
    ).padAll(12).inCard(elevation: 2).sized(h: 240);
  }

  Widget buildJourneyProgress(double v) {
    return AttrProgress(value: v).padAll(10);
  }
}

class ActionButtonArea extends StatefulWidget {
  const ActionButtonArea({super.key});

  @override
  State<ActionButtonArea> createState() => _ActionButtonAreaState();
}

class _ActionButtonAreaState extends State<ActionButtonArea> {
  @override
  Widget build(BuildContext context) {
    final actions = player.getAvailableActions();
    /*if (actions.length == 1) {
      return buildActionBtn(actions[0]).sized(w:180,h:40).container();
    } else {*/
    return GridView(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 256,
        childAspectRatio: 3,
      ),
      children: buildActions(actions),
    );
    /*}*/
  }

  List<Widget> buildActions(List<PlaceAction> actions) {
    var res = <Widget>[];
    for (final action in actions) {
      res.add(buildActionBtn(action));
    }
    return res;
  }

  Widget buildActionBtn(PlaceAction action) {
    final type = action.type;
    final canPerform = action.canPerform();
    return CardButton(
      elevation: canPerform ? 10 : 0,
      onTap: !canPerform
          ? null
          : () async {
              player.performAction(type);
              if (!mounted) return;
              // force to refresh the area, because it's hard to listen to all changes of player.
              setState(() {});
            },
      child: type
          .l10nName()
          .toUpperCase()
          .autoSizeText(
            maxLines: 1,
            minFontSize: 8,
            style: context.textTheme.headlineSmall?.copyWith(
              color: canPerform ? null : Colors.grey,
            ),
          )
          .center().padAll(5),
    );
  }
}
