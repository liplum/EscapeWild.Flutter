import 'package:escape_wild/core.dart';
import 'package:escape_wild/ui/game/shared.dart';
import 'package:flutter/material.dart';

/*
Future<Ts>  */

class ActionTsSelector extends StatefulWidget {
  final Ts initial;
  final Ts min;
  final Ts max;
  final Ts step;

  const ActionTsSelector({
    super.key,
    required this.initial,
    required this.min,
    required this.max,
    required this.step,
  });

  @override
  State<ActionTsSelector> createState() => _ActionTsSelectorState();
}

class _ActionTsSelectorState extends State<ActionTsSelector> {
  late final $cur = ValueNotifier(widget.initial);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  Widget buildStepper() {
    return DurationStepper(
      $cur: $cur,
      min: actionTsStep,
      max: maxActionDuration,
      step: actionTsStep,
    );
  }
}
