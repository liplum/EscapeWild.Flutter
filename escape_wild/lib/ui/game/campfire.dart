import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/theme.dart';
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
  final fireStarterSlot = ItemStackReqSlot(ItemMatcher.hasComp([FireStarterComp]));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: context.isPortrait ? buildPortrait() : buildLandscape(),
    );
  }

  Widget buildPortrait() {
    return [
      SvgPicture.asset(
        "assets/img/campfire.svg",
        color: context.themeColor,
      ).constrained(maxH: 200),
      buildFireStarterCell(),
      buildTryButton(),
    ].column(maa: MainAxisAlignment.spaceEvenly).center();
  }

  Widget buildLandscape() {
    return [
      SvgPicture.asset(
        "assets/img/campfire.svg",
        color: context.themeColor,
      ).constrained(maxH: 200).expanded(),
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

  Widget buildFireStarterCell() {
    return ItemStackReqCell(
      slot: fireStarterSlot,
      onSatisfy: (stack) => wrapCell(ItemStackCell(stack)),
      onNotInBackpack: (item) => wrapCell(ItemCell(item)),
      onInBackpack: (stack) => wrapCell(ItemStackCell(stack, showMass: false)),
    );
  }

  Widget wrapCell(Widget child) {
    return child.inCard().constrained(maxW: 180, maxH: 80);
  }

  Widget buildTryButton() {
    return CardButton(
      elevation: 12,
      child: "Try".text(style: context.textTheme.headlineSmall).center(),
    ).sized(w: 180, h: 80);
  }
}
