import 'package:escape_wild/core/index.dart';
import 'package:escape_wild/design/extension.dart';
import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/ui/game/in_game_menu.dart';
import 'package:escape_wild/ui/game/shared.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';
import 'package:tabler_icons/tabler_icons.dart';

import 'hud.dart';

class GameActionPage extends StatefulWidget {
  const GameActionPage({super.key});

  @override
  State<GameActionPage> createState() => _GameActionPageState();
}

class _GameActionPageState extends State<GameActionPage> {
  @override
  void initState() {
    super.initState();
    player.addListener(refresh);
  }

  @override
  void dispose() {
    player.removeListener(refresh);
    super.dispose();
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final actions = player.getAvailableActions();
    return Scaffold(
      body: CustomScrollView(
        physics: const RangeMaintainingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            snap: false,
            floating: false,
            flexibleSpace: FlexibleSpaceBar(
              title: "${player.location?.displayName()}".text(style: context.textTheme.headlineMedium),
              centerTitle: true,
            ),
            actions: buildAppBarActions(),
          ),
          SliverList(delegate: SliverChildListDelegate([buildHud().padFromLTRB(5, 5, 5, 0), buildJourneyProgress()])),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            sliver: actions.length == 1
                ? SliverToBoxAdapter(child: buildActionBtn(actions[0]).constrained(maxW: 240, maxH: 80).center())
                : SliverGrid.extent(maxCrossAxisExtent: 256, childAspectRatio: 3, children: buildActions(actions)),
          ),
        ],
      ),
    );
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
        icon: const Icon(TablerIcons.settings),
      ),
    ];
  }

  Widget buildHud() {
    return Hud(attrs: player.attrs, textStyle: context.textTheme.headlineMedium, minHeight: 14).padAll(12);
  }

  Widget buildJourneyProgress() {
    return AttrProgress(value: player.journeyProgress).padAll(10);
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
            },
      child: type
          .l10nName()
          .toUpperCase()
          .autoSizeText(
            maxLines: 1,
            minFontSize: 8,
            style: context.textTheme.headlineSmall?.copyWith(color: canPerform ? null : Colors.grey),
          )
          .center()
          .padAll(5),
    );
  }
}
