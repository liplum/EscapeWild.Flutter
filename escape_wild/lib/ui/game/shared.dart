import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/theme.dart';
import 'package:escape_wild/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
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
  childAspectRatio: 2,
);

class AttrProgress extends ImplicitlyAnimatedWidget {
  final double value;
  final Color? color;
  final double? minHeight;

  const AttrProgress({
    super.key,
    super.duration = const Duration(milliseconds: 1200),
    required this.value,
    this.color,
    this.minHeight = 8,
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
      child: buildBar(),
    );
  }

  Widget buildBar() {
    final progress = $progress.evaluate(animation);
    return LinearProgressIndicator(
      value: progress,
      minHeight: widget.minHeight,
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

class ItemCellTheme {
  final double? nameOpacity;
  final TextStyle? nameStyle;

  const ItemCellTheme({
    this.nameOpacity,
    this.nameStyle,
  });

  double get $nameOpacity => nameOpacity ?? 1;

  ItemCellTheme copyWith({
    double? nameOpacity,
    TextStyle? nameStyle,
  }) =>
      ItemCellTheme(
        nameOpacity: nameOpacity ?? this.nameOpacity,
        nameStyle: nameStyle ?? this.nameStyle,
      );
}

class ItemCell extends StatelessWidget {
  final Item item;
  final ItemCellTheme theme;

  const ItemCell(
    this.item, {
    super.key,
    this.theme = const ItemCellTheme(),
  });

  @override
  Widget build(BuildContext context) {
    final title = AutoSizeText(
      item.l10nName(),
      maxLines: 2,
      style: theme.nameStyle ?? context.textTheme.titleLarge,
      textAlign: TextAlign.center,
    ).opacityOrNot(theme.$nameOpacity);
    return ListTile(
      title: title,
      dense: true,
    ).center();
  }
}

class NullItemCell extends StatelessWidget {
  final ItemCellTheme theme;

  const NullItemCell({
    super.key,
    this.theme = const ItemCellTheme(),
  });

  @override
  Widget build(BuildContext context) {
    // never reached.
    return ListTile(
      title: AutoSizeText(
        "?",
        style: theme.nameStyle ?? context.textTheme.titleLarge,
        textAlign: TextAlign.center,
      ).opacityOrNot(theme.$nameOpacity),
      dense: true,
    );
  }
}

class ItemStackCellTheme extends ItemCellTheme {
  final bool? showMass;
  final bool? showProgressBar;
  final double? progressBarOpacity;
  final EdgeInsetsGeometry? pad;

  const ItemStackCellTheme({
    this.showMass = true,
    this.showProgressBar = true,
    this.progressBarOpacity = 0.55,
    super.nameOpacity = 1,
    super.nameStyle,
    this.pad = const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
  });

  bool get $showMass => showMass ?? true;

  bool get $showProgressBar => showProgressBar ?? true;

  double get $progressBarOpacity => progressBarOpacity ?? 0.55;

  EdgeInsetsGeometry get $pad => pad ?? const EdgeInsets.symmetric(vertical: 10, horizontal: 8);

  @override
  ItemStackCellTheme copyWith({
    bool? showMass,
    bool? showProgressBar,
    double? progressBarOpacity,
    double? nameOpacity,
    TextStyle? nameStyle,
    EdgeInsetsGeometry? pad,
  }) =>
      ItemStackCellTheme(
        showMass: showMass ?? this.showMass,
        showProgressBar: showProgressBar ?? this.showProgressBar,
        progressBarOpacity: progressBarOpacity ?? this.progressBarOpacity,
        nameOpacity: nameOpacity ?? this.nameOpacity,
        nameStyle: nameStyle ?? this.nameStyle,
        pad: pad ?? this.pad,
      );
}

class ItemStackCell extends StatelessWidget {
  final ItemStack stack;
  final ItemStackCellTheme theme;

  const ItemStackCell(
    this.stack, {
    super.key,
    this.theme = const ItemStackCellTheme(),
  });

  @override
  Widget build(BuildContext context) {
    final tile = ListTile(
      title: AutoSizeText(
        stack.meta.l10nName(),
        maxLines: 2,
        style: theme.nameStyle ?? context.textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      subtitle: !theme.$showMass ? null : I.massOf(stack.stackMass).text(textAlign: TextAlign.right),
      dense: true,
      contentPadding: !theme.$showMass ? null : theme.pad,
    ).opacityOrNot(theme.$nameOpacity).center();
    if (!theme.$showProgressBar || theme.$progressBarOpacity <= 0) return tile;
    final durabilityComp = DurabilityComp.of(stack);
    if (durabilityComp != null) {
      final ratio = durabilityComp.durabilityRatio(stack);
      return [
        Opacity(opacity: theme.$progressBarOpacity, child: AttrProgress(value: ratio))
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

class CardButton extends ImplicitlyAnimatedWidget {
  final double? elevation;
  final Widget child;
  final VoidCallback? onTap;
  final ShapeBorder? shape;

  const CardButton({
    super.key,
    super.duration = const Duration(milliseconds: 80),
    super.curve = Curves.easeInOut,
    this.elevation,
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
      begin: widget.elevation ?? 1.0,
      end: widget.elevation ?? 1.0,
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
    $elevation = visitor($elevation, widget.elevation ?? 1.0, (dynamic value) {
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
      buildHud(mock.attrs).inCard(),
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
      buildHud(mock.attrs).expanded(),
      ItemStackMassSelector(
        template: template,
        $selectedMass: $selectedMass,
        onSelectedMassChange: (newMass) {
          onSelectedMassChange(newMass);
        },
      ).expanded(),
    ].row(mas: MainAxisSize.max).constrained(minW: 500);
  }

  Widget buildHud(AttrModel attrs) {
    return Hud(attrs: attrs).mini();
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
          return Hud(attrs: mock.attrs).mini().inCard();
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

class ItemStackReqSlot with ChangeNotifier {
  var _stack = ItemStack.empty;

  ItemStack get stack => _stack;

  set stack(ItemStack v) {
    _stack = v;
    notifyListeners();
  }

  void reset() {
    stack = ItemStack.empty;
  }

  void resetIfEmpty() {
    if (stack.isEmpty) {
      stack = ItemStack.empty;
    }
  }

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

  /// manually call [notifyListeners] if the [stack] was changed outside.
  void notifyChange() {
    notifyListeners();
  }
  /// Call this manually if [stack]'s state was changed outside.
  /// - for example, [stack.stackMass] was changed.
  void updateMatching() {
    if (!matcher.exact(stack).isMatched) {
      reset();
    }
  }
}

class ItemStackReqCell extends StatelessWidget {
  final ItemStackReqSlot slot;
  final VoidCallback? onTapSatisfied;
  final VoidCallback? onTapUnsatisfied;
  final ItemStackCellTheme onSatisfy;
  final ItemCellTheme onNotInBackpack;
  final ItemStackCellTheme onInBackpack;
  static const opacityOnMissing = 0.5;

  const ItemStackReqCell({
    super.key,
    required this.slot,
    this.onTapSatisfied,
    this.onTapUnsatisfied,
    this.onSatisfy = const ItemStackCellTheme(),
    this.onNotInBackpack = const ItemCellTheme(),
    this.onInBackpack = const ItemStackCellTheme(),
  });

  @override
  Widget build(BuildContext context) {
    return slot << (_, __) => buildBody(context);
  }

  Widget buildBody(BuildContext context) {
    ShapeBorder? shape;
    final satisfyCondition = slot.isNotEmpty;
    if (!satisfyCondition) {
      shape = RoundedRectangleBorder(
        side: BorderSide(
          color: context.isDarkMode ? context.colorScheme.outline : context.colorScheme.secondary,
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
          ? ItemStackCell(
              slot.stack,
              theme: onSatisfy,
            )
          : DynamicMatchingCell(
              matcher: slot.matcher,
              onNotInBackpack: (item) => ItemCell(
                item,
                theme: onNotInBackpack.copyWith(nameOpacity: opacityOnMissing),
              ),
              onInBackpack: (stack) => ItemStackCell(stack,
                  theme: onInBackpack.copyWith(
                    nameOpacity: opacityOnMissing,
                    showMass: false,
                  )),
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
      body: LayoutBuilder(
        builder: (_, box) => CustomScrollView(
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
                title: backpackTitle.text(),
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
            buildBackpackView(box),
          ],
        ),
      ),
    );
  }

  Widget buildBackpackView(BoxConstraints box) {
    if (player.backpack.isEmpty) {
      // to center the empty backpack tip
      return SliverToBoxAdapter(child: buildEmptyBackpack().padV(box.maxHeight * 0.2));
    }
    var length = accepted.length;
    if (showUnaccepted) {
      length += unaccepted.length;
    }
    return SliverGrid(
      gridDelegate: itemCellGridDelegate,
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

extension BackpackBuildContextX on BuildContext {
  Future<T?> showMatchBackpack<T>({
    required ItemMatcher matcher,
    ValueChanged<ItemStack>? onSelect,
    BackpackFilterDisplayBehavior behavior = BackpackFilterDisplayBehavior.toggleable,
  }) async {
    return await showCupertinoModalBottomSheet<T>(
      context: this,
      enableDrag: false,
      builder: (ctx) => BackpackSheet(
        matcher: matcher,
        onSelect: onSelect,
        behavior: behavior,
      ).constrained(maxH: mediaQuery.size.height * 0.5),
    );
  }
}


class DurationStepper extends StatefulWidget {
  final ValueNotifier<TS> $duration;
  final TS min;
  final TS max;
  final TS step;

  const DurationStepper({
    super.key,
    required this.$duration,
    required this.min,
    required this.max,
    required this.step,
  });

  @override
  State<DurationStepper> createState() => _DurationStepperState();
}

class _DurationStepperState extends State<DurationStepper> {
  var isPressing = false;

  ValueNotifier<TS> get $duration => widget.$duration;

  TS get duration => widget.$duration.value;

  set duration(TS ts) => widget.$duration.value = ts;

  TS get min => widget.min;

  TS get max => widget.max;

  TS get step => widget.step;

  @override
  Widget build(BuildContext context) {
    return $duration << (ctx, ts, _) => buildBody(ts);
  }

  Widget buildBody(TS ts) {
    return [
      buildStepper(isLeft: true).flexible(flex: 1),
      I
          .ts(ts)
          .toUpperCase()
          .text(style: context.textTheme.headlineSmall, textAlign: TextAlign.end)
          .center()
          .flexible(flex: 4),
      buildStepper(isLeft: false).flexible(flex: 1),
    ].row(maa: MainAxisAlignment.spaceEvenly);
  }

  Widget buildStepper({required bool isLeft}) {
    if (isLeft) {
      return buildStepperBtn(
        Icons.arrow_left_rounded,
        canStep: () => duration > min,
        onStep: () => duration -= step,
      );
    } else {
      return buildStepperBtn(
        Icons.arrow_right_rounded,
        canStep: () => duration < max,
        onStep: () => duration += step,
      );
    }
  }

  Widget buildStepperBtn(
      IconData icon, {
        required bool Function() canStep,
        required void Function() onStep,
      }) {
    return GestureDetector(
        onLongPressStart: (_) async {
          isPressing = true;
          do {
            if (canStep()) {
              onStep();
            } else {
              break;
            }
            await Future.delayed(const Duration(milliseconds: 100));
          } while (isPressing);
        },
        onLongPressEnd: (_) => setState(() => isPressing = false),
        child: CardButton(
          elevation: canStep() ? 5 : 0,
          onTap: !canStep()
              ? null
              : () {
            onStep();
          },
          child: buildIcon(icon),
        ));
  }

  Widget buildIcon(IconData icon) {
    const iconSize = 36.0;
    const scale = 3.0;
    return Transform.scale(
      scale: scale,
      child: Icon(icon, size: iconSize).padAll(5),
    );
  }

  @override
  void dispose() {
    super.dispose();
    isPressing = false;
  }
}