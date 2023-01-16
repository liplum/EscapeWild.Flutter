import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/theme.dart';
import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/r.dart';
import 'package:escape_wild/ui/game/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rettulf/rettulf.dart';

class CampfirePage extends StatefulWidget {
  const CampfirePage({super.key});

  @override
  State<CampfirePage> createState() => _CampfirePageState();
}

class _CampfirePageState extends State<CampfirePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (player.$fireState <<
              (ctx, state, _) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: buildBody(state),
                  ))
          .padAll(5),
    );
  }

  Widget buildBody(FireState fireState) {
    if (fireState.active) {
      return const CookPage();
    } else {
      return const FireStartingPage();
    }
  }
}

class CampfireImage extends StatelessWidget {
  final Color? color;

  const CampfireImage({
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

class AnimatedCampfireImage extends StatefulWidget {
  final Color notCookingColor;
  final Color cookingColor;
  final ValueNotifier<bool> $isCooking;

  const AnimatedCampfireImage({
    super.key,
    required this.notCookingColor,
    required this.cookingColor,
    required this.$isCooking,
  });

  @override
  State<AnimatedCampfireImage> createState() => _AnimatedCampfireImageState();
}

class _AnimatedCampfireImageState extends State<AnimatedCampfireImage> with SingleTickerProviderStateMixin {
  late AnimationController _animationCtrl;
  late Animation _burningAnimation;
  bool? lastCookingState;

  @override
  void initState() {
    super.initState();
    _animationCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _burningAnimation = ColorTween(begin: widget.notCookingColor, end: widget.cookingColor).animate(_animationCtrl);
    widget.$isCooking.addListener(onCookingStateChange);
  }

  void onCookingStateChange() {
    final newState = widget.$isCooking.value;
    if (newState != lastCookingState) {
      if (newState) {
        // start cooking
        _animationCtrl.forward();
      } else {
        // end cooking
        _animationCtrl.reverse();
      }
      lastCookingState = newState;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _burningAnimation,
      builder: (ctx, _) => CampfireImage(
        color: _burningAnimation.value,
      ),
    );
  }

  @override
  void dispose() {
    widget.$isCooking.removeListener(onCookingStateChange);
    _animationCtrl.dispose();
    super.dispose();
  }
}

class FireStartingPage extends StatefulWidget {
  const FireStartingPage({super.key});

  @override
  State<FireStartingPage> createState() => _FireStartingPageState();
}

class _FireStartingPageState extends State<FireStartingPage> {
  final fireStarterSlot = ItemStackReqSlot(ItemMatcher.hasComp([FireStarterComp]));
  static int lastSelectedIndex = -1;

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
    return context.isPortrait ? buildPortrait() : buildLandscape();
  }

  Widget buildPortrait() {
    return [
      const CampfireImage(),
      buildFireStarterCell(),
      buildStartFireButton(),
    ].column(maa: MainAxisAlignment.spaceEvenly).center();
  }

  Widget buildLandscape() {
    return [
      const CampfireImage().expanded(),
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
    Widget cell = ItemStackReqCell(
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
    await context.showMatchBackpack(
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
      child: "Start Fire".text(style: context.textTheme.headlineSmall).center(),
    ).sized(w: 180, h: 80);
  }

  Future<void> onStartFire(ItemStack fireStarter) async {
    final comp = FireStarterComp.of(fireStarter);
    assert(comp != null, "$fireStarter doesn't have $FireStarterComp.");
    if (comp != null) {
      final started = comp.tryStartFire(fireStarter);
      if (started) {
        player.fireState = FireState.active(fuel: FuelComp.tryGetHeatValue(fireStarter));
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
  const CookPage({super.key});

  @override
  State<CookPage> createState() => _CookPageState();
}

class _CookPageState extends State<CookPage> {
  var $isCooking = ValueNotifier(false);
  final cookSlot = ItemStackReqSlot(ItemMatcher.hasComp(const [CookableComp]));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return [
      buildBackground(),
      buildBody(),
      player.$fireState << (_, state, __) => buildFuelState(state),
      buildFoodSlot(),
    ].stack();
  }

  Widget buildBackground() {
    return AnimatedCampfireImage(
      notCookingColor: context.themeColor,
      cookingColor: R.flameColor,
      $isCooking: $isCooking,
    ).center().opacity(0.35);
  }

  Widget buildFoodSlot() {
    return ItemStackReqCell(
      slot: cookSlot,
      onTapUnsatisfied: selectFood,
      onTapSatisfied: selectFood,
    ).aspectRatio(aspectRatio: 1.5).constrained(maxW: 160).align(at: const Alignment(0.0, -0.55));
  }

  Future<void> selectFood() async {
    final selected = await context.showMatchBackpack<ItemStack>(
      matcher: cookSlot.matcher,
      onSelect: (selected) async {
        context.navigator.pop(selected);
      },
    );
    if (selected == null) return;
    if (!mounted) return;
    setState(() {
      cookSlot.toggle(selected);
    });
  }

  Widget buildBody() {
    final canCook = cookSlot.isNotEmpty && player.fireFuel > 0;
    final cookBtn = CardButton(
      elevation: canCook ? 5 : null,
      onTap: !canCook
          ? null
          : () async {
              final raw = cookSlot.stack;
              final cookComp = CookableComp.of(raw);
              if (cookComp == null) return;
              final maxCookablePart = cookComp.getMaxCookablePart(raw, player.fireFuel);
              if (maxCookablePart <= 0) return;
              final partToCook = player.backpack.splitItemInBackpack(raw, maxCookablePart);
              $isCooking.value = true;
              await Future.delayed(const Duration(milliseconds: 500));
              player.fireFuel -= cookComp.getActualFuelCost(partToCook);
              await Future.delayed(const Duration(milliseconds: 500));
              $isCooking.value = false;
              final result = cookComp.cook(partToCook);
              player.backpack.addItemOrMerge(result);
              cookSlot.resetIfEmpty();
              if (!mounted) return;
              setState(() {});
            },
      child: "Cook".autoSizeText(style: context.textTheme.headlineSmall, textAlign: TextAlign.center).padAll(10),
    ).expanded();
    final fuelBtn = CardButton(
      elevation: 5,
      onTap: onFuel,
      child: "Fuel".autoSizeText(style: context.textTheme.headlineSmall, textAlign: TextAlign.center).padAll(10),
    ).expanded();
    return [
      cookBtn,
      fuelBtn,
    ].row(maa: MainAxisAlignment.spaceEvenly).align(at: Alignment.bottomCenter);
  }

  Future<void> onFuel() async {
    final selected = await context.showMatchBackpack<ItemStack>(
      matcher: ItemMatcher.hasComp(const [FuelComp]),
      onSelect: (selected) async {
        context.navigator.pop(selected);
      },
    );
    if (selected == null) return;
    if (!mounted) return;
    final heatValue = FuelComp.tryGetHeatValue(selected);
    player.fireFuel += heatValue;
    player.backpack.removeStack(selected);
  }

  Widget buildFuelState(FireState state) {
    return LayoutBuilder(
      builder: (_, box) {
        final length = box.maxHeight * 0.4;
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
        color: R.fuelYellowColor,
      ).constrained(maxW: length),
    );
  }

  @override
  void dispose() {
    cookSlot.dispose();
    super.dispose();
  }
}
