import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:escape_wild/core.dart';
import 'package:escape_wild/design/theme.dart';
import 'package:escape_wild/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rettulf/rettulf.dart';

import 'shared.dart';

class CraftPage extends StatefulWidget {
  const CraftPage({super.key});

  @override
  State<CraftPage> createState() => _CraftPageState();
}

class _CraftPageState extends State<CraftPage> {
  int selectedCatIndex = 0;
  late List<MapEntry<CraftRecipeCat, List<CraftRecipeProtocol>>> cat2Recipes;

  @override
  void initState() {
    super.initState();
    cat2Recipes = Contents.craftRecipes.cat2Recipes.entries.toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = context.isPortrait;
    return Scaffold(
      body: [
        buildCatView(context).flexible(flex: isPortrait ? 3 : 3),
        const VerticalDivider(
          thickness: 1,
        ),
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

  Widget buildRecipes(List<CraftRecipeProtocol> recipes) {
    return ListView.builder(
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
    final output = recipe.outputItem;
    return ItemCell(output)
        .inkWell(
          borderRadius: context.cardBorderRadius,
          onTap: () async {
            await showCupertinoModalBottomSheet(
              context: context,
              enableDrag: false,
              builder: (_) => CraftingSheet(
                recipe: recipe,
              ),
            );
          },
        )
        .inCard(elevation: 12);
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
          onInBackpack: (item) => ItemEntryCell(
            item,
            pad: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          ).inCard(elevation: 5),
        );
      },
    );
  }
}

class DynamicMatchingCell extends StatefulWidget {
  final ItemMatcher matcher;
  final Widget Function(Item item) onNotInBackpack;
  final Widget Function(ItemEntry item) onInBackpack;

  const DynamicMatchingCell({
    super.key,
    required this.matcher,
    required this.onNotInBackpack,
    required this.onInBackpack,
  });

  @override
  State<DynamicMatchingCell> createState() => _DynamicMatchingCellState();
}

class _DynamicMatchingCellState extends State<DynamicMatchingCell> {
  ItemMatcher get matcher => widget.matcher;
  var curIndex = 0;
  List<dynamic> allMatched = const [];
  var active = false;
  late Timer marqueeTimer;

  @override
  void initState() {
    super.initState();
    updateAllMatched();
    marqueeTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (allMatched.isNotEmpty) {
        setState(() {
          curIndex = (curIndex + 1) % allMatched.length;
        });
      }
    });
  }

  void updateAllMatched() {
    allMatched = player.backpack.matchExactItems(matcher);
    if (allMatched.isNotEmpty) {
      curIndex = curIndex % allMatched.length;
      active = true;
    } else {
      // player don't have any of it, try to browser all items.
      allMatched = Contents.getMatchedItems(matcher);
      assert(allMatched.isNotEmpty, "ItemMatcher should match at least one among all items.");
      if (allMatched.isNotEmpty) {
        curIndex = curIndex % allMatched.length;
      }
      active = false;
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant DynamicMatchingCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget != widget) {
      updateAllMatched();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (allMatched.isNotEmpty) {
      final cur = allMatched[curIndex];
      if (cur is Item) {
        return widget.onNotInBackpack(cur);
      } else if (cur is ItemEntry) {
        return widget.onInBackpack(cur);
      } else {
        assert(false, "${cur.runtimeType} is neither $Item nor $ItemEntry.");
        return const NullItemCell();
      }
    } else {
      assert(false, "No item matched.");
      return const NullItemCell();
    }
  }

  @override
  void dispose() {
    super.dispose();
    marqueeTimer.cancel();
  }
}

class CraftSlot {
  ItemEntry item = ItemEntry.empty;

  void reset() => item = ItemEntry.empty;

  bool get isEmpty => item == ItemEntry.empty;

  bool get isNotEmpty => !isEmpty;
  final ItemMatcher matcher;

  CraftSlot(this.matcher);
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
  final List<CraftSlot> craftSlots = [];
  List<ItemEntry> accepted = [];
  List<ItemEntry> unaccepted = [];

  @override
  void initState() {
    super.initState();
    for (final input in recipe.inputSlots) {
      craftSlots.add(CraftSlot(input));
    }
    updateBackpackFilter();
  }

  void updateBackpackFilter() {
    accepted.clear();
    unaccepted.clear();
    for (final item in player.backpack.items) {
      var isAccepted = false;
      for (final slot in craftSlots) {
        if (slot.matcher.typeOnly(item.meta)) {
          accepted.add(item);
          isAccepted = true;
          break;
        }
      }
      if (!isAccepted) {
        unaccepted.add(item);
      }
    }
    setState(() {});
  }

  bool get isSatisfyAllConditions {
    return !craftSlots.any((slot) => slot.isEmpty);
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
        middle: recipe.outputItem.localizedName().text(style: context.textTheme.titleLarge),
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
      child: [
        buildTableView().expanded(),
        const Divider(thickness: 2, indent: 10, endIndent: 10),
        buildBackpackView().expanded(),
      ].column().padAll(5),
    );
  }

  void onCraft() {
    final material = craftSlots.map((slot) => slot.item).toList(growable: false);
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
        itemCount: craftSlots.length,
        physics: const RangeMaintainingScrollPhysics(),
        gridDelegate: itemCellGridDelegate,
        itemBuilder: (ctx, i) {
          return buildInputSlot(craftSlots[i]);
        },
      ).expanded(),
    ].column();
  }

  Widget buildInputSlot(CraftSlot slot) {
    ShapeBorder? shape;
    final satisfyCondition = slot.isNotEmpty;
    if (!satisfyCondition) {
      shape = RoundedRectangleBorder(
        side: BorderSide(
          color: context.theme.colorScheme.outline,
        ),
        borderRadius: context.cardBorderRadius ?? BorderRadius.zero,
      );
    }
    return CardButton(
      elevation: satisfyCondition ? 4 : 0,
      onTap: !satisfyCondition
          ? null
          : () {
              goBackToAccepted(slot);
            },
      shape: shape,
      child: satisfyCondition
          ? ItemEntryCell(slot.item)
          : DynamicMatchingCell(
              matcher: slot.matcher,
              onNotInBackpack: (item) => ItemCell(item),
              onInBackpack: (item) => ItemEntryCell(item, showMass: false),
            ),
    );
  }

  void goBackToAccepted(CraftSlot slot) {
    if (slot.isNotEmpty) {
      accepted.add(slot.item);
      slot.reset();
      setState(() {});
    }
  }

  Widget buildBackpackView() {
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

  Widget buildItem(ItemEntry item, {required bool accepted}) {
    return CardButton(
      elevation: accepted ? 4 : 0,
      onTap: !accepted
          ? null
          : () {
              gotoFirstMatchedSlot(item);
            },
      child: ItemEntryCell(item),
    );
  }

  void gotoFirstMatchedSlot(ItemEntry item) {
    for (final slot in craftSlots) {
      if (slot.matcher.exact(item)) {
        slot.item = item;
        accepted.remove(item);
        setState(() {});
        break;
      }
    }
  }
}
