import 'package:escape_wild/core.dart';
import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/game/items/foods.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';

class BackpackPage extends StatefulWidget {
  const BackpackPage({super.key});

  @override
  State<BackpackPage> createState() => _BackpackPageState();
}

class _BackpackPageState extends State<BackpackPage> {
  @override
  void initState() {
    super.initState();
    player.backpack.addItem(ItemEntry(Foods.berry));
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
    return buildItems(player.backpack);
  }

  Widget buildItems(Backpack backpack) {
    return GridView.builder(
      itemCount: backpack.itemCount,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 180),
      itemBuilder: (ctx, i) {
        return buildItem(backpack[i]);
      },
    );
  }

  Widget buildItem(ItemEntry item) {
    return item.meta.localizedName.text(
      style: context.textTheme.titleLarge,
      textAlign: TextAlign.center
    );
  }
}
