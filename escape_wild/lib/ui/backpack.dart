import 'package:auto_size_text/auto_size_text.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/dialog.dart';
import 'package:escape_wild/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';
import 'package:easy_localization/easy_localization.dart';

import 'shared.dart';

part 'backpack.i18n.dart';

class BackpackPage extends StatefulWidget {
  const BackpackPage({super.key});

  @override
  State<BackpackPage> createState() => _BackpackPageState();
}

class _BackpackPageState extends State<BackpackPage> {
  ItemEntry? _selected;

  @override
  void initState() {
    super.initState();
    player.backpack.addListener(() {
      updateDefaultSelection();
    });
    updateDefaultSelection();
  }

  void updateDefaultSelection() {
    if (_selected == null && player.backpack.isNotEmpty) {
      _selected = player.backpack.firstOrNull;
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: player.backpack,
      builder: (ctx, _) {
        return ctx.isPortrait ? buildPortrait() : buildLandscape();
      },
    );
  }

  Widget buildPortrait() {
    return Scaffold(
      appBar: AppBar(
        title: _I.massLoad(player.backpack.mass, player.maxMassLoad).text(),
        centerTitle: true,
      ),
      body: buildPortraitBody().safeArea().padAll(10),
    );
  }

  Widget buildLandscape() {
    return Scaffold(
      appBar: AppBar(
        title: _I.massLoad(player.backpack.mass, player.maxMassLoad).text(),
        centerTitle: true,
        toolbarHeight: 40,
      ),
      body: buildLandscapeBody().safeArea().padAll(10),
    );
  }

  Widget buildPortraitBody() {
    final backpack = player.backpack;
    if (backpack.isEmpty) {
      return buildEmptyBackpack();
    } else {
      return [
        buildDetailArea(_selected).flexible(flex: 2),
        buildItems(player.backpack).flexible(flex: 5),
        buildButtonArea(_selected).flexible(flex: 1),
      ].column(maa: MainAxisAlignment.spaceBetween);
    }
  }

  Widget buildLandscapeBody() {
    final backpack = player.backpack;
    if (backpack.isEmpty) {
      return buildEmptyBackpack();
    } else {
      return [
        [
          buildDetailArea(_selected).flexible(flex: 4),
          buildButtonArea(_selected).flexible(flex: 2),
        ].column(maa: MainAxisAlignment.spaceBetween).expanded(),
        buildItems(player.backpack).expanded(),
      ].row();
    }
  }

  Widget buildEmptyBackpack() {
    return LeavingBlank(
      icon: Icons.no_backpack_outlined,
      desc: _I.emptyTip,
    );
  }

  Widget buildItems(Backpack backpack) {
    return GridView.builder(
      itemCount: backpack.itemCount,
      physics: const RangeMaintainingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (ctx, i) {
        return buildItem(backpack[i]);
      },
    );
  }

  Widget buildDetailArea(ItemEntry? item) {
    if (item == null) {
      // never reached.
      return "?".text();
    }
    return [
      ListTile(
        title: item.displayName().text(style: context.textTheme.titleLarge),
        subtitle: item.meta.localizedDescription().text(),
      ),
    ].column().inCard(elevation: 4);
  }

  void removeItem(ItemEntry item) {
    var index = player.backpack.indexOfItem(item);
    if (index == player.backpack.itemCount - 1) {
      // If current item is the last one, go to previous one.
      index--;
    }
    player.backpack.removeItem(item);
    final itemCount = player.backpack.itemCount;
    if (itemCount > 0) {
      // If the index is not changed, it should be the next one.
      index = (index % itemCount).clamp(0, itemCount - 1);
      _selected = player.backpack[index];
    } else {
      _selected = null;
    }
  }

  Widget buildButtonArea(ItemEntry? item) {
    if (item == null) {
      // never reached.
      return "?".text();
    }
    Widget btn(String text, {VoidCallback? onTap, Color? color}) {
      return CardButton(
        onTap: onTap,
        elevation: onTap != null ? 5 : 0,
        child: text
            .text(
              style: context.textTheme.headlineMedium?.copyWith(
                color: color,
              ),
              textAlign: TextAlign.center,
            )
            .padAll(10),
      ).expanded();
    }

    final buttons = <Widget>[];
    final discardBtn = btn(
      I.discard,
      onTap: () async {
        await onDiscard(item);
      },
      color: Colors.redAccent,
    );
    buttons.add(discardBtn);
    final usableComps = item.meta.getCompsOf<UsableComp>();
    final useType = _matchBestUseType(usableComps);
    if (usableComps.isNotEmpty) {
      buttons.add(btn(
        useType.localizeName(),
        onTap: () async {
          await onUse(item, useType, usableComps);
        },
      ));
    } else {
      buttons.add(btn("Can't Use", onTap: null));
    }
    return buttons.row();
  }

  final $selectedMass = ValueNotifier(0);

  Future<void> onDiscard(ItemEntry item) async {
    if (item.meta.mergeable) {
      $selectedMass.value = item.actualMass;
      final confirmed = await context.showAnyRequest(
        title: _I.discardRequest,
        make: (_) => ItemEntryMassSelector(
          template: item,
          $selectedMass: $selectedMass,
        ),
        yes: I.discard,
        no: I.cancel,
        highlight: true,
      );
      if (confirmed == true) {
        player.backpack.changeMass(item, item.actualMass - $selectedMass.value);
      }
    } else {
      final confirmed = await context.showRequest(
        title: _I.discardRequest,
        desc: _I.discardConfirm(item.displayName()),
        yes: I.discard,
        no: I.cancel,
        highlight: true,
      );
      if (confirmed == true) {
        removeItem(item);
      }
    }
  }

  Future<void> onUse(ItemEntry item, UseType useType, List<UsableComp> usableComps) async {
    // TODO: Handle with mergeable
    if (false && item.meta.mergeable) {
    } else {
      final confirmed = await context.showRequest(
        title: useType.localizeName(),
        desc: _I.discardConfirm(item.displayName()),
        yes: useType.localizeName(),
        no: I.cancel,
        highlight: true,
      );
      if (confirmed == true) {
        for (final usableComp in usableComps) {
          await usableComp.onUse(item);
        }
        removeItem(item);
      }
    }
  }

  Widget buildItem(ItemEntry item) {
    final isSelected = _selected == item;
    Widget label = ListTile(
      title: AutoSizeText(
        item.meta.localizedName(),
        style: context.textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      subtitle: I.item.massWithUnit(item.actualMass.toString()).text(textAlign: TextAlign.right),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
    ).center();
    return CardButton(
      elevation: isSelected ? 20 : 1,
      onTap: () {
        if (_selected != item) {
          setState(() {
            _selected = item;
          });
        }
      },
      child: label,
    );
  }
}

UseType _matchBestUseType(Iterable<UsableComp> comps) {
  UseType? type;
  for (final comp in comps) {
    if (type == null) {
      type = comp.useType;
    } else if (type == UseType.use) {
      type = comp.useType;
      break;
    }
  }
  return type ?? UseType.use;
}
