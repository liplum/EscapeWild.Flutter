import 'package:escape_wild/core.dart';
import 'package:json_annotation/json_annotation.dart';

abstract class CookRecipeProtocol with Moddable {
  /// The max cooking slot.
  static const maxIngredient = 3;

  @override
  final String name;

  CookRecipeProtocol(this.name);

  /// ## Constrains
  /// - [inputs] is in no order.
  /// - [inputs.length] equals to [slotRequired].
  /// - [inputs] is [Backpack.untracked].
  bool match(@Backpack.untracked List<ItemStack> inputs);

  /// Called as long as this is matched.
  /// ## Constrains
  /// - [inputs] is in no order.
  /// - [inputs] is already matched.
  /// - [inputs] is [Backpack.untracked].
  /// - [outputs] is in no order.
  /// - [outputs] is [Backpack.untracked].
  /// - return whether [inputs] or [outputs] was changed.
  /// ## Use cases
  /// - Instant cooking: such as igniting a torch.
  @Backpack.untracked
  bool onMatch(
    @Backpack.untracked List<ItemStack> inputs,
    @Backpack.untracked List<ItemStack> outputs,
  ) {
    return false;
  }

  /// ## Constrains
  /// - [inputs] is in no order.
  /// - [inputs] is already matched.
  /// - [inputs] is [Backpack.untracked].
  /// - [outputs] is in no order.
  /// - [outputs] is [Backpack.untracked].
  /// - return whether [inputs] or [outputs] was changed.
  @Backpack.untracked
  bool updateCooking(
    @Backpack.untracked List<ItemStack> inputs,
    @Backpack.untracked List<ItemStack> outputs,
    Ts totalTimePassed,
    Ts delta,
  ) {
    return false;
  }

  static String? getNameOrNull(CookRecipeProtocol? recipe) => recipe?.name;
  static const jsonKey = JsonKey(fromJson: Contents.getCookRecipesByName, toJson: getNameOrNull, includeIfNull: false);
}

CookRecipeProtocol? matchCookRecipe(List<ItemStack> stacks) {
  if (stacks.isEmpty) return null;
  for (final recipe in Contents.cookRecipes.name2FoodRecipe.values) {
    if (recipe.match(stacks)) {
      return recipe;
    }
  }
  return null;
}
