import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/theme.dart';
import 'package:escape_wild/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rettulf/rettulf.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import 'hud.dart';

const itemCellGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 180,
  childAspectRatio: 1.5,
);
const itemCellSmallGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 160,
  childAspectRatio: 2.2,
);

class ItemStackCell extends StatelessWidget {
  final ItemStack item;
  final EdgeInsetsGeometry? pad;
  final bool showMass;

  const ItemStackCell(
    this.item, {
    super.key,
    this.pad = const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
    this.showMass = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: AutoSizeText(
        item.meta.l10nName(),
        maxLines: 2,
        style: context.textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      subtitle: !showMass ? null : I.item.massWithUnit(item.stackMass.toString()).text(textAlign: TextAlign.right),
      dense: true,
      contentPadding: !showMass ? null : pad,
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
        item.l10nName(),
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
    // never reached.
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

class ItemStackMassSelector extends StatefulWidget {
  final ItemStack template;
  final ValueNotifier<int> $selectedMass;
  final ValueChanged<int>? onSelectedMassChange;

  const ItemStackMassSelector({
    super.key,
    required this.template,
    required this.$selectedMass,
    this.onSelectedMassChange,
  });

  @override
  State<ItemStackMassSelector> createState() => _ItemStackMassSelectorState();
}

class _ItemStackMassSelectorState extends State<ItemStackMassSelector> {
  ItemStack get item => widget.template;

  ValueNotifier<int> get $selectedMass => widget.$selectedMass;

  @override
  Widget build(BuildContext context) {
    var maxMass = item.stackMass;
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
          final newMass = (v as double).round().clamp(0, item.stackMass);
          setState(() {
            $selectedMass.value = newMass;
          });
          widget.onSelectedMassChange?.call(newMass);
        },
      ),
    ].column(mas: MainAxisSize.min);
  }
}

class MergeableItemStackUsePreview extends StatefulWidget {
  final ItemStack template;
  final UseType useType;
  final ValueNotifier<int> $selectedMass;
  final List<ModifyAttrComp> comps;

  const MergeableItemStackUsePreview({
    super.key,
    required this.template,
    this.useType = UseType.use,
    required this.$selectedMass,
    required this.comps,
  });

  @override
  State<MergeableItemStackUsePreview> createState() => _MergeableItemStackUsePreviewState();
}

class _MergeableItemStackUsePreviewState extends State<MergeableItemStackUsePreview> {
  ItemStack get template => widget.template;
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
      MiniHud(attrs: mock.attrs).inCard(),
      const SizedBox(height: 40),
      ItemStackMassSelector(
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
      ItemStackMassSelector(
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

class UnmergeableItemStackUsePreview extends StatefulWidget {
  final ItemStack item;
  final List<ModifyAttrComp> comps;
  final ValueNotifier<bool> $isShowAttrPreview;

  const UnmergeableItemStackUsePreview({
    super.key,
    required this.item,
    required this.comps,
    required this.$isShowAttrPreview,
  });

  @override
  State<UnmergeableItemStackUsePreview> createState() => _UnmergeableItemStackUsePreviewState();
}

class _UnmergeableItemStackUsePreviewState extends State<UnmergeableItemStackUsePreview> {
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
          return MiniHud(attrs: mock.attrs).inCard();
        };
  }
}

enum DynamicMatchingBehavior {
  onlyBackpack,
  onlyRegistry,
  both;

  bool get includingBackpack => this != onlyRegistry;

  bool get includingRegistry => this != onlyBackpack;
}

class DynamicMatchingCell extends StatefulWidget {
  final ItemMatcher matcher;
  final DynamicMatchingBehavior behavior;
  final Widget Function(Item item) onNotInBackpack;
  final Widget Function(ItemStack item) onInBackpack;

  const DynamicMatchingCell({
    super.key,
    required this.matcher,
    this.behavior = DynamicMatchingBehavior.both,
    required this.onNotInBackpack,
    required this.onInBackpack,
  });

  @override
  State<DynamicMatchingCell> createState() => _DynamicMatchingCellState();
}

class _DynamicMatchingCellState extends State<DynamicMatchingCell> {
  ItemMatcher get matcher => widget.matcher;
  var curIndex = 0;
  List<dynamic> allMatched = const [];
  var active = false;
  late Timer marqueeTimer;

  @override
  void initState() {
    super.initState();
    updateAllMatched();
    marqueeTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (allMatched.isNotEmpty) {
        setState(() {
          curIndex = (curIndex + 1) % allMatched.length;
        });
      }
    });
    player.backpack.addListener(updateAllMatched);
  }

  void updateAllMatched() {
    final behavior = widget.behavior;
    allMatched = behavior.includingBackpack ? player.backpack.matchExactItems(matcher) : const [];
    if (allMatched.isNotEmpty) {
      curIndex = curIndex % allMatched.length;
      active = true;
    } else {
      // If player don't have any of them, or backpack is excluded, try to browser all items.
      allMatched = behavior.includingRegistry ? Contents.getMatchedItems(matcher) : const [];
      assert(
          allMatched.isNotEmpty || !behavior.includingRegistry, "ItemMatcher should match at least one of all items.");
      if (allMatched.isNotEmpty) {
        curIndex = curIndex % allMatched.length;
      }
      active = false;
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant DynamicMatchingCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      if (!widget.behavior.includingBackpack) {
        player.backpack.removeListener(updateAllMatched);
      }
      updateAllMatched();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (allMatched.isNotEmpty) {
      final cur = allMatched[curIndex];
      if (cur is Item) {
        return widget.onNotInBackpack(cur);
      } else if (cur is ItemStack) {
        return widget.onInBackpack(cur);
      } else {
        assert(false, "${cur.runtimeType} is neither $Item nor $ItemStack.");
        return const NullItemCell();
      }
    } else {
      assert(false, "No item matched.");
      return const NullItemCell();
    }
  }

  @override
  void dispose() {
    super.dispose();
    marqueeTimer.cancel();
    player.backpack.removeListener(updateAllMatched);
  }
}
