import 'dart:async';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/theme.dart';
import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/r.dart';
import 'package:escape_wild/ui/game/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:noitcelloc/noitcelloc.dart';
import 'package:rettulf/rettulf.dart';

part 'campfire.i18n.dart';

class CampfirePage extends StatefulWidget {
  const CampfirePage({super.key});

  @override
  State<CampfirePage> createState() => _CampfirePageState();
}

class _CampfirePageState extends State<CampfirePage> {
  @override
  Widget build(BuildContext context) {
    final loc = player.location;
    if (loc is CampfireHolderProtocol) {
      final holder = loc as CampfireHolderProtocol;
      final $fireState = holder.$fireState;
      final mainBody = $fireState <<
          (ctx, state, _) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: buildBody($fireState, holder),
              );
      return mainBody;
    } else {
      return LeavingBlank(icon: Icons.close_rounded, desc: "Here doesn't allow fire.");
    }
  }

  Widget buildBody(ValueNotifier<FireState> $fireState, CampfireHolderProtocol holder) {
    if ($fireState.value.active) {
      return CookPage(
        $fireState: $fireState,
        campfireHolder: holder,
      );
    } else {
      return FireStartingPage($fireState: $fireState);
    }
  }
}

class FireStartingPage extends StatefulWidget {
  final ValueNotifier<FireState> $fireState;

  const FireStartingPage({
    super.key,
    required this.$fireState,
  });

  @override
  State<FireStartingPage> createState() => _FireStartingPageState();
}

class _FireStartingPageState extends State<FireStartingPage> {
  final fireStarterSlot = ItemStackReqSlot(ItemMatcher.hasComp([FireStarterComp]));
  static int lastSelectedIndex = -1;

  FireState get fireState => widget.$fireState.value;

  set fireState(FireState v) => widget.$fireState.value = v;

  @override
  void initState() {
    super.initState();
    if (lastSelectedIndex >= 0) {
      final lastSelected = player.backpack[lastSelectedIndex];
      if (fireStarterSlot.matcher.exact(lastSelected).isMatched) {
        setState(() {
          fireStarterSlot.stack = lastSelected;
        });
      }
    }
    fireStarterSlot.addListener(() {
      final newStack = fireStarterSlot.stack;
      lastSelectedIndex = player.backpack.indexOfStack(newStack);
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = context.isPortrait ? buildPortrait() : buildLandscape();
    return body.padAll(5);
  }

  Widget buildPortrait() {
    return [
      const StaticCampfireImage(),
      buildFireStarterCell(),
      buildStartFireButton(),
    ].column(maa: MainAxisAlignment.spaceEvenly).center();
  }

  Widget buildLandscape() {
    return [
      const StaticCampfireImage().expanded(),
      [
        buildFireStarterCell(),
        buildStartFireButton(),
      ]
          .column(
            caa: CrossAxisAlignment.center,
            maa: MainAxisAlignment.spaceEvenly,
          )
          .expanded()
    ].row();
  }

  Widget buildFireStarterCell() {
    Widget cell = ItemStackReqAutoMatchCell(
      slot: fireStarterSlot,
      onTapSatisfied: onSelectFireStarter,
      onTapUnsatisfied: onSelectFireStarter,
      onInBackpack: const ItemStackCellTheme(
        showMass: false,
        showProgressBar: false,
      ),
    ).constrained(maxW: 180, maxH: 80);
    return cell;
  }

  Future<void> onSelectFireStarter() async {
    await context.showBackpackSheet(
      matcher: fireStarterSlot.matcher,
      onSelect: (selected) {
        if (!mounted) return;
        setState(() {
          fireStarterSlot.toggle(selected);
        });
        context.navigator.pop();
      },
    );
  }

  Widget buildStartFireButton() {
    final maybeFireStarter = fireStarterSlot.stack;
    return CardButton(
      elevation: maybeFireStarter.isNotEmpty ? 12 : 0.5,
      onTap: maybeFireStarter.isEmpty
          ? null
          : () async {
              await onStartFire(maybeFireStarter);
            },
      child: _I.startFire.text(style: context.textTheme.headlineSmall).center(),
    ).sized(w: 180, h: 80);
  }

  Future<void> onStartFire(ItemStack fireStarter) async {
    final comp = FireStarterComp.of(fireStarter);
    assert(comp != null, "$fireStarter doesn't have $FireStarterComp.");
    if (comp != null) {
      final started = comp.tryStartFire(fireStarter);
      if (started) {
        fireState = FireState(fuel: FuelComp.tryGetHeatValue(fireStarter));
      }
      if (DurabilityComp.tryGetIsBroken(fireStarter)) {
        player.backpack.removeStack(fireStarter);
        fireStarterSlot.reset();
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    fireStarterSlot.dispose();
    super.dispose();
  }
}

class CookPage extends StatefulWidget {
  final ValueNotifier<FireState> $fireState;
  final CampfireHolderProtocol campfireHolder;

  const CookPage({
    super.key,
    required this.$fireState,
    required this.campfireHolder,
  });

  @override
  State<CookPage> createState() => _CookPageState();
}

class _CookPageState extends State<CookPage> {
  final cookMatcher = ItemMatcher.hasAnyTag(["cookable", "cooker"]);
  late final List<ItemStackReqSlot> cookSlots =
      List.generate(CookRecipeProtocol.maxSlot, (i) => ItemStackReqSlot(cookMatcher));

  FireState get fireState => widget.$fireState.value;

  set fireState(FireState v) => widget.$fireState.value = v;

  double get fireFuel => fireState.fuel;

  set fireFuel(double v) => fireState = fireState.copyWith(fuel: v);

  @override
  void initState() {
    super.initState();
    readCookSlots();
  }

  void writeCookSlots() {
    final cur = cookSlots.where((slot) => slot.isNotEmpty).map((slot) => slot.stack).toList(growable: false);
    widget.campfireHolder.onCampfire = cur;
  }

  void readCookSlots() {
    final items = widget.campfireHolder.onCampfire;
    for (var i = 0; i < min(items.length, items.length); i++) {
      cookSlots[i].stack = items[i];
    }
  }

  @override
  Widget build(BuildContext context) {
    return context.isPortrait ? buildBodyPortrait() : buildBodyLandscape();
  }

  Widget buildBodyPortrait() {
    return Scaffold(
      appBar: AppBar(
        title: "Campfire".text(),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: [
        buildFoodGrid().flexible(flex: 2),
        buildCampfire().flexible(flex: 4),
        buildButtons().flexible(flex: 1),
      ].column(maa: MainAxisAlignment.spaceBetween).padAll(5),
    );
  }

  Widget buildBodyLandscape() {
    return [
      buildFoodGrid().flexible(flex: 4),
      [
        LayoutBuilder(builder: (_, box) => buildCampfire().constrained(maxH: box.maxWidth * 0.5)),
        buildButtons(),
      ].column(maa: MainAxisAlignment.center).flexible(flex: 4),
    ].row();
  }

  Widget buildCampfire() {
    return [
      buildBackground(),
      widget.$fireState << (_, state, __) => buildFuelState(state),
    ].stack();
  }

  Widget buildBackground() {
    return AnimatedBuilder(
      animation: widget.$fireState,
      builder: (ctx, _) => DynamicCampfireImage(
        color: Color.lerp(context.themeColor, R.flameColor, fireState.fuel / FireState.maxVisualFuel)!,
      ),
    ).center().opacity(0.45);
  }

  Widget buildFoodGrid() {
    final cells = <Widget>[];
    for (final slot in cookSlots) {
      final cell = ItemStackReqCell(
        slot: slot,
        //onTapUnsatisfied: selectFood,
        //onTapSatisfied: selectFood,
      ).constrained(maxW: 180);
      cells.add(cell);
    }
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: context.itemCellGridDelegate,
      children: cells,
    );
  }

  final $selectedMass = ValueNotifier(0);

  Future<void> onAdd() async {
    await context.showBackpackSheet<ItemStack>(
      matcher: cookMatcher,
      onSelect: (selected) async {
        $selectedMass.value = selected.stackMass;
        final confirmed = await context.showAnyRequest(
          title: selected.displayName(),
          make: (_) => ItemStackMassSelector(
            template: selected,
            $selectedMass: $selectedMass,
          ),
          yes: "Add",
          no: I.cancel,
          highlight: true,
        );
        if (confirmed != true) return;
        final selectedMassOrPart = $selectedMass.value;
        if (selectedMassOrPart <= 0) return;
        context.navigator.pop(selected);
        final slot = findAvailableSlot();
        if (slot == null) return;
        final part = player.backpack.splitItemInBackpack(selected, selectedMassOrPart);
        slot.stack = part;
        writeCookSlots();
      },
    );
  }

  ItemStackReqSlot? findAvailableSlot() {
    for (var i = 0; i < min(cookSlots.length, CookRecipeProtocol.maxIngredient); i++) {
      final slot = cookSlots[i];
      if (slot.isEmpty) return slot;
    }
    return null;
  }

  Widget buildButtons() {
    final canAdd = cookSlots.count((slot) => slot.isNotEmpty) < CookRecipeProtocol.maxIngredient;
    final cookBtn = CardButton(
      onTap: canAdd ? onAdd : null,
      elevation: canAdd ? 5 : 0,
      child: "Add".autoSizeText(style: context.textTheme.headlineSmall, textAlign: TextAlign.center).padAll(10),
    ).expanded();
    final fuelBtn = CardButton(
      elevation: 5,
      onTap: onFuel,
      child: _I.fuel.autoSizeText(style: context.textTheme.headlineSmall, textAlign: TextAlign.center).padAll(10),
    ).expanded();
    return [
      cookBtn,
      fuelBtn,
    ].row(maa: MainAxisAlignment.spaceEvenly).align(at: Alignment.bottomCenter);
  }

  Future<void> onFuel() async {
    final selected = await context.showBackpackSheet<ItemStack>(
      matcher: ItemMatcher.hasComp(const [FuelComp]),
      onSelect: (selected) async {
        context.navigator.pop(selected);
      },
    );
    if (selected == null) return;
    if (!mounted) return;
    final heatValue = FuelComp.tryGetHeatValue(selected);
    fireFuel += heatValue;
    player.backpack.removeStack(selected);
  }

  Widget buildFuelState(FireState state) {
    return LayoutBuilder(
      builder: (_, box) {
        final length = box.maxHeight * 0.6;
        final halfP = state.fuel / FireState.maxVisualFuel / 2;
        final left = buildFuelProgress(halfP, length);
        final right = buildFuelProgress(halfP, length);
        return [
          left,
          right,
        ].row(maa: MainAxisAlignment.spaceBetween);
      },
    ).center();
  }

  Widget buildFuelProgress(Ratio progress, double length) {
    return RotatedBox(
      quarterTurns: -1,
      child: AttrProgress(
        value: progress,
        minHeight: 16,
        color: context.fixColorBrightness(R.fuelYellowColor),
      ).constrained(maxW: length),
    ).padH(12);
  }

  @override
  void dispose() {
    for (final cookSlot in cookSlots) {
      cookSlot.dispose();
    }
    super.dispose();
  }
}

class StaticCampfireImage extends StatelessWidget {
  final Color? color;

  const StaticCampfireImage({
    super.key,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/img/campfire.svg",
      //color: context.themeColor,
      color: color ?? context.themeColor,
      placeholderBuilder: (_) => const Placeholder(),
    ).constrained(maxW: 200, maxH: 200);
  }
}

class DynamicCampfireImage extends ImplicitlyAnimatedWidget {
  final Color color;

  const DynamicCampfireImage({
    super.key,
    super.duration = const Duration(milliseconds: 1200),
    required this.color,
    super.curve = Curves.fastLinearToSlowEaseIn,
  });

  @override
  ImplicitlyAnimatedWidgetState<DynamicCampfireImage> createState() => _DynamicCampfireImageState();
}

class _DynamicCampfireImageState extends AnimatedWidgetBaseState<DynamicCampfireImage> {
  late ColorTween $color;

  @override
  void initState() {
    $color = ColorTween(
      begin: widget.color,
      end: widget.color,
    );
    super.initState();
    if ($color.begin != $color.end) {
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
    return StaticCampfireImage(
      color: $color.animate(animation).value,
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    $color = visitor($color, widget.color, (dynamic value) {
      assert(false);
      throw StateError('Constructor will never be called because null is never provided as current tween.');
    }) as ColorTween;
  }
}
