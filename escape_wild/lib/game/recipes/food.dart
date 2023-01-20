import 'package:escape_wild/core.dart';
import 'package:escape_wild/foundation.dart';

class FoodRecipes {
  FoodRecipes._();

  static void registerAll() {
    _registerSpecial();
    Contents.cookRecipes.addAll([
      ContinuousCookRecipe(
        "cook-fish",
        ingredient: {"raw", "fish"},
        dish: () => Foods.cookedFish,
        speed: 500 / 30,
        ratio: 0.65,
      ),
      ContinuousCookRecipe(
        "cook-rabbit",
        ingredient: {"raw", "rabbit"},
        dish: () => Foods.cookedRabbit,
        speed: 500 / 30,
        ratio: 0.7,
      ),
      ContinuousCookRecipe(
        "cook-bear-meat",
        ingredient: {"raw", "bear-meat"},
        dish: () => Foods.cookedBearMeat,
        speed: 500 / 30,
        ratio: 0.75,
      ),
      // TODO: work with container
      ContinuousCookRecipe(
        "boiling-dirty-water",
        ingredient: {"dirty-water"},
        dish: () => Foods.boiledWater,
        speed: 100 / 5,
      ),
      ContinuousCookRecipe(
        "roast-berry",
        ingredient: {"raw", "berry"},
        dish: () => Foods.roastedBerry,
        speed: 500 / 10,
        ratio: 0.6,
      ),
      ContinuousCookRecipe(
        "toast-nuts",
        ingredient: {"raw", "nuts"},
        dish: () => Foods.roastedBerry,
        speed: 500 / 20,
        ratio: 0.95,
      ),
    ]);
  }

  static void _registerSpecial() {
    Contents.cookRecipes.addAll([
      InstantConvertCookRecipe(
        "light-torch",
        input: () => Tools.unlitTorch,
        output: () => Tools.litTorch,
      ),
    ]);
  }
}
