import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/core/attribute.dart';
import 'package:escape_wild/r.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:rettulf/rettulf.dart';

part 'hud.i18n.dart';

class Hud extends StatefulWidget {
  final AttrModel attr;

  const Hud({
    super.key,
    required this.attr,
  });

  @override
  State<Hud> createState() => _HudState();
}

class _HudState extends State<Hud> {
  AttrModel get attr => widget.attr;

  @override
  Widget build(BuildContext context) {
    return LayoutGrid(
      columnSizes: [auto, 1.5.fr],
      rowSizes: const [auto, auto, auto, auto],
      children: [
        label(Attr.health),
        buildBar(attr.health, R.healthColor),
        label(Attr.food),
        buildBar(attr.food, R.foodColor),
        label(Attr.water),
        buildBar(attr.water, R.waterColor),
        label(Attr.energy),
        buildBar(attr.energy, R.energyColor),
      ],
    );
  }

  Widget label(Attr attr) {
    return _I.attr(attr).text(style: context.textTheme.headlineLarge).center();
  }

  Widget buildBar(double value, Color color) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: AttrProgress(
        value: value,
        color: color,
        curve: Curves.fastLinearToSlowEaseIn,
        duration: const Duration(milliseconds: 1200),
      ),
    ).center().padSymmetric(h: 12);
  }
}

class AttrProgress extends ImplicitlyAnimatedWidget {
  final double value;
  final Color color;

  const AttrProgress({
    super.key,
    required super.duration,
    required this.value,
    required this.color,
    super.curve,
  });

  @override
  ImplicitlyAnimatedWidgetState<AttrProgress> createState() => _AttrProgressState();
}

class _AttrProgressState extends AnimatedWidgetBaseState<AttrProgress> {
  late Tween<double> $progress;

  @override
  void initState() {
    $progress = Tween<double>(
      begin: 0,
      end: widget.value,
    );
    super.initState();
    if ($progress.begin != $progress.end) {
      controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildBar($progress.evaluate(animation));
  }

  Widget buildBar(double v) {
    return LinearProgressIndicator(
      value: v,
      minHeight: 8,
      color: widget.color,
      backgroundColor: Colors.grey.withOpacity(0.2),
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    $progress = visitor($progress, widget.value, (dynamic value) {
      assert(false);
      throw StateError('Constructor will never be called because null is never provided as current tween.');
    }) as Tween<double>;
  }
}
