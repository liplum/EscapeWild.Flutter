import 'package:escape_wild/core.dart';
import 'package:escape_wild/foundation.dart';

class CraftRecipes {
  CraftRecipes._();

  static void registerAll() {
    Contents.craftRecipes.addAll([
      MergeWetCraftRecipe(
        "tinder",
        CraftRecipeCat.fire,
        inputTags: [50.g("flammable-floc")],
        outputMass: 30,
        output: () => Stuff.tinder,
      ),
      MergeWetCraftRecipe(
        "hand-drill-kit",
        CraftRecipeCat.fire,
        inputTags: [
          50.g("tinder"),
          50.g("sticks"),
          200.g("log"),
        ],
        output: () => Tools.handDrillKit,
      ),
      TaggedCraftRecipe(
        "straw-rope",
        CraftRecipeCat.refine,
        tags: [200.g("straw")],
        output: () => Stuff.strawRope,
        outputMass: 100,
      ),
      TaggedCraftRecipe(
        "stone-axe",
        CraftRecipeCat.tool,
        tags: [
          1000.g("stone"),
          500.g("log"),
          50.g("rope"),
        ],
        output: () => Tools.stoneAxe,
      ),
    ]);
  }
}

extension _DSL on int {
  TagMassEntry g(String tag) {
    return TagMassEntry(tag, this);
  }
}
