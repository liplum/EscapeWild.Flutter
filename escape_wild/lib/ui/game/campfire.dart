import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/theme.dart';
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
    return Scaffold(
      body: context.isPortrait ? buildPortrait() : buildLandscape(),
    );
  }

  Widget buildPortrait() {
    return [
      buildCampfire(),
      buildFireStarterCell(),
      buildTryButton(),
    ].column(maa: MainAxisAlignment.spaceEvenly).center();
  }

  Widget buildLandscape() {
    return [
      buildCampfire().expanded(),
      [
        buildFireStarterCell(),
        buildTryButton(),
      ]
          .column(
            caa: CrossAxisAlignment.center,
            maa: MainAxisAlignment.spaceEvenly,
          )
          .expanded()
    ].row();
  }

  Widget buildCampfire() {
    return buildFireImg("assets/img/campfire.svg");
  }

  Widget buildFireImg(String path) {
    return SvgPicture.asset(
      path,
      color: context.themeColor,
    ).constrained(maxW: 200, maxH: 200);
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

  Widget buildTryButton() {
    final maybeFireStarter = fireStarterSlot.stack;
    return CardButton(
      elevation: maybeFireStarter.isNotEmpty ? 12 : 0,
      onTap: maybeFireStarter.isEmpty
          ? null
          : () async {
              await onTry(maybeFireStarter);
            },
      child: "Try".text(style: context.textTheme.headlineSmall).center(),
    ).sized(w: 180, h: 80);
  }

  Future<void> onTry(ItemStack fireStarter) async {
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
