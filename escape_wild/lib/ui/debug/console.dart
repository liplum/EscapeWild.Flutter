import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:escape_wild/core.dart';

import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/ui/game/shared.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';

part 'console.i18n.dart';

String get debugConsoleTitle => _I.title;

class DebugConsole extends StatefulWidget {
  const DebugConsole({super.key});

  @override
  State<DebugConsole> createState() => _DebugConsoleState();
}

class _Item {
  final String name;
  final WidgetBuilder builder;

  const _Item(this.name, this.builder);
}

class _DebugConsoleState extends State<DebugConsole> {
  late final List<_Item> items = buildItems();
  var selected = 0;

  @override
  Widget build(BuildContext context) {
    return [
      buildLeft().flexible(flex: 1),
      const VerticalDivider(thickness: 2),
      buildRight().flexible(flex: 3),
    ].row();
  }

  Widget buildLeft() {
    return ListView.builder(
      physics: const RangeMaintainingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final isSelected = selected == i;
        return ListTile(
          title: item.name.autoSizeText(maxLines: 1),
          selected: isSelected,
        ).inCard(elevation: isSelected ? 4 : 0);
      },
    );
  }

  Widget buildRight() {
    final item = items[selected];
    return item.builder(context);
  }

  List<_Item> buildItems() {
    final res = <_Item>[];
    res.add(_Item(_I.cat.item, (context) {
      return const _ItemGrid();
    }));
    return res;
  }
}

class _ItemGrid extends StatefulWidget {
  const _ItemGrid({super.key});

  @override
  State<_ItemGrid> createState() => _ItemGridState();
}

class _ItemGridState extends State<_ItemGrid> {
  @override
  Widget build(BuildContext context) {
    return buildGrid();
  }

  Widget buildGrid() {
    final items = Contents.items.toList().sortedBy((item) => item.l10nName());
    return GridView.builder(
      itemCount: items.length,
      physics: const RangeMaintainingScrollPhysics(),
      gridDelegate: itemCellSmallGridDelegate,
      itemBuilder: (ctx, i) {
        final item = items[i];
        return buildCell(item);
      },
    );
  }

  Widget buildCell(Item item) {
    return CardButton(
      elevation: 5,
      onTap: () {
        player.backpack.addItemOrMerge(item.create());
      },
      child: ItemCell(
        item,
        theme: ItemCellTheme(
          nameStyle: context.textTheme.titleSmall,
        ),
      ),
    );
  }
}
