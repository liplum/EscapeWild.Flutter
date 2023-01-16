import 'package:escape_wild/core/attribute.dart';
import 'package:escape_wild/r.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:rettulf/rettulf.dart';

import 'shared.dart';

abstract class HudWidgetProtocol extends StatefulWidget {
  final TextStyle? textStyle;
  final double? opacity;

  const HudWidgetProtocol({
    super.key,
    this.textStyle,
    this.opacity,
  });
}

extension HudX on HudWidgetProtocol {
  Widget mini() {
    return ListTile(
      subtitle: this,
    ).scrolled(physics: const NeverScrollableScrollPhysics()).padAll(5);
  }
}

class Hud extends HudWidgetProtocol {
  final AttrModel attrs;

  const Hud({
    super.key,
    required this.attrs,
    super.textStyle,
    super.opacity,
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
    final opacity = widget.opacity;
    return AttrProgress(
      value: value,
      color: opacity != null ? color.withOpacity(opacity) : color,
    ).center().padOnly(l: 12);
  }
}
