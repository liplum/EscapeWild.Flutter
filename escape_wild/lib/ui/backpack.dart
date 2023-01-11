import 'package:auto_size_text/auto_size_text.dart';
import 'package:escape_wild/core.dart';
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
        return Scaffold(
          appBar: AppBar(
            title: _I.massLoad(player.backpack.mass, player.maxMassLoad).text(),
            centerTitle: true,
          ),
          body: buildBody(),
        );
      },
    );
  }

  Widget buildBody() {
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

  Widget buildEmptyBackpack() {
    return Icon(Icons.no_backpack_outlined);
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
    player.backpack.removeItem(item);
    final itemCount = player.backpack.itemCount;
    if (itemCount > 0) {
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
      _I.discard,
      onTap: () {
        // TODO: Handle with mergeable
        removeItem(item);
      },
      color: Colors.redAccent,
    );
    buttons.add(discardBtn);
    final usableComps = item.meta.getCompsOf<UsableComp>();
    if (usableComps.isNotEmpty) {
      buttons.add(btn(
        _matchBestUseType(usableComps).localizeName(),
        onTap: () async {
          // TODO: Handle with mergeable
          for (final usableComp in usableComps) {
            await usableComp.onUse(item);
          }
          removeItem(item);
        },
      ));
    } else {
      buttons.add(btn("Can't Use", onTap: null));
    }
    return buttons.row();
  }

  Widget buildItem(ItemEntry item) {
    final isSelected = _selected == item;
    Widget label = AutoSizeText(
      item.meta.localizedName(),
      style: context.textTheme.titleLarge,
      textAlign: TextAlign.center,
    ).center().padSymmetric(h: 2);
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
