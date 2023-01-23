import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/theme.dart';
import 'package:escape_wild/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:noitcelloc/noitcelloc.dart';
import 'package:rettulf/rettulf.dart';
import 'package:easy_localization/easy_localization.dart';

import 'shared.dart';

part 'backpack.i18n.dart';

String get backpackTitle => _I.title;

class BackpackPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  BackpackPage({super.key});

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
  int selectedIndex = 0;

  ItemStack get selected => player.backpack[selectedIndex];

  static int lastSelectedIndex = 0;

  set selected(ItemStack v) {
    selectedIndex = player.backpack.indexOfStack(v);
    lastSelectedIndex = selectedIndex;
  }

  @override
  void initState() {
    super.initState();
    player.addListener(updateDefaultSelection);
    if (lastSelectedIndex >= 0) {
      selected = player.backpack[lastSelectedIndex];
    }
    updateDefaultSelection();
  }

  @override
  void dispose() {
    player.removeListener(updateDefaultSelection);
    super.dispose();
  }

  void updateDefaultSelection() {
    if (selected.isEmpty && player.backpack.isNotEmpty) {
      selected = player.backpack.firstOrEmpty;
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          onPointerScroll(pointerSignal);
        }
      },
      child: context.isPortrait ? buildPortrait() : buildLandscape(),
    );
  }

  void onPointerScroll(PointerScrollEvent e) {
    setState(() {
      selectedIndex = (selectedIndex + 1) % player.backpack.itemCount;
    });
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
    final backpack = player.backpack;
    if (backpack.isEmpty) {
      return buildEmptyBackpack();
    }
    return [
      Scaffold(
        appBar: AppBar(
          title: _I.massLoad(player.backpack.mass, player.maxMassLoad).text(),
          centerTitle: true,
          automaticallyImplyLeading: false,
          toolbarHeight: 40,
          backgroundColor: Colors.transparent,
        ),
        body: buildLandscapeBody().safeArea().padAll(5),
      ).expanded(),
      buildItems(player.backpack).expanded(),
    ].row();
  }

  Widget buildPortraitBody() {
    final backpack = player.backpack;
    if (backpack.isEmpty) {
      return buildEmptyBackpack();
    } else {
      return [
        ItemDetails(stack: selected).flexible(flex: 2),
        buildItems(player.backpack).flexible(flex: 5),
        buildButtonArea(selected).flexible(flex: 1),
      ].column(maa: MainAxisAlignment.spaceBetween);
    }
  }

  Widget buildLandscapeBody() {
    return [
      ItemDetails(stack: selected).flexible(flex: 4),
      buildButtonArea(selected).flexible(flex: 2),
    ].column(maa: MainAxisAlignment.spaceBetween);
  }

  Widget buildItems(Backpack backpack) {
    return GridView.builder(
      itemCount: backpack.itemCount,
      physics: const RangeMaintainingScrollPhysics(),
      gridDelegate: itemCellGridDelegatePortrait,
      itemBuilder: (ctx, i) {
        return buildItem(backpack[i]);
      },
    );
  }

  Future<void> removeItem(ItemStack item) async {
    await runWithTrackCurrentSelected(item, () async {
      player.backpack.removeStackInBackpack(item);
    });
  }

  Future<void> runWithTrackCurrentSelected(ItemStack item, Future Function() between) async {
    if (item == selected) {
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
        selected = player.backpack[index];
      } else {
        selected = ItemStack.empty;
      }
    } else {
      await between();
    }
  }

  Widget buildButtonArea(ItemStack item) {
    Widget btn(String text, {VoidCallback? onTap, Color? color}) {
      final canAct = player.canPlayerAct() && onTap != null;
      return CardButton(
        onTap: !canAct ? null : onTap,
        elevation: canAct ? 5 : 0,
        child: text
            .autoSizeText(
              maxLines: 1,
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

  Future<void> onDiscard(ItemStack stack) async {
    assert(stack.isNotEmpty, "$stack is empty");
    if (stack.meta.mergeable) {
      $selectedMass.value = stack.stackMass;
      final confirmed = await context.showAnyRequest(
        title: _I.discardRequest,
        make: (_) => ItemStackMassSelector(
          template: stack,
          $selectedMass: $selectedMass,
        ),
        yes: I.discard,
        no: I.cancel,
        highlight: true,
      );
      if (confirmed == true) {
        final selectedMassOrPart = $selectedMass.value;
        if (selectedMassOrPart > 0) {
          await runWithTrackCurrentSelected(stack, () async {
            // discard the part.
            final _ = player.backpack.splitItemInBackpack(stack, selectedMassOrPart);
          });
        }
      }
    } else {
      final confirmed = await context.showRequest(
        title: _I.discardRequest,
        desc: _I.discardConfirm(stack.displayName()),
        yes: I.discard,
        no: I.cancel,
        highlight: true,
      );
      if (confirmed == true) {
        await removeItem(stack);
      }
    }
  }

  final $isShowAttrPreview = ValueNotifier(true);

  Widget buildShowAttrPreviewToggle() {
    return $isShowAttrPreview >>
        (_, b) => Switch(
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
          await runWithTrackCurrentSelected(item, () async {
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
        await removeItem(item);
      }
    }
  }

  Widget buildItem(ItemStack item) {
    final isSelected = selected == item;
    return AnimatedSlide(
      offset: isSelected ? const Offset(0.015, -0.04) : Offset.zero,
      curve: Curves.easeInOutCubic,
      duration: const Duration(milliseconds: 300),
      child: CardButton(
        elevation: isSelected ? 20 : 0.8,
        onTap: () {
          if (selected != item) {
            setState(() {
              selected = item;
            });
          }
        },
        child: ItemStackCell(item),
      ),
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

class ItemDetails extends StatefulWidget {
  final ItemStack stack;

  const ItemDetails({
    super.key,
    required this.stack,
  });

  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  ItemStack get stack => widget.stack;

  @override
  Widget build(BuildContext context) {
    return [
      buildTop(context),
      buildBottom(context),
    ].column().inCard(elevation: 4);
  }

  Widget buildTop(BuildContext ctx) {
    return Container(
      color: Color.lerp(
        ctx.theme.cardColor,
        ctx.colorScheme.secondary,
        ctx.isLightMode ? 0.2 : 0.15,
      ),
      child: ListTile(
        title: stack.displayName().text(style: ctx.textTheme.titleLarge),
        subtitle: stack.meta.l10nDescription().text(),
      ),
    ).clipRRect(borderRadius: ctx.cardBorderRadiusTop);
  }

  Widget buildBottom(BuildContext ctx) {
    return ListTile(
      title: buildStatus(ctx),
      //subtitle: "AAA".text(),
      //isThreeLine: true,
    );
  }

  Widget buildStatus(BuildContext ctx) {
    final builder = ItemStackStatusBuilder(darkMode: ctx.isDarkMode);
    stack.buildStatus(builder);
    final entries = <Widget>[];
    for (final toolComp in stack.meta.getCompsOf<ToolComp>()) {
      final isToolPref = player.isToolPrefOrDefault(stack, toolComp.toolType);
      entries.add(ChoiceChip(
        selected: isToolPref,
        elevation: 2,
        tooltip: isToolPref ? "Is default" : "Set to default",
        selectedColor: context.fixColorBrightness(context.colorScheme.primary),
        onSelected: (newIsPref) {
          if (newIsPref == isToolPref) return;
          if (newIsPref) {
            player.setToolPref(toolComp.toolType, stack);
          } else {
            player.clearToolPref(toolComp.toolType);
          }
          setState(() {});
        },
        label: toolComp.toolType.l10nName().text(),
      ));
    }
    for (final status in builder.build()) {
      var color = status.color;
      color ??= ctx.colorScheme.primary;
      entries.add(Chip(
        elevation: 2,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        label: status.name.text(),
        backgroundColor: Color.lerp(color, ctx.colorScheme.primary, 0.2),
      ));
    }
    return Wrap(
      spacing: 5.w,
      children: entries,
    );
  }
}
