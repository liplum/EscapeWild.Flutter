import 'package:escape_wild/core/index.dart';
import 'package:escape_wild/foundation.dart';

class CraftRecipes {
  CraftRecipes._();

  static void registerAll() {
    Contents.craftRecipes.addAll([
      TagCraftRecipe(
        name: "tinder",
        cat: CraftRecipeCat.fire,
        ingredients: [50.tag("flammable-floc")],
        output: () => Stuff.tinder,
        outputMass: 30,
      ),
      TagCraftRecipe(
        name: "hand-drill-kit",
        cat: CraftRecipeCat.fire,
        ingredients: [50.tag("tinder"), 50.tag("sticks"), 200.tag("log")],
        output: () => Tools.handDrillKit,
      ),
      TagCraftRecipe(
        name: "straw-rope",
        cat: CraftRecipeCat.refine,
        ingredients: [200.tag("straw")],
        output: () => Stuff.strawRope,
      ),
      TagCraftRecipe(
        name: "stone-axe",
        cat: CraftRecipeCat.tool,
        ingredients: [1000.tag("stone"), 500.tag("log"), 50.tag("rope")],
        output: () => Tools.stoneAxe,
      ),
      TagCraftRecipe(
        name: "torch",
        cat: CraftRecipeCat.fire,
        ingredients: [1000.tag("log"), 500.tag("torch-head")],
        output: () => Tools.unlitTorch,
      ),
      // TagCraftRecipe(
      //  name: "water-filter",
      //  cat:  CraftRecipeCat.survival,
      //   tags: [20.g("plastic-bottle"), 300.g("sand"), 200.g("straw")],
      //   output: () => Tools.waterFilter,
      // ),
    ]);
  }
}
