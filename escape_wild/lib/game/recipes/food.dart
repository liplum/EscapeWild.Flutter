import 'package:escape_wild/core.dart';
import 'package:escape_wild/foundation.dart';

class FoodRecipes {
  FoodRecipes._();

  static void registerAll() {
    Contents.cookRecipes.addAll([
      TransformCookRecipe(
        "raw-fish-to-cooked",
        ingredient: ["raw", "fish"],
        dish: () => Foods.cookedFish,
        speed: 500 / 30,
        ratio: 0.65,
      ),
      TransformCookRecipe(
        "raw-rabbit-to-cooked",
        ingredient: ["raw", "rabbit"],
        dish: () => Foods.cookedRabbit,
        speed: 500 / 30,
        ratio: 0.7,
      )
    ]);
  }
}
