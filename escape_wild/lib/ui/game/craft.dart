import 'package:escape_wild/core.dart';
import 'package:escape_wild/foundation.dart';
import 'package:escape_wild/r.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rettulf/rettulf.dart';

import 'backpack.dart';
import 'shared.dart';

class CraftPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  CraftPage({super.key});

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
      appBar: !isPortrait
          ? null
          : AppBar(
              title: "Craft".text(),
              automaticallyImplyLeading: false,
              centerTitle: true,
            ),
      body: [
        buildCatView(context).flexible(flex: isPortrait ? 4 : 3),
        const VerticalDivider(thickness: 1),
        buildRecipes(cat2Recipes[selectedCatIndex].value).flexible(flex: isPortrait ? 10 : 12),
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
        return CardButton(
          elevation: isSelected ? 10 : 0,
          child: ListTile(
            title: cat.l10nName().autoSizeText(maxLines: 1, style: style, textAlign: TextAlign.center),
            selected: isSelected,
            dense: true,
          ),
          onTap: () {
            if (selectedCatIndex != i) {
              setState(() {
                selectedCatIndex = i;
              });
            }
          },
        );
      },
    );
  }

  Widget buildRecipes(List<CraftRecipeProtocol> recipes) {
    return MasonryGridView.extent(
      maxCrossAxisExtent: 280,
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
      buildOutputItemBtn(),
      buildInputGrid(),
    ].column().inCard();
  }

  Widget buildOutputItemBtn() {
    final canAct = player.canPlayerAct();
    final output = recipe.outputItem;
    return CardButton(
      elevation: canAct ? 12 : 0,
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
      child: ItemCell(output).aspectRatio(aspectRatio: 5),
    );
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
          onNotInBackpack: (item) => ItemCell(item).inCard(
            key: const ValueKey("not in backpack"),
            elevation: 0.6,
          ),
          onInBackpack: (item) => ItemCell(item.meta).inCard(
            key: const ValueKey("in backpack"),
            elevation: 5,
          ),
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
  final List<ItemStackSlot> itemStackReqSlots = [];
  List<ItemStack> accepted = const [];
  List<ItemStack> unaccepted = const [];

  @override
  void initState() {
    super.initState();
    for (final input in recipe.inputSlots) {
      itemStackReqSlots.add(ItemStackSlot(input));
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.navigator.pop();
          },
        ),
        title: recipe.outputItem.l10nName().text(style: context.textTheme.titleLarge),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: !isSatisfyAllConditions ? null : onCraft,
            child: recipe.craftType.l10nName().text(
                  style: TextStyle(fontSize: context.textTheme.titleMedium?.fontSize),
                ),
          )
        ],
        backgroundColor: Colors.transparent,
      ),
      body: context.isPortrait ? buildPortrait() : buildLandscape(),
    );
  }

  Widget buildPortrait() {
    return [
      buildTableView().flexible(flex: 3),
      const Divider(thickness: 2, height: 1),
      buildBackpackView().flexible(flex: 6),
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
    // if player doesn't have all items required, just pop.
    var matchedAll = true;
    for (final slot in itemStackReqSlots) {
      slot.updateMatching();
      matchedAll &= player.backpack.matchedAny(slot.matcher.exact.bool);
    }
    if (!matchedAll) {
      context.navigator.pop();
    }
  }

  Widget buildTableView() {
    return [
      GridView.builder(
        itemCount: itemStackReqSlots.length,
        physics: const RangeMaintainingScrollPhysics(),
        gridDelegate: itemCellGridDelegatePortrait,
        itemBuilder: (ctx, i) {
          return buildInputSlot(itemStackReqSlots[i]);
        },
      ).expanded(),
    ].column();
  }

  Widget buildInputSlot(ItemStackSlot slot) {
    return ItemStackReqAutoMatchCell(
      slot: slot,
      onTapSatisfied: () {
        goBackToAccepted(slot);
      },
    );
  }

  void goBackToAccepted(ItemStackSlot slot) {
    if (slot.isNotEmpty) {
      accepted.add(slot.stack);
      slot.reset();
      setState(() {});
    }
  }

  Widget buildBackpackView() {
    if (player.backpack.isEmpty) {
      return buildEmptyBackpack();
    }
    return GridView.builder(
      itemCount: accepted.length + unaccepted.length,
      physics: const RangeMaintainingScrollPhysics(),
      gridDelegate: itemCellGridDelegatePortrait,
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
      child: ItemStackCell(
        item,
        theme: ItemStackCellTheme(opacity: accepted ? 1.0 : R.disabledAlpha),
      ),
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

  @override
  void dispose() {
    for (final slot in itemStackReqSlots) {
      slot.dispose();
    }
    super.dispose();
  }
}
