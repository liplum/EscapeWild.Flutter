import 'package:escape_wild/core.dart';
import 'package:escape_wild/foundation.dart';

class FoodRecipes {
  FoodRecipes._();

  static void registerAll() {
    Contents.cookRecipes.addAll([
      TransformCookRecipe(
        "cook-fish",
        ingredient: {"raw", "fish"},
        dish: () => Foods.cookedFish,
        speed: 500 / 30,
        ratio: 0.65,
      ),
      TransformCookRecipe(
        "cook-rabbit",
        ingredient: {"raw", "rabbit"},
        dish: () => Foods.cookedRabbit,
        speed: 500 / 30,
        ratio: 0.7,
      ),
      TransformCookRecipe(
        "cook-bear-meat",
        ingredient: {"raw", "bear-meat"},
        dish: () => Foods.cookedBearMeat,
        speed: 500 / 30,
        ratio: 0.75,
      ),
      // TODO: work with container
      TransformCookRecipe(
        "boiling-dirty-water",
        ingredient: {"dirty-water"},
        dish: () => Foods.boiledWater,
        speed: 100 / 5,
      ),
      TransformCookRecipe(
        "roast-berry",
        ingredient: {"raw", "berry"},
        dish: () => Foods.roastedBerry,
        speed: 500 / 10,
        ratio: 0.6,
      ),
      TransformCookRecipe(
        "toast-nuts",
        ingredient: {"raw", "nuts"},
        dish: () => Foods.roastedBerry,
        speed: 500 / 20,
        ratio: 0.95,
      ),
    ]);
  }
}
