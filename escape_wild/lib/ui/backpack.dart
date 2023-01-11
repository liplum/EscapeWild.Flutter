import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/theme.dart';
import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/game/items/foods.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';

import 'shared.dart';

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
      if (!mounted) return;
      if (_selected == null && player.backpack.isNotEmpty) {
        setState(() {
          _selected = player.backpack.firstOrNull;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: "Backpack".text(),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return AnimatedBuilder(
      animation: player.backpack,
      builder: (ctx, _) {
        final backpack = player.backpack;
        if (backpack.isEmpty) {
          return buildEmptyBackpack();
        } else {
          return [
            buildDetailArea(_selected).flexible(flex: 2),
            buildItems(player.backpack).flexible(flex: 5),
            buildButtonArea(_selected).flexible(flex: 1),
          ].column();
        }
      },
    );
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
    ].column().inCard();
  }

  Widget buildButtonArea(ItemEntry? item) {
    if (item == null) {
      // never reached.
      return "?".text();
    }
    final usable = item.meta.tryGetFirstComp<UsableItemComp>();
    if (usable != null) {
      return [
        CardButton(
          onTap: () {},
          child: usable.useType.localizeName().text(),
        )
      ].row();
    } else {
      return [
        CardButton(
          onTap: () {},
          child: "Can't Use".text(),
        ),
      ].row();
    }
  }

  Widget buildItem(ItemEntry item) {
    final isSelected = _selected == item;
    Widget label = item.meta
        .localizedName()
        .text(
          style: context.textTheme.titleLarge,
          textAlign: TextAlign.center,
        )
        .center();
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
