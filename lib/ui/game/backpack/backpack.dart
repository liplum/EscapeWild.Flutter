import 'package:escape_wild/core/index.dart';
import 'package:escape_wild/design/empty.dart';
import 'package:escape_wild/design/theme.dart';
import 'package:escape_wild/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:noitcelloc/noitcelloc.dart';
import 'package:rettulf/rettulf.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tabler_icons/tabler_icons.dart';

import '../shared.dart';

part 'backpack.i18n.dart';

String get backpackTitle => _I.title;

class GameBackpackPage extends StatefulWidget {
  const GameBackpackPage({super.key});

  @override
  State<GameBackpackPage> createState() => _GameBackpackPageState();
}

Widget buildEmptyBackpack() {
  return Empty(icon: Icon(TablerIcons.backpack_off), title: _I.emptyTip);
}

class _GameBackpackPageState extends State<GameBackpackPage> {
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
    player.addListener(refresh);
    if (lastSelectedIndex >= 0) {
      selected = player.backpack[lastSelectedIndex];
    }
    updateDefaultSelection();
  }

  @override
  void dispose() {
    player.removeListener(refresh);
    super.dispose();
  }

  void refresh() {
    updateDefaultSelection();
    setState(() {});
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
      child: buildBody(),
    );
  }

  void onPointerScroll(PointerScrollEvent e) {
    setState(() {
      selectedIndex = (selectedIndex + 1) % player.backpack.itemCount;
    });
  }

  Widget buildBody() {
    return Scaffold(
      appBar: AppBar(
        title: _I.massLoad(player.backpack.totalMass(), player.maxMassLoad).text(),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body:
          (player.backpack.isEmpty
                  ? buildEmptyBackpack()
                  : [
                      ItemDetails(stack: selected),
                      buildItems(player.backpack).expanded(),
                      buildButtonArea(selected),
                    ].column(maa: .spaceBetween, spacing: 8))
              .safeArea()
              .padAll(5),
    );
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
        selected = .empty;
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
              style: context.textTheme.headlineSmall?.copyWith(color: color),
              textAlign: .center,
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
      buttons.add(
        btn(
          useType.l10nName(),
          onTap: () async {
            await onUse(item, useType, usableComps);
          },
        ),
      );
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
        builder: (_) => ItemStackMassSelector(template: stack, $selectedMass: $selectedMass),
        primary: I.discard,
        secondary: I.cancel,
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
      final confirmed = await context.showDialogRequest(
        title: _I.discardRequest,
        desc: _I.discardConfirm(stack.displayName()),
        primary: I.discard,
        secondary: I.cancel,
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
          },
        );
  }

  Future<void> onUse(ItemStack item, UseType useType, List<UsableComp> usableComps) async {
    final modifiers = usableComps.ofType<ModifyAttrComp>().toList(growable: false);
    if (item.meta.mergeable) {
      $selectedMass.value = item.stackMass;
      final confirmed = await context.showAnyRequest(
        title: item.displayName(),
        builder: (_) => MergeableItemStackUsePreview(
          template: item,
          useType: useType,
          $selectedMass: $selectedMass,
          comps: modifiers,
        ),
        primary: useType.l10nName(),
        secondary: I.cancel,
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
        // TODO: preview toggle
        // titleTrailing: buildShowAttrPreviewToggle(),
        builder: (_) =>
            UnmergeableItemStackUsePreview(item: item, comps: modifiers, $isShowAttrPreview: $isShowAttrPreview),
        primary: useType.l10nName(),
        secondary: I.cancel,
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
      offset: isSelected ? const .new(0.015, -0.04) : .zero,
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
    } else if (type == .use) {
      type = comp.useType;
      break;
    }
  }
  return type ?? .use;
}

class ItemDetails extends StatefulWidget {
  final ItemStack stack;

  const ItemDetails({super.key, required this.stack});

  @override
  State<ItemDetails> createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  ItemStack get stack => widget.stack;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      color: context.colorScheme.surfaceContainer,
      clipBehavior: .hardEdge,
      child: [buildTop(context), buildBottom(context).padSymmetric(h: 8, v: 4)].column(caa: .start),
    );
  }

  Widget buildTop(BuildContext ctx) {
    return Container(
      color: context.colorScheme.surfaceContainerHighest,
      child: ListTile(
        title: stack.displayName().text(style: ctx.textTheme.titleLarge),
        subtitle: stack.meta.l10nDescription().text(),
      ),
    );
  }

  Widget buildBottom(BuildContext ctx) {
    return buildStatus(ctx);
  }

  Widget buildStatus(BuildContext ctx) {
    final builder = ItemStackStatusBuilder(darkMode: ctx.isDarkMode);
    stack.buildStatus(builder);
    final entries = <Widget>[];
    for (final toolComp in stack.meta.getCompsOf<ToolComp>()) {
      final isToolPref = player.isToolPrefOrDefault(stack, toolComp.toolType);
      entries.add(
        ChoiceChip(
          selected: isToolPref,
          tooltip: isToolPref ? "Unset default" : "Set default",
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
        ),
      );
    }
    for (final status in builder.build()) {
      var color = status.color;
      color ??= ctx.colorScheme.primary;
      entries.add(
        Chip(
          elevation: 2,
          shape: const RoundedRectangleBorder(borderRadius: .all(.circular(8))),
          label: status.name.text(),
          backgroundColor: .lerp(color, ctx.colorScheme.primary, 0.2),
        ),
      );
    }
    return Wrap(spacing: 4, children: entries);
  }
}
