import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/theme.dart';
import 'package:escape_wild/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rettulf/rettulf.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class CardButton extends ImplicitlyAnimatedWidget {
  final double elevation;
  final Widget child;
  final VoidCallback? onTap;

  const CardButton({
    super.key,
    super.duration = const Duration(milliseconds: 80),
    super.curve = Curves.easeInOut,
    this.elevation = 1.0,
    this.onTap,
    required this.child,
  });

  @override
  ImplicitlyAnimatedWidgetState<CardButton> createState() => _CardButtonState();
}

class _CardButtonState extends AnimatedWidgetBaseState<CardButton> {
  late Tween<double> $elevation;

  @override
  void initState() {
    $elevation = Tween<double>(
      begin: 1.0,
      end: widget.elevation,
    );
    super.initState();
    if ($elevation.begin != $elevation.end) {
      controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child
        .inkWell(
          onTap: widget.onTap,
          borderRadius: context.cardBorderRadius,
        )
        .inCard(elevation: $elevation.evaluate(animation));
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    $elevation = visitor($elevation, widget.elevation, (dynamic value) {
      assert(false);
      throw StateError('Constructor will never be called because null is never provided as current tween.');
    }) as Tween<double>;
  }
}

class ItemEntryMassSelector extends StatefulWidget {
  final ItemEntry template;
  final ValueNotifier<int> $selectedMass;

  const ItemEntryMassSelector({
    super.key,
    required this.template,
    required this.$selectedMass,
  });

  @override
  State<ItemEntryMassSelector> createState() => _ItemEntryMassSelectorState();
}

class _ItemEntryMassSelectorState extends State<ItemEntryMassSelector> {
  ItemEntry get item => widget.template;

  ValueNotifier<int> get $selectedMass => widget.$selectedMass;

  @override
  Widget build(BuildContext context) {
    var maxMass = item.actualMass;
    return [
      SfSlider(
        value: $selectedMass.value.clamp(0, maxMass),
        max: maxMass,
        enableTooltip: true,
        showTicks: true,
        showLabels: true,
        interval: maxMass / 2,
        minorTicksPerInterval: 2,
        shouldAlwaysShowTooltip: true,
        numberFormat: NumberFormat(I.item.massWithUnit("#")),
        onChanged: (v) {
          setState(() {
            $selectedMass.value = (v as double).round().clamp(0, item.actualMass);
          });
        },
      ),
    ].column(mas: MainAxisSize.min);
  }
}

class ItemEntryUsePreview extends StatefulWidget {
  final ItemEntry template;
  final ValueNotifier<int> $selectedMass;
  final List<ModifyAttrComp> modifiers;

  const ItemEntryUsePreview({
    super.key,
    required this.template,
    required this.$selectedMass,
    required this.modifiers,
  });

  @override
  State<ItemEntryUsePreview> createState() => _ItemEntryUsePreviewState();
}

class _ItemEntryUsePreviewState extends State<ItemEntryUsePreview> {
  ItemEntry get item => widget.template;

  ValueNotifier<int> get $selectedMass => widget.$selectedMass;

  @override
  Widget build(BuildContext context) {
    return [
      ItemEntryMassSelector(template: item, $selectedMass: $selectedMass),
    ].column(mas: MainAxisSize.min);
  }
}
