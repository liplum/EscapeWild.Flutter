import 'package:escape_wild/core/attribute/attribute.dart';
import 'package:escape_wild/design/theme.dart';
import 'package:escape_wild/r.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:rettulf/rettulf.dart';

import '../shared.dart';

class Hud extends StatefulWidget {
  final AttrModel attrs;
  final TextStyle? textStyle;
  final double? opacity;
  final double? minHeight;

  const Hud({super.key, required this.attrs, this.textStyle, this.opacity, this.minHeight});

  @override
  State<Hud> createState() => _HudState();

  Widget mini() {
    return ListTile(subtitle: this).scrolled(physics: const NeverScrollableScrollPhysics()).padAll(5);
  }
}

class _HudState extends State<Hud> {
  AttrModel get attr => widget.attrs;

  @override
  Widget build(BuildContext context) {
    return LayoutGrid(
      columnSizes: [auto, 1.5.fr],
      gridFit: GridFit.expand,
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
    color = context.fixColorBrightness(color);
    final opacity = widget.opacity;
    return AttrProgress(
      value: value,
      minHeight: widget.minHeight,
      color: opacity != null ? color.withValues(alpha: opacity) : color,
    ).center().padOnly(l: 12);
  }
}
