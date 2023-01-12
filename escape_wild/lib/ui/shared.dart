import 'package:auto_size_text/auto_size_text.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/theme.dart';
import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/ui/hud.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rettulf/rettulf.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

const itemCellGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 180,
  childAspectRatio: 1.5,
);
const itemCellSmallGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 160,
  childAspectRatio: 2.2,
);

class ItemEntryCell extends StatelessWidget {
  final ItemEntry item;
  final EdgeInsetsGeometry? pad;
  final bool showMass;

  const ItemEntryCell(
    this.item, {
    super.key,
    this.pad = const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
    this.showMass = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: AutoSizeText(
        item.meta.localizedName(),
        style: context.textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      subtitle: !showMass ? null : I.item.massWithUnit(item.actualMass.toString()).text(textAlign: TextAlign.right),
      dense: true,
      contentPadding: pad,
    ).center();
  }
}

class ItemCell extends StatelessWidget {
  final Item item;

  const ItemCell(
    this.item, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: AutoSizeText(
        item.localizedName(),
        style: context.textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      dense: true,
    ).center();
  }
}

class NullItemCell extends StatelessWidget {
  const NullItemCell({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: AutoSizeText(
        "?",
        style: context.textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      dense: true,
    );
  }
}

class CardButton extends ImplicitlyAnimatedWidget {
  final double elevation;
  final Widget child;
  final VoidCallback? onTap;
  final ShapeBorder? shape;

  const CardButton({
    super.key,
    super.duration = const Duration(milliseconds: 80),
    super.curve = Curves.easeInOut,
    this.elevation = 1.0,
    this.shape,
    this.onTap,
    required this.child,
  });

  @override
  ImplicitlyAnimatedWidgetState<CardButton> createState() => _CardButtonState();
}

class _CardButtonState extends AnimatedWidgetBaseState<CardButton> {
  late Tween<double> $elevation;
  late ShapeBorderTween? $shape;

  @override
  void initState() {
    $elevation = Tween<double>(
      begin: widget.elevation,
      end: widget.elevation,
    );
    $shape = ShapeBorderTween(
      begin: widget.shape,
      end: widget.shape,
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
        .inCard(
          elevation: $elevation.evaluate(animation),
          shape: $shape?.evaluate(animation),
        );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    $elevation = visitor($elevation, widget.elevation, (dynamic value) {
      assert(false);
      throw StateError('Constructor will never be called because null is never provided as current tween.');
    }) as Tween<double>;
    $shape = visitor($shape, widget.shape, (dynamic value) {
      return ShapeBorderTween(
        begin: widget.shape,
        end: widget.shape,
      );
    }) as ShapeBorderTween?;
  }
}

class ItemEntryMassSelector extends StatefulWidget {
  final ItemEntry template;
  final ValueNotifier<int> $selectedMass;
  final ValueChanged<int>? onSelectedMassChange;

  const ItemEntryMassSelector({
    super.key,
    required this.template,
    required this.$selectedMass,
    this.onSelectedMassChange,
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
          final newMass = (v as double).round().clamp(0, item.actualMass);
          setState(() {
            $selectedMass.value = newMass;
          });
          widget.onSelectedMassChange?.call(newMass);
        },
      ),
    ].column(mas: MainAxisSize.min);
  }
}

class MergeableItemEntryUsePreview extends StatefulWidget {
  final ItemEntry template;
  final UseType useType;
  final ValueNotifier<int> $selectedMass;
  final List<ModifyAttrComp> comps;

  const MergeableItemEntryUsePreview({
    super.key,
    required this.template,
    this.useType = UseType.use,
    required this.$selectedMass,
    required this.comps,
  });

  @override
  State<MergeableItemEntryUsePreview> createState() => _MergeableItemEntryUsePreviewState();
}

class _MergeableItemEntryUsePreviewState extends State<MergeableItemEntryUsePreview> {
  ItemEntry get template => widget.template;
  late var mock = AttributeManager(initial: player.attrs);

  UseType get useType => widget.useType;

  ValueNotifier<int> get $selectedMass => widget.$selectedMass;

  @override
  void initState() {
    super.initState();
    onSelectedMassChange($selectedMass.value);
  }

  @override
  Widget build(BuildContext context) {
    return context.isPortrait ? buildPortrait() : buildLandscape();
  }

  Widget buildPortrait() {
    return [
      MiniHud(attrs: mock.attrs),
      const SizedBox(height: 40),
      ItemEntryMassSelector(
        template: template,
        $selectedMass: $selectedMass,
        onSelectedMassChange: (newMass) {
          onSelectedMassChange(newMass);
        },
      ),
    ].column(mas: MainAxisSize.min);
  }

  Widget buildLandscape() {
    return [
      MiniHud(attrs: mock.attrs).expanded(),
      ItemEntryMassSelector(
        template: template,
        $selectedMass: $selectedMass,
        onSelectedMassChange: (newMass) {
          onSelectedMassChange(newMass);
        },
      ).expanded(),
    ].row(mas: MainAxisSize.max).constrained(minW: 500);
  }

  void onSelectedMassChange(int newMassOfPart) {
    mock.attrs = player.attrs;
    if (newMassOfPart <= 0) return;
    var item = widget.template.clone();
    final part = item.split(newMassOfPart);
    final builder = AttrModifierBuilder();
    for (final comp in widget.comps) {
      comp.buildAttrModification(part, builder);
    }
    builder.performModification(mock);
    setState(() {});
  }
}

class UnmergeableItemEntryUsePreview extends StatefulWidget {
  final ItemEntry item;
  final List<ModifyAttrComp> comps;
  final ValueNotifier<bool> $isShowAttrPreview;

  const UnmergeableItemEntryUsePreview({
    super.key,
    required this.item,
    required this.comps,
    required this.$isShowAttrPreview,
  });

  @override
  State<UnmergeableItemEntryUsePreview> createState() => _UnmergeableItemEntryUsePreviewState();
}

class _UnmergeableItemEntryUsePreviewState extends State<UnmergeableItemEntryUsePreview> {
  @override
  Widget build(BuildContext context) {
    return widget.$isShowAttrPreview <<
        (_, isShow, __) {
          final mock = AttributeManager(initial: player.attrs);
          if (isShow) {
            final builder = AttrModifierBuilder();
            for (final comp in widget.comps) {
              comp.buildAttrModification(widget.item, builder);
            }
            builder.performModification(mock);
          }
          return MiniHud(attrs: mock.attrs);
        };
  }
}
