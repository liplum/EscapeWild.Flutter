import 'package:escape_wild/core.dart';
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

Widget buildEmptyBackpack() {
  return LeavingBlank(
    icon: Icons.no_backpack_outlined,
    desc: _I.emptyTip,
  );
}

class _BackpackPageState extends State<BackpackPage> {
  ItemStack? _selected;

  ItemStack? get $selected => _selected;
  static int lastSelectedIndex = 0;

  set $selected(ItemStack? v) {
    _selected = v;
    lastSelectedIndex = player.backpack.indexOfStack(v);
  }

  @override
  void initState() {
    super.initState();
    player.backpack.addListener(() {
      updateDefaultSelection();
    });
    if (lastSelectedIndex >= 0) {
      $selected = player.backpack[lastSelectedIndex];
    }
    updateDefaultSelection();
  }

  void updateDefaultSelection() {
    if ($selected == null && player.backpack.isNotEmpty) {
      $selected = player.backpack.firstOrNull;
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
        automaticallyImplyLeading: false,
      ),
      body: buildPortraitBody().safeArea().padAll(5),
    );
  }

  Widget buildLandscape() {
    return Scaffold(
      appBar: AppBar(
        title: _I.massLoad(player.backpack.mass, player.maxMassLoad).text(),
        centerTitle: true,
        toolbarHeight: 40,
      ),
      body: buildLandscapeBody().safeArea().padAll(5),
    );
  }

  Widget buildPortraitBody() {
    final backpack = player.backpack;
    if (backpack.isEmpty) {
      return buildEmptyBackpack();
    } else {
      return [
        buildDetailArea($selected).flexible(flex: 2),
        buildItems(player.backpack).flexible(flex: 5),
        buildButtonArea($selected).flexible(flex: 1),
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
          buildDetailArea($selected).flexible(flex: 4),
          buildButtonArea($selected).flexible(flex: 2),
        ].column(maa: MainAxisAlignment.spaceBetween).expanded(),
        buildItems(player.backpack).expanded(),
      ].row();
    }
  }

  Widget buildItems(Backpack backpack) {
    return GridView.builder(
      itemCount: backpack.itemCount,
      physics: const RangeMaintainingScrollPhysics(),
      gridDelegate: itemCellGridDelegate,
      itemBuilder: (ctx, i) {
        return buildItem(backpack[i]);
      },
    );
  }

  Widget buildDetailArea(ItemStack? item) {
    if (item == null) {
      // never reached.
      return "?".text();
    }
    return [
      ListTile(
        title: item.displayName().text(style: context.textTheme.titleLarge),
        subtitle: item.meta.l10nDescription().text(),
      ),
    ].column().inCard(elevation: 4);
  }

  void removeItem(ItemStack item) {
    runAndTrackCurrentSelected(item, () {
      player.backpack.removeStack(item);
    });
  }

  void runAndTrackCurrentSelected(ItemStack item, Function() between) {
    if (item == $selected) {
      var index = player.backpack.indexOfStack(item);
      var isLast = false;
      if (index == player.backpack.itemCount - 1) {
        isLast = true;
      }
      between();
      if (isLast && item.isEmpty) {
        // If current item is the last one and empty after running [between()], go to previous one.
        index--;
      }
      final itemCount = player.backpack.itemCount;
      if (itemCount > 0) {
        // If the index is not changed, it should be the next one.
        index = (index % itemCount).clamp(0, itemCount - 1);
        $selected = player.backpack[index];
      } else {
        $selected = null;
      }
    } else {
      between();
    }
  }

  Future<void> runAndTrackCurrentSelectedAsync(ItemStack item, Future Function() between) async {
    if (item == $selected) {
      var index = player.backpack.indexOfStack(item);
      var isLast = false;
      if (index == player.backpack.itemCount - 1) {
        isLast = true;
      }
      await between();
      if (isLast && item.isEmpty) {
        // If current item is the last one and empty after running [between()], go to previous one.
        index--;
      }
      final itemCount = player.backpack.itemCount;
      if (itemCount > 0) {
        // If the index is not changed, it should be the next one.
        index = (index % itemCount).clamp(0, itemCount - 1);
        $selected = player.backpack[index];
      } else {
        $selected = null;
      }
    } else {
      between();
    }
  }

  Widget buildButtonArea(ItemStack? item) {
    if (item == null) {
      // never reached.
      return "?".text();
    }
    Widget btn(String text, {VoidCallback? onTap, Color? color}) {
      final canAct = player.canPlayerAct() && onTap != null;
      return CardButton(
        onTap: !canAct ? null : onTap,
        elevation: canAct ? 5 : 0,
        child: text
            .autoSizeText(
              style: context.textTheme.headlineSmall?.copyWith(
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
        useType.l10nName(),
        onTap: () async {
          await onUse(item, useType, usableComps);
        },
      ));
    } else {
      buttons.add(btn(UseType.use.l10nName(), onTap: null));
    }
    return buttons.row();
  }

  final $selectedMass = ValueNotifier(0);

  Future<void> onDiscard(ItemStack item) async {
    if (item.meta.mergeable) {
      $selectedMass.value = item.stackMass;
      final confirmed = await context.showAnyRequest(
        title: _I.discardRequest,
        make: (_) => ItemStackMassSelector(
          template: item,
          $selectedMass: $selectedMass,
        ),
        yes: I.discard,
        no: I.cancel,
        highlight: true,
      );
      if (confirmed == true) {
        final selectedMassOrPart = $selectedMass.value;
        if (selectedMassOrPart > 0) {
          runAndTrackCurrentSelected(item, () {
            // discard the part.
            final _ = player.backpack.splitItemInBackpack(item, selectedMassOrPart);
          });
        }
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

  final $isShowAttrPreview = ValueNotifier(true);

  Widget buildShowAttrPreviewToggle() {
    return $isShowAttrPreview <<
        (_, b, __) => Switch(
            value: b,
            onChanged: (newV) {
              $isShowAttrPreview.value = newV;
            });
  }

  Future<void> onUse(ItemStack item, UseType useType, List<UsableComp> usableComps) async {
    final modifiers = usableComps.ofType<ModifyAttrComp>().toList(growable: false);
    if (item.meta.mergeable) {
      $selectedMass.value = item.stackMass;
      final confirmed = await context.showAnyRequest(
        title: item.displayName(),
        isPrimaryDefault: true,
        make: (_) => MergeableItemStackUsePreview(
          template: item,
          useType: useType,
          $selectedMass: $selectedMass,
          comps: modifiers,
        ),
        yes: useType.l10nName(),
        no: I.cancel,
      );
      if (confirmed == true) {
        final selectedMassOrPart = $selectedMass.value;
        if (selectedMassOrPart > 0) {
          await runAndTrackCurrentSelectedAsync(item, () async {
            final part = player.backpack.splitItemInBackpack(item, selectedMassOrPart);
            for (final usableComp in usableComps) {
              await usableComp.onUse(part);
            }
          });
        }
      }
    } else {
      $isShowAttrPreview.value = true;
      final confirmed = await context.showAnyRequest(
        title: item.displayName(),
        titleTrailing: buildShowAttrPreviewToggle(),
        make: (_) => UnmergeableItemStackUsePreview(
          item: item,
          comps: modifiers,
          $isShowAttrPreview: $isShowAttrPreview,
        ),
        yes: useType.l10nName(),
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

  Widget buildItem(ItemStack item) {
    final isSelected = $selected == item;
    return CardButton(
      elevation: isSelected ? 20 : 0.8,
      onTap: () {
        if ($selected != item) {
          setState(() {
            $selected = item;
          });
        }
      },
      child: ItemStackCell(item),
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
