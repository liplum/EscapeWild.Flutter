import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild_flutter/core/attribute.dart';
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
        buildBar(attr.health),
        label(Attr.food),
        buildBar(attr.food),
        label(Attr.water),
        buildBar(attr.water),
        label(Attr.energy),
        buildBar(attr.energy),
      ],
    );
  }

  Widget label(Attr attr) {
    return _I.attr(attr).text(style: context.textTheme.headlineLarge).center();
  }

  Widget buildBar(double value) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: AttrProgress(value: value),
    ).center().padSymmetric(h: 12);
  }
}

class AttrProgress extends StatefulWidget {
  final double value;

  const AttrProgress({super.key, required this.value});

  @override
  State<AttrProgress> createState() => _AttrProgressState();
}

class _AttrProgressState extends State<AttrProgress> {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      curve: Curves.fastLinearToSlowEaseIn,
      tween: Tween<double>(
        begin: 0,
        end: widget.value,
      ),
      builder: (context, value, _) => buildBar(value),
    );
  }

  Widget buildBar(double v) {
    return LinearProgressIndicator(
      value: v,
      minHeight: 8,
    );
  }
}
