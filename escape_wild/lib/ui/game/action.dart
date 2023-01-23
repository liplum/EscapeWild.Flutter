import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/extension.dart';
import 'package:escape_wild/foundation.dart';
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

  Widget buildPortrait() {
    final slivers = [
      SliverAppBar(
        pinned: true,
        snap: false,
        floating: false,
        flexibleSpace: FlexibleSpaceBar(
          title: player.$location >>
              (ctx, l) => "${l?.displayName()}".text(
                    style: ctx.textTheme.headlineMedium,
                  ),
          centerTitle: true,
        ),
        actions: buildAppBarActions(),
      ),
      SliverList(
          delegate: SliverChildListDelegate([
        buildHud().padFromLTRB(5, 5, 5, 0),
        buildJourneyProgress(),
      ])),
    ];
    final actions = player.getAvailableActions();
    final Widget buttonArea;
    if (actions.length == 1) {
      final singleBtn = buildActionBtn(actions[0]).constrained(maxW: 240, maxH: 80).center();
      buttonArea = SliverToBoxAdapter(child: singleBtn);
    } else {
      buttonArea = SliverGrid.extent(
        maxCrossAxisExtent: 256,
        childAspectRatio: 3,
        children: buildActions(actions),
      );
    }
    slivers.add(SliverPadding(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      sliver: buttonArea,
    ));
    if (player.canPlayerAct()) {
      slivers.add(SliverToBoxAdapter(child: buildStepper().padFromLTRB(5, 0, 5, 5)));
    }
    return Scaffold(
      body: CustomScrollView(
        physics: const RangeMaintainingScrollPhysics(),
        slivers: slivers,
      ),
    );
  }

  Widget buildLandscape() {
    return [
      Scaffold(
        appBar: AppBar(
          title: player.$location >>
              (ctx, l) => "${l?.displayName()}".text(
                    style: ctx.textTheme.headlineMedium,
                  ),
          actions: buildAppBarActions(),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        body: [
          buildJourneyProgress(),
          buildHud(),
        ].column(maa: MainAxisAlignment.start),
      ).expanded(),
      buildActionButtonArea().expanded(),
    ].row(maa: MainAxisAlignment.spaceEvenly).safeArea().padAll(5);
  }

  Widget buildStepper() {
    return DurationStepper(
      $cur: player.$overallActionDuration,
      min: actionStepTime,
      max: actionMaxTime,
      step: actionStepTime,
    );
  }

  Widget buildActionButtonArea() {
    if (player.canPlayerAct()) {
      return [
        buildActionArea().flexible(flex: 12),
        buildStepper().flexible(flex: context.isPortrait ? 2 : 3),
      ].column();
    } else {
      return buildActionArea().expanded();
    }
  }

  Widget buildActionArea() {
    final actions = player.getAvailableActions();
    if (actions.length == 1) {
      return buildActionBtn(actions[0]).constrained(maxW: 240, maxH: 80).center();
    }
    return GridView.extent(
      physics: const RangeMaintainingScrollPhysics(),
      maxCrossAxisExtent: 256,
      childAspectRatio: 3,
      children: buildActions(actions),
    );
  }

  List<Widget>? buildAppBarActions() {
    return [
      IconButton(
        onPressed: () async {
          await context.showIngameMenuDialog();
        },
        icon: const Icon(Icons.settings),
      ),
    ];
  }

  Widget buildHud() {
    return player.$attrs >>
        (ctx, attr) => Hud(
              attrs: attr,
              textStyle: context.textTheme.headlineMedium,
              minHeight: 14,
            ).padAll(12).inCard(elevation: 2);
  }

  Widget buildJourneyProgress() {
    return player.$journeyProgress >> (ctx, p) => AttrProgress(value: p).padAll(10);
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
              await player.performAction(type);
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
          .center()
          .padAll(5),
    );
  }
}
