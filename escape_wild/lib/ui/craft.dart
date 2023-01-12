import 'package:escape_wild/core.dart';
import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';

import 'shared.dart';

class CraftPage extends StatefulWidget {
  const CraftPage({super.key});

  @override
  State<CraftPage> createState() => _CraftPageState();
}

class _CraftPageState extends State<CraftPage> {
  int selectedCat = 0;
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
        buildRecipes(cat2Recipes[selectedCat].value).flexible(flex: isPortrait ? 10 : 12),
      ].row(),
    );
  }

  // (=｀ω´=)
  Widget buildCatView(BuildContext ctx) {
    return ListView.builder(
      physics: const RangeMaintainingScrollPhysics(),
      itemCount: cat2Recipes.length,
      itemBuilder: (ctx, i) {
        final cat = cat2Recipes[i].key;
        return ListTile(
          title: cat.name.text(),
          selected: i == selectedCat,
        ).inCard().onTap(() {
          setState(() {
            selectedCat = i;
          });
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
      buildInputGrid().expanded(),
    ].row().inCard();
  }

  Widget buildInputGrid() {
    final inputSlots = recipe.inputSlots;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: inputSlots.length,
      gridDelegate: itemCellGridDelegate,
      shrinkWrap: true,
      itemBuilder: (ctx, i) {
        return DynamicMatchingCell(matcher: inputSlots[i]);
      },
    );
  }
}

class DynamicMatchingCell extends StatefulWidget {
  final ItemMatcher matcher;

  const DynamicMatchingCell({
    super.key,
    required this.matcher,
  });

  @override
  State<DynamicMatchingCell> createState() => _DynamicMatchingCellState();
}

class _DynamicMatchingCellState extends State<DynamicMatchingCell> {
  var curIndex = 0;
  @override
  void initState() {
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
