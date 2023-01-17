import 'package:escape_wild/core.dart';
import 'package:escape_wild/core/recipe.dart';
import 'package:escape_wild/foundation.dart';

class FoodRecipes {
  FoodRecipes._();

  static void registerAll() {
    Contents.cookRecipes.addAll([
      FoodRecipe(
        "raw-fish-to-cooked",
        ingredients: [
          150.tag(["fish", "raw"]),
        ],
        outputs: [
          100.stack(() => Foods.cookedFish),
        ],
        cookingTime: const TS.hm(hour: 1, minute: 0),
      )
    ]);
  }
}
