import 'package:escape_wild/core.dart';
import 'package:escape_wild/ui/game/shared.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

extension MoveSheetBuildContextX on BuildContext {
  Future<void> showMoveSheet({ValueChanged<Ts>? onMoved}) async {
    return await showCupertinoModalBottomSheet(
        context: this,
        enableDrag: false,
        builder: (ctx) => MoveSheet(
              initialDuration: Ts.zero,
              onMoved: onMoved,
            ));
  }
}

class MoveSheet extends StatefulWidget {
  final Ts initialDuration;
  final ValueChanged<Ts>? onMoved;

  const MoveSheet({
    super.key,
    required this.initialDuration,
    this.onMoved,
  });

  @override
  State<MoveSheet> createState() => _MoveSheetState();
}

class _MoveSheetState extends State<MoveSheet> {
  late final $cur = ValueNotifier(widget.initialDuration);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return buildStepper();
  }

  Widget buildStepper() {
    return DurationStepper(
      $cur: $cur,
      min: actionMinTime,
      max: actionMaxTime,
      step: actionStepTime,
    );
  }
}
