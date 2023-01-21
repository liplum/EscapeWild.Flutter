import 'package:escape_wild/core.dart';
import 'package:escape_wild/ui/game/shared.dart';
import 'package:flutter/material.dart';

/*
Future<Ts>  */

class MoveSheet extends StatefulWidget {
  final Ts initialDuration;
  final ValueChanged<Ts> onMoved;

  const MoveSheet({
    super.key,
    required this.initialDuration,
    required this.onMoved,
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
