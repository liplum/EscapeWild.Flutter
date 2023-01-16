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
      MixCraftRecipe(
        "straw-rope",
        CraftRecipeCat.refine,
        tags: [200.g("straw")],
        output: () => Stuff.strawRope,
        outputMass: 100,
      ),
      MixCraftRecipe(
        "stone-axe",
        CraftRecipeCat.tool,
        tags: [
          1000.g("stone"),
          500.g("log"),
          50.g("rope"),
        ],
        output: () => Tools.stoneAxe,
      ),
/*      MixCraftRecipe("water-filter", CraftRecipeCat.survival,
          names: [20.g("plastic-bottle")],
          tags: [
            300.g("sand"),
            200.g("straw"),
          ],
          output: () => Tools.waterFilter)*/
    ]);
  }
}

extension _DSL on int {
  StringMassEntry g(String tag) {
    return StringMassEntry(tag, this);
  }
}
