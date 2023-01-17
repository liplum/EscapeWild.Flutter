import 'package:collection/collection.dart';
import 'package:escape_wild/core.dart';
import 'package:flutter/widgets.dart';
import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cooking.g.dart';

abstract class CookRecipeProtocol with Moddable {
  /// The max cooking slot.
  static const maxIngredient = 3;

  @override
  final String name;

  CookRecipeProtocol(this.name);

  /// ## Constrains
  /// - [inputs] is in no order.
  /// - [inputs.length] equals to [slotRequired].
  /// - [slots] is [Backpack.untracked].
  bool match(@Backpack.untracked List<ItemStack> inputs);

  /// ## Constrains
  /// - [slots] is in no order.
  /// - [slots] is already matched.
  /// - [slots] is [Backpack.untracked].
  /// - return a new list of output slots.
  @Backpack.untracked
  List<ItemStack> updateCooking(@Backpack.untracked List<ItemStack> slots, TS totalTimePassed);

  static String? getNameOrNull(CookRecipeProtocol? recipe) => recipe?.name;
  static const jsonKey = JsonKey(fromJson: Contents.getCookRecipesByName, toJson: getNameOrNull, includeIfNull: false);
}

/// - [FoodRecipe] will output the food as long as [cookingTime] is reached.
/// - [FoodRecipe] can only output one item.
///
/// [Item.container] is not allowed.
@JsonSerializable(createToJson: false)
class FoodRecipe extends CookRecipeProtocol implements JConvertibleProtocol {
  @JsonKey()
  final List<TagMassEntry> ingredients;
  @JsonKey()
  final List<LazyItemStack> outputs;
  @TS.jsonKey
  final TS cookingTime;

  FoodRecipe(
    super.name, {
    required this.ingredients,
    required this.outputs,
    required this.cookingTime,
  }) {
    assert(ingredients.isNotEmpty, "Ingredients of $registerName is empty.");
    assert(ingredients.length <= CookRecipeProtocol.maxIngredient,
        "Ingredients of $registerName is > ${CookRecipeProtocol.maxIngredient}.");
    assert(outputs.isNotEmpty, "Outputs of $registerName is empty.");
  }

  factory FoodRecipe.fromJson(Map<String, dynamic> json) => _$FoodRecipeFromJson(json);

  @override
  bool match(List<ItemStack> inputs) {
    if (inputs.length != ingredients.length) return false;
    // Container is not allowed.
    if (inputs.any((input) => input.meta.isContainer)) return false;
    final rest = Set.of(inputs);
    for (final ingredient in ingredients) {
      final matched = rest.firstWhereOrNull((input) => isMatched(input, ingredient));
      if (matched == null) return false;
      rest.remove(matched);
    }
    return rest.isEmpty;
  }

  bool isMatched(ItemStack input, TagMassEntry ingredient) {
    if (!input.meta.hasTags(ingredient.tags)) return false;
    final massReq = ingredient.mass;
    // [massReq] is null, the input should be unmergeable.
    // otherwise, [ItemStack.stackMass] should reach the [massReq].
    if (massReq == null) {
      return input.meta.mergeable;
    } else {
      return input.stackMass >= massReq;
    }
  }

  @override
  List<ItemStack> updateCooking(List<ItemStack> slots, TS totalTimePassed) {
    // It must reach the [cookingTime]
    if (totalTimePassed < cookingTime) return const [];
    if (slots.length != ingredients.length) return const [];
    // Cooked!
    final rest = Set.of(slots);
    for (final ingredient in ingredients) {
      final matched = rest.firstWhereOrNull((input) => isMatched(input, ingredient));
      assert(matched != null, "$slots should match $registerName in $updateCooking");
      if (matched == null) return const [];
      rest.remove(matched);
      if (matched.meta.mergeable) {
        matched.mass = matched.stackMass - (ingredient.mass ?? 0);
      } else {
        slots.removeStack(matched);
      }
    }
    slots.cleanEmptyStack();
    final res = <ItemStack>[];
    for (final output in outputs) {
      final item = output.item();
      final mass = output.mass;
      res.add(item.create(mass: mass));
    }
    return res;
  }

  static const type = "FoodRecipe";

  @override
  String get typeName => type;
}

class CookRecipeFinder {
  CookRecipeFinder._();

  static CookRecipeProtocol? match(List<ItemStack> stacks) {
    if (stacks.isEmpty) return null;
    for (final recipe in Contents.cookRecipes.name2FoodRecipe.values) {
      if (recipe.match(stacks)) {
        return recipe;
      }
    }
    return null;
  }
}

mixin CampfireCookingMixin implements CampfireHolderProtocol {
  @JsonKey(fromJson: TS.fromJsom)
  TS cookingTime = TS.zero;
  List<ItemStack> _onCampfire = [];

  @override
  @CampfireHolderProtocol.onCampfireJsonKey
  List<ItemStack> get onCampfire => _onCampfire;
  @CookRecipeProtocol.jsonKey
  CookRecipeProtocol? recipe;

  @override
  set onCampfire(List<ItemStack> v) {
    _onCampfire = v;
    cookingTime = TS.zero;
  }

  @mustCallSuper
  Future<void> onCookingPass(TS delta) async {
    // only cooking when fireState is active
    if (!$fireState.value.active) return;
    if (onCampfire.isEmpty) return;
    this.recipe ??= CookRecipeFinder.match(onCampfire);
    final recipe = this.recipe;
    if (recipe == null) {
      cookingTime = TS.zero;
    } else {
      cookingTime += delta;
      recipe.updateCooking(onCampfire, cookingTime);
    }
  }
}
