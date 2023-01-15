import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/theme.dart';
import 'package:escape_wild/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import 'backpack.dart';
import 'hud.dart';

const itemCellGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 180,
  childAspectRatio: 1.5,
);
const itemCellSmallGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 160,
  childAspectRatio: 2.2,
);

class AttrProgress extends ImplicitlyAnimatedWidget {
  final double value;
  final Color? color;

  const AttrProgress({
    super.key,
    super.duration = const Duration(milliseconds: 1200),
    required this.value,
    this.color,
    super.curve = Curves.fastLinearToSlowEaseIn,
  });

  @override
  ImplicitlyAnimatedWidgetState<AttrProgress> createState() => _AttrProgressState();
}

class _AttrProgressState extends AnimatedWidgetBaseState<AttrProgress> {
  late Tween<double> $progress;

  @override
  void initState() {
    $progress = Tween<double>(
      begin: widget.value,
      end: widget.value,
    );
    super.initState();
    if ($progress.begin != $progress.end) {
      controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: buildBar($progress.evaluate(animation)),
    );
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

class ItemStackCell extends StatelessWidget {
  final ItemStack stack;
  final EdgeInsetsGeometry? pad;
  final bool showMass;
  final bool showProgressBar;

  const ItemStackCell(
    this.stack, {
    super.key,
    this.pad = const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
    this.showMass = true,
    this.showProgressBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final tile = ListTile(
      title: AutoSizeText(
        stack.meta.l10nName(),
        maxLines: 2,
        style: context.textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      subtitle: !showMass ? null : I.massOf(stack.stackMass).text(textAlign: TextAlign.right),
      dense: true,
      contentPadding: !showMass ? null : pad,
    ).center();
    if (!showProgressBar) return tile;
    final durabilityComp = DurabilityComp.of(stack);
    if (durabilityComp != null) {
      final ratio = durabilityComp.durabilityRatio(stack);
      return [
        Opacity(opacity: 0.55, child: AttrProgress(value: ratio))
            .align(
              at: const Alignment(1.0, -0.86),
            )
            .padH(5),
        tile,
      ].stack();
    } else {
      return tile;
    }
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
        labelFormatterCallback: (v, format) {
          return I.massOf((v as num).toInt());
        },
        tooltipTextFormatterCallback: (v, format) {
          return I.massOf((v as num).toInt());
        },
        semanticFormatterCallback: (v) {
          return I.massOf((v as num).toInt());
        },
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
  final Widget Function(ItemStack stack) onInBackpack;

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

class ItemStackReqSlot {
  ItemStack stack = ItemStack.empty;

  void reset() => stack = ItemStack.empty;

  bool get isEmpty => stack == ItemStack.empty;

  bool get isNotEmpty => !isEmpty;
  final ItemMatcher matcher;

  ItemStackReqSlot(this.matcher);

  ItemStackReqSlot.match({
    required ItemTypeMatcher typeOnly,
    required ItemStackMatcher exact,
  }) : matcher = ItemMatcher(typeOnly: typeOnly, exact: exact);

  void toggle(ItemStack newStack) {
    if (newStack == stack) {
      reset();
    } else if (matcher.exact(newStack).isMatched) {
      stack = newStack;
    }
  }
}

class ItemStackReqCell extends StatelessWidget {
  final ItemStackReqSlot slot;
  final VoidCallback? onTapSatisfied;
  final VoidCallback? onTapUnsatisfied;
  final Widget Function(ItemStack stack)? onSatisfy;
  final Widget Function(Item item)? onNotInBackpack;
  final Widget Function(ItemStack item)? onInBackpack;

  const ItemStackReqCell({
    super.key,
    required this.slot,
    this.onTapSatisfied,
    this.onTapUnsatisfied,
    this.onSatisfy,
    this.onNotInBackpack,
    this.onInBackpack,
  });

  @override
  Widget build(BuildContext context) {
    ShapeBorder? shape;
    final satisfyCondition = slot.isNotEmpty;
    if (!satisfyCondition) {
      shape = RoundedRectangleBorder(
        side: BorderSide(
          color: context.theme.colorScheme.outline,
        ),
        borderRadius: context.cardBorderRadius ?? BorderRadius.zero,
      );
    }
    return CardButton(
      elevation: satisfyCondition ? 4 : 0,
      onTap: !satisfyCondition
          ? onTapUnsatisfied
          : () {
              onTapSatisfied?.call();
            },
      shape: shape,
      child: satisfyCondition
          ? onSatisfy?.call(slot.stack) ?? ItemStackCell(slot.stack)
          : DynamicMatchingCell(
              matcher: slot.matcher,
              onNotInBackpack: onNotInBackpack ?? (item) => ItemCell(item),
              onInBackpack: onInBackpack ?? (stack) => ItemStackCell(stack, showMass: false),
            ),
    );
  }
}

enum BackpackFilterDisplayBehavior {
  onlyAccepted,
  both,
  toggleable;

  bool get showFilterButton => this == toggleable;
}

class BackpackSheet extends StatefulWidget {
  final ItemMatcher matcher;
  final ValueChanged<ItemStack>? onSelect;
  final BackpackFilterDisplayBehavior behavior;

  const BackpackSheet({
    super.key,
    required this.matcher,
    this.onSelect,
    this.behavior = BackpackFilterDisplayBehavior.toggleable,
  });

  @override
  State<BackpackSheet> createState() => _BackpackSheetState();
}

class _BackpackSheetState extends State<BackpackSheet> {
  ItemMatcher get matcher => widget.matcher;
  List<ItemStack> accepted = const [];
  List<ItemStack> unaccepted = const [];
  bool toggleFilter = false;

  bool get showUnaccepted =>
      widget.behavior == BackpackFilterDisplayBehavior.both ||
      (widget.behavior == BackpackFilterDisplayBehavior.toggleable && !toggleFilter);

  @override
  void initState() {
    super.initState();
    updateBackpackFilter();
  }

  void updateBackpackFilter() {
    final p = player.backpack.separateMatchedFromUnmatched((stack) => matcher.typeOnly(stack.meta));
    accepted = p.key;
    unaccepted = p.value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const RangeMaintainingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 60.0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                context.navigator.pop();
              },
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              title: "Backpack".text(),
            ),
            actions: [
              if (widget.behavior.showFilterButton)
                IconButton(
                  onPressed: () {
                    setState(() {
                      toggleFilter = !toggleFilter;
                    });
                  },
                  icon: Icon(
                    toggleFilter ? Icons.filter_alt_rounded : Icons.filter_alt_off_rounded,
                  ),
                )
            ],
          ),
          buildBackpackView(),
        ],
      ),
    );
  }

  Widget buildBackpackView() {
    if (player.backpack.isEmpty) {
      return SliverToBoxAdapter(child: buildEmptyBackpack().padV(30));
    }
    var length = accepted.length;
    if (showUnaccepted) {
      length += unaccepted.length;
    }
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        childAspectRatio: 1.5,
      ),
      delegate: SliverChildBuilderDelegate(
        childCount: length,
        (ctx, i) {
          if (i < accepted.length) {
            return buildItem(accepted[i], accepted: true);
          } else {
            return buildItem(unaccepted[i - accepted.length], accepted: false);
          }
        },
      ),
    );
  }

  Widget buildItem(ItemStack stack, {required bool accepted}) {
    final onSelect = widget.onSelect;
    return CardButton(
      elevation: accepted ? 4 : 0,
      onTap: !accepted || onSelect == null
          ? null
          : () {
              onSelect(stack);
            },
      child: ItemStackCell(stack),
    );
  }
}
