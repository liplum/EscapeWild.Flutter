import 'package:escape_wild_flutter/core/attribute.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';

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
    return GridView(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 8,
      ),
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

  Widget label(Attr attr){
    return attr.localizedName().text(textAlign: TextAlign.center);
  }

  Widget buildBar(double value) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      child: AttrProgress(value: value),
    ).padAll(2);
  }
}

class AttrProgress extends StatelessWidget {
  final double value;

  const AttrProgress({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      curve: Curves.fastLinearToSlowEaseIn,
      tween: Tween<double>(
        begin: 0,
        end: value,
      ),
      builder: (context, value, _) => buildBar(value),
    );
  }

  Widget buildBar(double v) {
    return LinearProgressIndicator(value: v);
  }
}
