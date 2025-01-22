import 'package:escape_wild/app.dart';
import 'package:escape_wild/core/index.dart';
import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/ui/game/shared.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rettulf/rettulf.dart';

Future<void> showMoveSheet({ValueChanged<Ts>? onMoved}) async {
  return await showCupertinoModalBottomSheet(
    context: $context,
    builder: (ctx) {
      final sheet = MoveSheet(
        initialDuration: actionDefaultTime,
        onMove: onMoved,
      );
      final size = $context.mediaQuery.size;
      if ($context.isPortrait) {
        return sheet.constrained(maxH: size.height * 0.4);
      } else {
        return sheet.constrained(maxH: size.height * 0.5);
      }
    },
  );
}

class MoveSheet extends StatefulWidget {
  final Ts initialDuration;
  final ValueChanged<Ts>? onMove;

  const MoveSheet({
    super.key,
    required this.initialDuration,
    this.onMove,
  });

  @override
  State<MoveSheet> createState() => _MoveSheetState();
}

class _MoveSheetState extends State<MoveSheet> {
  late final $cur = ValueNotifier(widget.initialDuration);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: "Forward".text(),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.navigator.pop();
          },
        ),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return [
      buildStepper(),
      buildMoveBtn(),
    ].column(mas: MainAxisSize.min);
  }

  Widget buildMoveBtn() {
    final onMove = widget.onMove;
    return CardButton(
      elevation: onMove != null ? 10 : 0,
      onTap: onMove == null
          ? null
          : () {
              onMove($cur.value);
            },
      child: UserAction.move
          .l10nName()
          .toUpperCase()
          .autoSizeText(
            maxLines: 1,
            minFontSize: 8,
            style: context.textTheme.headlineSmall?.copyWith(
              color: onMove != null ? null : Colors.grey,
            ),
          )
          .padAll(5),
    );
  }

  Widget buildStepper() {
    return DurationStepper(
      $cur: $cur,
      min: actionMinTime,
      max: actionMaxTime,
      step: actionStepTime,
    );
  }

  @override
  void dispose() {
    $cur.dispose();
    super.dispose();
  }
}
