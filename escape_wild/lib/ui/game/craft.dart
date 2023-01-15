import 'package:auto_size_text/auto_size_text.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/theme.dart';
import 'package:escape_wild/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rettulf/rettulf.dart';

import 'backpack.dart';
import 'shared.dart';

class CraftPage extends StatefulWidget {
  const CraftPage({super.key});

  @override
  State<CraftPage> createState() => _CraftPageState();
}

class _CraftPageState extends State<CraftPage> {
  int _selectedCatIndex = 0;

  int get selectedCatIndex => _selectedCatIndex;

  set selectedCatIndex(int v) {
    _selectedCatIndex = v;
    lastSelectedIndex = v;
  }

  static int lastSelectedIndex = 0;
  late List<MapEntry<CraftRecipeCat, List<CraftRecipeProtocol>>> cat2Recipes;

  @override
  void initState() {
    super.initState();
    cat2Recipes = Contents.craftRecipes.cat2Recipes.entries.toList();
    selectedCatIndex = lastSelectedIndex.clamp(0, cat2Recipes.length - 1);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = context.isPortrait;
    return Scaffold(
      body: [
        buildCatView(context).flexible(flex: isPortrait ? 3 : 3),
        const VerticalDivider(thickness: 1),
        if (isPortrait)
          buildRecipesPortrait(cat2Recipes[selectedCatIndex].value).flexible(flex: 10)
        else
          buildRecipesLandscape(cat2Recipes[selectedCatIndex].value).flexible(flex: 12),
      ].row().padAll(5),
    );
  }

  // (=｀ω´=)
  Widget buildCatView(BuildContext ctx) {
    return ListView.builder(
      physics: const RangeMaintainingScrollPhysics(),
      itemCount: cat2Recipes.length,
      itemBuilder: (ctx, i) {
        final isSelected = selectedCatIndex == i;
        final cat = cat2Recipes[i].key;
        final style = ctx.isPortrait ? ctx.textTheme.titleMedium : ctx.textTheme.titleLarge;
        return ListTile(
          title: AutoSizeText(cat.l10nName(), maxLines: 1, style: style, textAlign: TextAlign.center),
          selected: isSelected,
        ).inCard(elevation: isSelected ? 10 : 0).onTap(() {
          if (selectedCatIndex != i) {
            setState(() {
              selectedCatIndex = i;
            });
          }
        });
      },
    );
  }

  Widget buildRecipesPortrait(List<CraftRecipeProtocol> recipes) {
    return ListView.builder(
      physics: const RangeMaintainingScrollPhysics(),
      itemCount: recipes.length,
      itemBuilder: (ctx, i) {
        final recipe = recipes[i];
        return CraftRecipeEntry(recipe);
      },
    );
  }

  Widget buildRecipesLandscape(List<CraftRecipeProtocol> recipes) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 350,
        childAspectRatio: 1.5,
      ),
      physics: const RangeMaintainingScrollPhysics(),
      itemCount: recipes.length,
      itemBuilder: (ctx, i) {
        final recipe = recipes[i];
        return CraftRecipeEntry(recipe);
      },
    );
  }
}

class CraftRecipeEntry extends StatefulWidget {
  final CraftRecipeProtocol recipe;

  const CraftRecipeEntry(
    this.recipe, {
    super.key,
  });

  @override
  State<CraftRecipeEntry> createState() => _CraftRecipeEntryState();
}

class _CraftRecipeEntryState extends State<CraftRecipeEntry> {
  CraftRecipeProtocol get recipe => widget.recipe;

  @override
  Widget build(BuildContext context) {
    return [
      buildOutputItem(),
      buildInputGrid(),
    ].column().inCard();
  }

  Widget buildOutputItem() {
    final canAct = player.canPlayerAct();
    final output = recipe.outputItem;
    return ItemCell(output)
        .inkWell(
          borderRadius: context.cardBorderRadius,
          onTap: !canAct
              ? null
              : () async {
                  await showCupertinoModalBottomSheet(
                    context: context,
                    enableDrag: false,
                    builder: (_) => CraftingSheet(
                      recipe: recipe,
                    ),
                  );
                },
        )
        .inCard(elevation: canAct ? 12 : 0);
  }

  Widget buildInputGrid() {
    final inputSlots = recipe.inputSlots;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: inputSlots.length,
      gridDelegate: itemCellSmallGridDelegate,
      shrinkWrap: true,
      itemBuilder: (ctx, i) {
        return DynamicMatchingCell(
          matcher: inputSlots[i],
          onNotInBackpack: (item) => ItemCell(item).inCard(elevation: 0),
          onInBackpack: (item) => ItemStackCell(
            item,
            pad: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          ).inCard(elevation: 5),
        );
      },
    );
  }
}

class CraftingSheet extends StatefulWidget {
  final CraftRecipeProtocol recipe;

  const CraftingSheet({
    super.key,
    required this.recipe,
  });

  @override
  State<CraftingSheet> createState() => _CraftingSheetState();
}

class _CraftingSheetState extends State<CraftingSheet> {
  CraftRecipeProtocol get recipe => widget.recipe;
  final List<ItemStackReqSlot> itemStackReqSlots = [];
  List<ItemStack> accepted = const [];
  List<ItemStack> unaccepted = const [];

  @override
  void initState() {
    super.initState();
    for (final input in recipe.inputSlots) {
      itemStackReqSlots.add(ItemStackReqSlot(input));
    }
    updateBackpackFilter();
  }

  void updateBackpackFilter() {
    final p = player.backpack.separateMatchedFromUnmatched((stack) {
      for (final slot in itemStackReqSlots) {
        if (slot.matcher.typeOnly(stack.meta)) {
          return true;
        }
      }
      return false;
    });
    accepted = p.key;
    unaccepted = p.value;
    setState(() {});
  }

  bool get isSatisfyAllConditions {
    return !itemStackReqSlots.any((slot) => slot.isEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            context.navigator.pop();
          },
          child: I.cancel.text(),
        ),
        middle: recipe.outputItem.l10nName().text(style: context.textTheme.titleLarge),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: !isSatisfyAllConditions
              ? null
              : () {
                  onCraft();
                },
          child: recipe.craftType.l10nName().text(),
        ),
        backgroundColor: Colors.transparent,
      ),
      child: context.isPortrait ? buildPortrait() : buildLandscape(),
    );
  }

  Widget buildPortrait() {
    return [
      buildTableView().expanded(),
      const Divider(thickness: 2, indent: 10, endIndent: 10, height: 1),
      buildBackpackView().expanded(),
    ].column().padAll(5);
  }

  Widget buildLandscape() {
    return [
      buildTableView().expanded(),
      const VerticalDivider(thickness: 2),
      buildBackpackView().expanded(),
    ].row().padAll(5);
  }

  void onCraft() {
    final material = itemStackReqSlots.map((slot) => slot.stack).toList(growable: false);
    final result = recipe.onCraft(material);
    if (result.isNotEmpty) {
      recipe.onConsume(material, player.backpack.consumeItemInBackpack);
      player.backpack.addItemOrMerge(result);
    }
    context.navigator.pop();
  }

  Widget buildTableView() {
    return [
      GridView.builder(
        itemCount: itemStackReqSlots.length,
        physics: const RangeMaintainingScrollPhysics(),
        gridDelegate: itemCellGridDelegate,
        itemBuilder: (ctx, i) {
          return buildInputSlot(itemStackReqSlots[i]);
        },
      ).expanded(),
    ].column();
  }

  Widget buildInputSlot(ItemStackReqSlot slot) {
    return ItemStackReqCell(
      slot: slot,
      onTapSatisfied: () {
        goBackToAccepted(slot);
      },
    );
  }

  void goBackToAccepted(ItemStackReqSlot slot) {
    if (slot.isNotEmpty) {
      accepted.add(slot.stack);
      slot.reset();
      setState(() {});
    }
  }

  Widget buildBackpackView() {
    if (player.backpack.isEmpty) {
      return buildEmptyBackpack().padV(30);
    }
    return GridView.builder(
      itemCount: accepted.length + unaccepted.length,
      physics: const RangeMaintainingScrollPhysics(),
      gridDelegate: itemCellGridDelegate,
      itemBuilder: (ctx, i) {
        if (i < accepted.length) {
          return buildItem(accepted[i], accepted: true);
        } else {
          return buildItem(unaccepted[i - accepted.length], accepted: false);
        }
      },
    );
  }

  Widget buildItem(ItemStack item, {required bool accepted}) {
    return CardButton(
      elevation: accepted ? 4 : 0,
      onTap: !accepted
          ? null
          : () {
              gotoFirstMatchedSlot(item);
            },
      child: ItemStackCell(item),
    );
  }

  void gotoFirstMatchedSlot(ItemStack item) {
    for (final slot in itemStackReqSlots) {
      if (slot.matcher.exact(item).isMatched) {
        slot.stack = item;
        accepted.remove(item);
        setState(() {});
        break;
      }
    }
  }
}
