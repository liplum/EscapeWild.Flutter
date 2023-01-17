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
    return context.isPortrait ? buildPortrait2() : buildLandscape();
  }

  Widget buildPortrait2() {
    return Scaffold(
      body: CustomScrollView(
        physics: const RangeMaintainingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            snap: false,
            floating: false,
            flexibleSpace: FlexibleSpaceBar(
              title: player.$location <<
                  (ctx, l, __) => "${l?.displayName()}".text(
                        style: ctx.textTheme.headlineMedium,
                      ),
              centerTitle: true,
            ),
            actions: buildAppBarActions(),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            player.$attrs << (ctx, attr, __) => buildHud(attr).padFromLTRB(5, 5, 5, 0),
            player.$journeyProgress << (ctx, p, _) => buildJourneyProgress(p),
          ])),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
            sliver: ActionButtonArea(sliver: true),
          ),
          SliverToBoxAdapter(child: buildStepper().padFromLTRB(5, 0, 5, 5)),
        ],
      ),
    );
  }

  Widget buildStepper() {
    if (!player.canPlayerAct()) {
      return const SizedBox();
    }
    return DurationStepper(
      $duration: player.$overallActionDuration,
      min: actionTsStep,
      max: maxActionDuration,
      step: actionTsStep,
    );
  }

  Widget buildPortrait() {
    return Scaffold(
      appBar: AppBar(
        title: player.$location <<
            (ctx, l, __) => "${l?.displayName()}".text(
                  style: ctx.textTheme.headlineMedium,
                ),
        centerTitle: true,
        actions: buildAppBarActions(),
      ),
      body: [
        player.$attrs << (ctx, attr, __) => buildHud(attr),
        player.$journeyProgress << (ctx, p, _) => buildJourneyProgress(p),
        buildActionButtonArea().expanded(),
      ].column().padAll(5),
    );
  }

  Widget buildLandscape() {
    return [
      Scaffold(
        appBar: AppBar(
          title: player.$location <<
              (ctx, l, __) => "${l?.displayName()}".text(
                    style: ctx.textTheme.headlineMedium,
                  ),
          actions: buildAppBarActions(),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        body: [
          player.$journeyProgress << (ctx, p, _) => buildJourneyProgress(p),
          (player.$attrs << (ctx, attr, __) => buildHud(attr)),
        ].column(maa: MainAxisAlignment.start),
      ).expanded(),
      buildActionButtonArea().expanded(),
    ].row(maa: MainAxisAlignment.spaceEvenly).safeArea().padAll(5);
  }

  Widget buildActionButtonArea() {
    return [
      const ActionButtonArea(sliver: false).flexible(flex: 12),
      DurationStepper(
        $duration: player.$overallActionDuration,
        min: actionTsStep,
        max: maxActionDuration,
        step: actionTsStep,
      ).flexible(flex: context.isPortrait ? 2 : 3),
    ].column();
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

  Widget buildHud(AttrModel attr) {
    return Hud(
      attrs: attr,
      textStyle: context.textTheme.headlineMedium,
      minHeight: 14,
    ).padAll(12).inCard(elevation: 2);
  }

  Widget buildJourneyProgress(double v) {
    return AttrProgress(value: v).padAll(10);
  }
}

class ActionButtonArea extends StatefulWidget {
  final bool sliver;

  const ActionButtonArea({
    super.key,
    required this.sliver,
  });

  @override
  State<ActionButtonArea> createState() => _ActionButtonAreaState();
}

class _ActionButtonAreaState extends State<ActionButtonArea> {
  @override
  Widget build(BuildContext context) {
    final actions = player.getAvailableActions();
    if (actions.length == 1) {
      final singleBtn = buildActionBtn(actions[0]).constrained(maxW: 240, maxH: 80).center();
      if (widget.sliver) {
        return SliverToBoxAdapter(
          child: singleBtn,
        );
      } else {
        return singleBtn;
      }
    } else {
      if (widget.sliver) {
        return SliverGrid.extent(
          maxCrossAxisExtent: 256,
          childAspectRatio: 3,
          children: buildActions(actions),
        );
      } else {
        return GridView.extent(
          physics: const RangeMaintainingScrollPhysics(),
          maxCrossAxisExtent: 256,
          childAspectRatio: 3,
          children: buildActions(actions),
        );
      }
    }
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
          .center()
          .padAll(5),
    );
  }
}
