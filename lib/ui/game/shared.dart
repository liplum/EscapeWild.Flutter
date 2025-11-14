import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:escape_wild/core/index.dart';
import 'package:escape_wild/design/theme.dart';
import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/r.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rettulf/rettulf.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:tabler_icons/tabler_icons.dart';

import 'backpack/backpack.dart';
import 'action/hud.dart';

const itemCellGridDelegatePortrait = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 180,
  childAspectRatio: 1.5,
);
const itemCellGridDelegateLandscape = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 180,
  childAspectRatio: 1.8,
);

extension ItemCellGridBuildContextX on BuildContext {
  SliverGridDelegateWithMaxCrossAxisExtent get itemCellGridDelegate =>
      isPortrait ? itemCellGridDelegatePortrait : itemCellGridDelegateLandscape;
}

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
    this.minHeight,
    super.curve = Curves.fastLinearToSlowEaseIn,
  });

  @override
  ImplicitlyAnimatedWidgetState<AttrProgress> createState() => _AttrProgressState();
}

class _AttrProgressState extends AnimatedWidgetBaseState<AttrProgress> {
  late Tween<double> $progress;
  late ColorTween? $color;

  @override
  void initState() {
    $progress = Tween<double>(begin: widget.value, end: widget.value);
    $color = ColorTween(begin: widget.color, end: widget.color);
    super.initState();
    if ($progress.begin != $progress.end) {
      controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(8)), child: buildBar());
  }

  Widget buildBar() {
    final progress = $progress.evaluate(animation);
    return LinearProgressIndicator(
      value: progress,
      minHeight: widget.minHeight ?? 8,
      color: $color?.animate(animation).value,
      backgroundColor: Colors.grey.withValues(alpha: 0.2),
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    $progress =
        visitor($progress, widget.value, (dynamic value) {
              assert(false);
              throw StateError('Constructor will never be called because null is never provided as current tween.');
            })
            as Tween<double>;
    $color =
        visitor($color, widget.color, (dynamic value) {
              assert(false);
              throw StateError('Constructor will never be called because null is never provided as current tween.');
            })
            as ColorTween?;
  }
}

class ItemCellTheme {
  final double? opacity;
  final TextStyle? nameStyle;

  const ItemCellTheme({this.opacity, this.nameStyle});

  double get $opacity => opacity ?? 1;

  ItemCellTheme copyWith({double? opacity, TextStyle? nameStyle}) =>
      ItemCellTheme(opacity: opacity ?? this.opacity, nameStyle: nameStyle ?? this.nameStyle);
}

class ItemCell extends StatelessWidget {
  final Item item;
  final ItemCellTheme theme;

  const ItemCell(this.item, {super.key, this.theme = const ItemCellTheme()});

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      item.l10nName(),
      maxLines: 2,
      style: theme.nameStyle ?? context.textTheme.titleMedium,
      textAlign: .center,
    ).opacity(theme.$opacity).center();
  }
}

class NullItemCellTheme extends ItemCellTheme {
  /// To show a placeholder on the center
  final String? placeholder;

  const NullItemCellTheme({this.placeholder, super.opacity, super.nameStyle});
}

class NullItemCell extends StatelessWidget {
  final NullItemCellTheme theme;

  const NullItemCell({super.key, this.theme = const NullItemCellTheme()});

  @override
  Widget build(BuildContext context) {
    final placeholder = theme.placeholder;
    if (placeholder != null) {
      return buildPlaceholder(context, placeholder);
    } else {
      return const SizedBox();
    }
  }

  Widget buildPlaceholder(BuildContext ctx, String placeholder) {
    return AutoSizeText(
      placeholder,
      maxLines: 2,
      style: theme.nameStyle ?? ctx.textTheme.titleMedium,
      textAlign: .center,
    ).opacity(theme.$opacity).center();
  }
}

class ItemStackCellTheme extends ItemCellTheme {
  final bool? showMass;
  final bool? showProgressBar;
  final double? progressBarOpacity;
  final EdgeInsetsGeometry? pad;

  const ItemStackCellTheme({
    this.showMass,
    this.showProgressBar,
    this.progressBarOpacity,
    super.opacity,
    super.nameStyle,
    this.pad,
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
    double? opacity,
    TextStyle? nameStyle,
    EdgeInsetsGeometry? pad,
  }) => ItemStackCellTheme(
    showMass: showMass ?? this.showMass,
    showProgressBar: showProgressBar ?? this.showProgressBar,
    progressBarOpacity: progressBarOpacity ?? this.progressBarOpacity,
    opacity: opacity ?? this.opacity,
    nameStyle: nameStyle ?? this.nameStyle,
    pad: pad ?? this.pad,
  );
}

class ItemStackCell extends StatelessWidget {
  final ItemStack stack;
  final ItemStackCellTheme theme;

  const ItemStackCell(this.stack, {super.key, this.theme = const ItemStackCellTheme()});

  @override
  Widget build(BuildContext context) {
    final tile = ListTile(
      title: AutoSizeText(
        stack.meta.l10nName(),
        maxLines: 2,
        style: theme.nameStyle ?? context.textTheme.titleMedium,
        textAlign: .center,
      ),
      subtitle: !theme.$showMass ? null : I.massOf(stack.stackMass).text(textAlign: .right),
      dense: true,
      contentPadding: !theme.$showMass ? null : theme.$pad,
    ).opacity(theme.$opacity).center();
    return decorate(context, tile);
  }

  Widget decorate(BuildContext ctx, Widget tile) {
    final inStack = <Widget>[tile];
    if (theme.$showProgressBar && theme.$progressBarOpacity > 0) {
      final durabilityComp = DurabilityComp.of(stack);
      if (durabilityComp != null) {
        final ratio = durabilityComp.getDurabilityRatio(stack);
        final durabilityBar = AttrProgress(
          value: ratio,
          color: durabilityComp.progressColor(stack, darkMode: ctx.isDarkMode),
        ).opacity(theme.$progressBarOpacity * theme.$opacity).align(at: const .new(1.0, -0.86)).padH(5);
        inStack.add(durabilityBar);
      }
    }
    final freshnessComp = FreshnessComp.of(stack);
    if (freshnessComp != null) {
      final color = freshnessComp.progressColor(stack, darkMode: ctx.isDarkMode);
      inStack.add(
        AnimatedContainer(
          color: color.withValues(alpha: 0.15),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.fastLinearToSlowEaseIn,
        ).clipRRect(borderRadius: ctx.cardBorderRadius),
      );
    }
    if (inStack.length == 1) {
      return tile;
    } else {
      return inStack.stack();
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
    $elevation = Tween<double>(begin: widget.elevation ?? 1.0, end: widget.elevation ?? 1.0);
    $shape = ShapeBorderTween(begin: widget.shape, end: widget.shape);
    super.initState();
    if ($elevation.begin != $elevation.end) {
      controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      clipBehavior: .hardEdge,
      shape: $shape?.evaluate(animation),
      child: InkWell(onTap: widget.onTap, borderRadius: context.cardBorderRadius, child: widget.child),
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    $elevation =
        visitor($elevation, widget.elevation ?? 1.0, (dynamic value) {
              assert(false);
              throw StateError('Constructor will never be called because null is never provided as current tween.');
            })
            as Tween<double>;
    $shape =
        visitor($shape, widget.shape, (dynamic value) {
              return ShapeBorderTween(begin: widget.shape, end: widget.shape);
            })
            as ShapeBorderTween?;
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
    return widget.$isShowAttrPreview >>
        (_, isShow) {
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
  final bool random;
  final DynamicMatchingBehavior behavior;
  final Widget Function(Item item) onNotInBackpack;
  final Widget Function(ItemStack stack) onInBackpack;

  const DynamicMatchingCell({
    super.key,
    required this.matcher,
    this.behavior = DynamicMatchingBehavior.both,
    required this.onNotInBackpack,
    required this.onInBackpack,
    this.random = true,
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
    player.addListener(updateAllMatched);
  }

  void updateAllMatched() {
    final behavior = widget.behavior;
    allMatched = behavior.includingBackpack ? player.backpack.matchExactItems(matcher) : const [];
    if (allMatched.isNotEmpty) {
      if (widget.random) {
        curIndex = Random(hashCode).i(0, allMatched.length);
      } else {
        curIndex = curIndex % allMatched.length;
      }
      active = true;
    } else {
      // If player don't have any of them, or backpack is excluded, try to browser all items.
      allMatched = behavior.includingRegistry ? Contents.getMatchedItems(matcher) : const [];
      assert(
        allMatched.isNotEmpty || !behavior.includingRegistry,
        "ItemMatcher should match at least one of all items.",
      );
      if (allMatched.isNotEmpty) {
        if (widget.random) {
          curIndex = Random(hashCode).i(0, allMatched.length);
        } else {
          curIndex = curIndex % allMatched.length;
        }
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
        player.removeListener(updateAllMatched);
      }
      updateAllMatched();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: it doesn't work
    return AnimatedSwitcher(duration: Durations.medium4, child: buildCell());
  }

  Widget buildCell() {
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
    player.removeListener(updateAllMatched);
  }
}

class ItemStackSlot with ChangeNotifier {
  var _stack = ItemStack.empty;

  ItemStack get stack => _stack;

  set stack(ItemStack v) {
    _stack = v;
    notifyListeners();
  }

  void reset() {
    stack = .empty;
  }

  void resetIfEmpty() {
    if (stack.isEmpty) {
      stack = .empty;
    }
  }

  ItemStackMatchResult checkExact() => matcher.exact(stack);

  bool get isExactMatched => isNotEmpty && checkExact().isMatched;

  bool get isTypeMatched => isNotEmpty && matcher.typeOnly(stack.meta);

  bool get isEmpty => stack == .empty;

  bool get isNotEmpty => !isEmpty;
  final ItemMatcher matcher;

  ItemStackSlot(this.matcher);

  ItemStackSlot.match({required ItemTypeMatcher typeOnly, required ItemStackMatcher exact})
    : matcher = ItemMatcher(typeOnly: typeOnly, exact: exact);

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
  final ItemStackSlot slot;
  final VoidCallback? onTapSatisfied;
  final VoidCallback? onTapUnsatisfied;
  final ItemStackCellTheme satisfiedTheme;
  final NullItemCellTheme unsatisfiedTheme;
  static const opacityOnMissing = 0.5;

  const ItemStackReqCell({
    super.key,
    required this.slot,
    this.onTapSatisfied,
    this.onTapUnsatisfied,
    this.satisfiedTheme = const .new(),
    this.unsatisfiedTheme = const .new(),
  });

  @override
  Widget build(BuildContext context) {
    return slot >> (_) => buildBody(context);
  }

  Widget buildBody(BuildContext context) {
    final satisfyCondition = slot.isExactMatched;
    return CardButton(
      elevation: satisfyCondition ? 4 : 0,
      onTap: satisfyCondition ? onTapSatisfied : onTapUnsatisfied,
      shape: satisfyCondition ? null : context.outlinedCardBorder(),
      child: satisfyCondition
          ? ItemStackCell(slot.stack, theme: satisfiedTheme)
          : NullItemCell(theme: unsatisfiedTheme),
    );
  }
}

class ItemStackReqAutoMatchCell extends StatelessWidget {
  final ItemStackSlot slot;
  final VoidCallback? onTapSatisfied;
  final VoidCallback? onTapUnsatisfied;
  final ItemStackCellTheme satisfiedTheme;
  final ItemCellTheme onNotInBackpack;
  final ItemStackCellTheme onInBackpack;
  static const opacityOnMissing = 0.5;

  const ItemStackReqAutoMatchCell({
    super.key,
    required this.slot,
    this.onTapSatisfied,
    this.onTapUnsatisfied,
    this.satisfiedTheme = const .new(),
    this.onNotInBackpack = const .new(),
    this.onInBackpack = const .new(),
  });

  @override
  Widget build(BuildContext context) {
    return slot >> (_) => buildBody(context);
  }

  Widget buildBody(BuildContext context) {
    final satisfyCondition = slot.isNotEmpty;
    return CardButton(
      elevation: satisfyCondition ? 4 : 0,
      onTap: !satisfyCondition ? onTapUnsatisfied : onTapSatisfied,
      shape: !satisfyCondition ? context.outlinedCardBorder() : null,
      child: satisfyCondition
          ? ItemStackCell(slot.stack, theme: satisfiedTheme)
          : DynamicMatchingCell(
              matcher: slot.matcher,
              onNotInBackpack: (item) => ItemCell(item, theme: onNotInBackpack.copyWith(opacity: opacityOnMissing)),
              onInBackpack: (stack) =>
                  ItemStackCell(stack, theme: onInBackpack.copyWith(opacity: opacityOnMissing, showMass: false)),
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

abstract class BackpackSheetDelegate {
  const BackpackSheetDelegate();

  void onSelectItemStack(ItemStack stack, int? massOrPart);
}

class BackpackSheetItemStack extends BackpackSheetDelegate {
  final ValueChanged<ItemStack> onSelect;

  const BackpackSheetItemStack({required this.onSelect});

  @override
  void onSelectItemStack(ItemStack stack, int? massOrPart) {
    onSelect(stack);
  }
}

class BackpackSheetItemStackWithMass extends BackpackSheetDelegate {
  final void Function(ItemStack stack, int? mass) onSelect;

  const BackpackSheetItemStackWithMass({required this.onSelect});

  @override
  void onSelectItemStack(ItemStack stack, int? massOrPart) {
    onSelect(stack, massOrPart);
  }
}

class BackpackSheet extends StatefulWidget {
  final ItemMatcher matcher;
  final BackpackSheetDelegate? delegate;
  final BackpackFilterDisplayBehavior behavior;

  const BackpackSheet({super.key, required this.matcher, this.delegate, this.behavior = .toggleable});

  @override
  State<BackpackSheet> createState() => _BackpackSheetState();
}

class _BackpackSheetState extends State<BackpackSheet> {
  ItemMatcher get matcher => widget.matcher;
  List<ItemStack> accepted = const [];
  List<ItemStack> unaccepted = const [];
  bool toggleFilter = false;

  bool get showUnaccepted => widget.behavior == .both || (widget.behavior == .toggleable && !toggleFilter);

  @override
  void initState() {
    super.initState();
    updateBackpackFilter();
    player.addListener(updateBackpackFilter);
  }

  @override
  void dispose() {
    player.removeListener(updateBackpackFilter);
    super.dispose();
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
              expandedHeight: 50.0,
              leading: IconButton(
                icon: const Icon(TablerIcons.x),
                onPressed: () {
                  context.pop();
                },
              ),
              flexibleSpace: FlexibleSpaceBar(centerTitle: true, title: backpackTitle.text()),
              actions: [
                if (widget.behavior.showFilterButton)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        toggleFilter = !toggleFilter;
                      });
                    },
                    icon: Icon(toggleFilter ? TablerIcons.filter : TablerIcons.filter_off),
                  ),
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
      gridDelegate: context.itemCellGridDelegate,
      delegate: SliverChildBuilderDelegate(childCount: length, (ctx, i) {
        if (i < accepted.length) {
          return buildItem(accepted[i], accepted: true);
        } else {
          return buildItem(unaccepted[i - accepted.length], accepted: false);
        }
      }),
    );
  }

  Widget buildItem(ItemStack stack, {required bool accepted}) {
    final delegate = widget.delegate;
    return CardButton(
      elevation: accepted ? 4 : 0,
      onTap: !accepted || delegate == null
          ? null
          : () async {
              await onSelectItemStack(stack, delegate);
            },
      child: ItemStackCell(stack, theme: .new(opacity: accepted ? 1.0 : R.disabledAlpha)),
    );
  }

  final $selectedMass = ValueNotifier(0);

  Future<void> onSelectItemStack(ItemStack selected, BackpackSheetDelegate delegate) async {
    if (delegate is BackpackSheetItemStackWithMass && selected.meta.mergeable) {
      // if selected is mergeable, show a mass selector.
      $selectedMass.value = selected.stackMass;
      final confirmed = await context.showAnyRequest(
        title: selected.displayName(),
        builder: (_) => ItemStackMassSelector(template: selected, $selectedMass: $selectedMass),
        primary: "Select",
        secondary: I.cancel,
      );
      if (confirmed != true) return;
      final massOrPart = $selectedMass.value;
      if (massOrPart <= 0) return;
      delegate.onSelectItemStack(selected, massOrPart);
    } else {
      delegate.onSelectItemStack(selected, null);
    }
  }
}

extension BackpackBuildContextX on BuildContext {
  Future<T?> showBackpackSheet<T>({
    required ItemMatcher matcher,
    BackpackSheetDelegate? delegate,
    BackpackFilterDisplayBehavior behavior = .toggleable,
  }) async {
    return await showCupertinoModalBottomSheet<T>(
      context: this,
      enableDrag: false,
      builder: (ctx) => BackpackSheet(
        matcher: matcher,
        delegate: delegate,
        behavior: behavior,
      ).constrained(maxH: max(mediaQuery.size.height * 0.5, 380)),
    );
  }
}

class DurationStepper extends StatefulWidget {
  final ValueNotifier<Ts> $cur;
  final Ts min;
  final Ts max;
  final Ts step;

  const DurationStepper({super.key, required this.$cur, required this.min, required this.max, required this.step});

  @override
  State<DurationStepper> createState() => _DurationStepperState();
}

class _DurationStepperState extends State<DurationStepper> {
  var isPressing = false;

  ValueNotifier<Ts> get $duration => widget.$cur;

  Ts get cur => widget.$cur.value;

  set cur(Ts ts) => widget.$cur.value = ts;

  Ts get min => widget.min;

  Ts get max => widget.max;

  Ts get step => widget.step;

  @override
  Widget build(BuildContext context) {
    return $duration >> (ctx, ts) => buildBody(ts);
  }

  Widget buildBody(Ts ts) {
    return [
      buildStepper(isLeft: true),
      I.ts(ts).toUpperCase().text(style: context.textTheme.headlineSmall, textAlign: .end),
      buildStepper(isLeft: false),
    ].row(maa: .spaceEvenly);
  }

  Widget buildStepper({required bool isLeft}) {
    if (isLeft) {
      return buildStepperBtn(TablerIcons.chevron_left, canStep: () => cur > min, onStep: () => cur -= step);
    } else {
      return buildStepperBtn(TablerIcons.chevron_right, canStep: () => cur < max, onStep: () => cur += step);
    }
  }

  Widget buildStepperBtn(IconData icon, {required bool Function() canStep, required void Function() onStep}) {
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
      ),
    );
  }

  Widget buildIcon(IconData icon) {
    const iconSize = 48.0;
    return Icon(icon, size: iconSize);
  }

  @override
  void dispose() {
    super.dispose();
    isPressing = false;
  }
}
