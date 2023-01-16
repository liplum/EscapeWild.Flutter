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
          (player.$attrs << (ctx, attr, __) => buildHud(attr)).expanded(),
        ].column(maa: MainAxisAlignment.center),
      ).expanded(),
      buildActionButtonArea().expanded(),
    ].row(maa: MainAxisAlignment.spaceEvenly).safeArea().padAll(5);
  }

  Widget buildActionButtonArea() {
    return [
      const ActionButtonArea().flexible(flex: 12),
      ActionDurationStepper(
        $duration: player.$overallActionDuration,
        min: actionTsStep,
        max: maxActionDuration,
        step: actionTsStep,
      ).flexible(flex: 2),
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
    ).padAll(12).inCard(elevation: 2).sized(h: 240);
  }

  Widget buildJourneyProgress(double v) {
    return AttrProgress(value: v).padAll(10);
  }
}

class ActionDurationStepper extends StatefulWidget {
  final ValueNotifier<TS> $duration;
  final TS min;
  final TS max;
  final TS step;

  const ActionDurationStepper({
    super.key,
    required this.$duration,
    required this.min,
    required this.max,
    required this.step,
  });

  @override
  State<ActionDurationStepper> createState() => _ActionDurationStepperState();
}

class _ActionDurationStepperState extends State<ActionDurationStepper> {
  var isPressing = false;

  ValueNotifier<TS> get $duration => widget.$duration;

  TS get duration => widget.$duration.value;

  set duration(TS ts) => widget.$duration.value = ts;

  TS get min => widget.min;

  TS get max => widget.max;

  TS get step => widget.step;

  @override
  Widget build(BuildContext context) {
    return $duration << (ctx, ts, _) => buildBody(ts);
  }

  Widget buildBody(TS ts) {
    return [
      buildStepper(isLeft: true).flexible(flex: 1),
      I
          .ts(ts)
          .toUpperCase()
          .text(style: context.textTheme.headlineSmall, textAlign: TextAlign.end)
          .center()
          .flexible(flex: 4),
      buildStepper(isLeft: false).flexible(flex: 1),
    ].row(maa: MainAxisAlignment.spaceEvenly);
  }

  Widget buildStepper({required bool isLeft}) {
    if (isLeft) {
      return buildStepperBtn(
        Icons.arrow_left_rounded,
        canStep: () => duration > min,
        onStep: () => duration -= step,
      );
    } else {
      return buildStepperBtn(
        Icons.arrow_right_rounded,
        canStep: () => duration < max,
        onStep: () => duration += step,
      );
    }
  }

  Widget buildStepperBtn(
    IconData icon, {
    required bool Function() canStep,
    required void Function() onStep,
  }) {
    return GestureDetector(
        onLongPressStart: (_) async {
          isPressing = true;
          do {
            if (canStep()) {
              onStep();
            } else {
              break;
            }
            await Future.delayed(const Duration(milliseconds: 100));
          } while (isPressing);
        },
        onLongPressEnd: (_) => setState(() => isPressing = false),
        child: CardButton(
          elevation: canStep() ? 5 : 0,
          onTap: !canStep()
              ? null
              : () {
                  onStep();
                },
          child: buildIcon(icon),
        ));
  }

  Widget buildIcon(IconData icon) {
    const iconSize = 36.0;
    const scale = 3.0;
    return Transform.scale(
      scale: scale,
      child: Icon(icon, size: iconSize).padAll(5),
    );
  }

  @override
  void dispose() {
    super.dispose();
    isPressing = false;
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
    if (actions.length == 1) {
      return buildActionBtn(actions[0]).constrained(maxW: 240, maxH: 80).center();
    } else {
      return GridView(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 256,
          childAspectRatio: 3,
        ),
        children: buildActions(actions),
      );
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
