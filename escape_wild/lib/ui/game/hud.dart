import 'package:escape_wild/core/attribute.dart';
import 'package:escape_wild/r.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:rettulf/rettulf.dart';

import 'shared.dart';

class Hud extends StatefulWidget {
  final AttrModel attrs;
  final TextStyle? textStyle;

  const Hud({
    super.key,
    required this.attrs,
    this.textStyle,
  });

  @override
  State<Hud> createState() => _HudState();
}

class _HudState extends State<Hud> {
  AttrModel get attr => widget.attrs;

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
    return attr.l10nName().toUpperCase().text(style: widget.textStyle).center();
  }

  Widget buildBar(double value, Color color) {
    return AttrProgress(
      value: value,
      color: color,
    ).center().padOnly(l: 12);
  }
}

class MiniHud extends StatelessWidget {
  final AttrModel attrs;

  const MiniHud({super.key, required this.attrs});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      subtitle: Hud(attrs: attrs).scrolled(physics: const NeverScrollableScrollPhysics()),
    ).padAll(5);
  }
}
