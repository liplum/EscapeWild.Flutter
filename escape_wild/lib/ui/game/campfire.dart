import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/theme.dart';
import 'package:escape_wild/r.dart';
import 'package:escape_wild/ui/game/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
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
      body: player.$fireState <<
          (ctx, state, _) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: buildBody(state),
              ),
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
      setState(() {
        fireStarterSlot.stack = player.backpack[lastSelectedIndex];
      });
    }
    fireStarterSlot.onChange = (newStack) {
      lastSelectedIndex = player.backpack.indexOfStack(newStack);
    };
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
    await showCupertinoModalBottomSheet(
      context: context,
      enableDrag: false,
      builder: (ctx) => BackpackSheet(
        matcher: fireStarterSlot.matcher,
        onSelect: (selected) {
          if (!mounted) return;
          setState(() {
            fireStarterSlot.toggle(selected);
          });
          ctx.navigator.pop();
        },
      ).constrained(maxH: context.mediaQuery.size.height * 0.5),
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
}

class CookPage extends StatefulWidget {
  const CookPage({super.key});

  @override
  State<CookPage> createState() => _CookPageState();
}

class _CookPageState extends State<CookPage> {
  var $isCooking = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return [
      buildBackground(),
      buildBody(),
    ].stack();
  }

  Widget buildBackground() {
    return AnimatedCampfireImage(
      notCookingColor: context.themeColor,
      cookingColor: R.fireColor,
      $isCooking: $isCooking,
    ).center().opacity(0.35);
  }

  Widget buildBody() {
    return ElevatedButton(
      onPressed: () {
        $isCooking.value = !$isCooking.value;
      },
      child: "Cook".text(style: TextStyle(fontSize: 20)),
    ).align(at: Alignment.bottomCenter);
  }
}
