import 'package:escape_wild/core.dart';
import 'package:escape_wild/foundation.dart';

class CraftRecipes {
  CraftRecipes._();

  static void registerAll() {
    Contents.craftRecipes.addAll([
      _TinderRecipe(
        inputTags: [
          50.g("flammable-floc"),
        ],
        outputMass: 30,
      ),
      /*TaggedCraftRecipe(
        "hand-drill-kit",
        CraftRecipeCat.fire,
        tags: [
          "tinder" ^ 50,
          "sticks" ^ 50,
          "log" ^ 200,
        ],
        output: () => Tools.handDrillKit,
      ),*/
    ]);
  }
}

class _TinderRecipe extends CraftRecipeProtocol {
  final List<TagMassEntry> inputTags;
  final int outputMass;

  @override
  List<ItemMatcher> inputSlots = [];

  @override
  List<ItemMatcher> toolSlots = [];

  _TinderRecipe({
    required this.inputTags,
    required this.outputMass,
  }) : super("tinder", CraftRecipeCat.fire) {
    for (final input in inputTags) {
      inputSlots.add(ItemMatcher(
        typeOnly: (item) => item.hasTag(input.tag),
        exact: (item) => item.meta.hasTag(input.tag) && item.actualMass >= outputMass,
      ));
    }
  }

  @override
  Item get outputItem => Stuff.tinder;

  ItemEntry onCraft(List<ItemEntry> inputs) {
    var sumMass = 0;
    var sumWet = 0.0;
    for (final tag in inputTags) {
      final input = inputs.findFirstByTag(tag.tag);
      assert(input != null, "$tag not found in $inputs");
      if (input == null) return ItemEntry.empty;
      final inputMass = input.actualMass;
      sumMass += inputMass;
      sumWet += WetComp.tryGetWet(input) * inputMass;
    }
    final res = Stuff.tinder.create(mass: outputMass);
    WetComp.trySetWet(res, sumWet / sumMass);
    return res;
  }
}

extension _DSL on int {
  TagMassEntry g(String tag) {
    return TagMassEntry(tag, this);
  }
}
