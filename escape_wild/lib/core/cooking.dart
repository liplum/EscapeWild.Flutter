import 'package:collection/collection.dart';
import 'package:escape_wild/core.dart';
import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cooking.g.dart';

abstract class FoodRecipeProtocol with Moddable {
  /// The max cooking slot.
  static const maxIngredient = 3;
  static const maxSlot = maxIngredient * 2;

  @override
  final String name;

  FoodRecipeProtocol(this.name);

  /// ## Constrains
  /// - [inputs] is in no order.
  /// - [inputs.length] equals to [slotRequired].
  /// - [slots] is [Backpack.untracked].
  bool match(@Backpack.untracked List<ItemStack> inputs);

  /// ## Constrains
  /// - [slots] is in no order.
  /// - [slots] is already matched.
  /// - [slots] is [Backpack.untracked].
  /// - return whether cooking is finished.
  bool updateCooking(@Backpack.untracked List<ItemStack> slots, TS totalTimePassed);
}

/// - [FoodRecipe] will output the food as long as [cookingTime] is reached.
/// - [FoodRecipe] can only output one item.
///
/// [Item.container] is not allowed.
@JsonSerializable(createToJson: false)
class FoodRecipe extends FoodRecipeProtocol implements JConvertibleProtocol {
  @JsonKey()
  final List<TagMassEntry> ingredients;
  @itemGetterJsonKey
  final ItemGetter output;
  final int? outputMass;
  @TS.jsonKey
  final TS cookingTime;

  FoodRecipe(
    super.name, {
    required this.ingredients,
    required this.output,
    required this.cookingTime,
    this.outputMass,
  }) {
    assert(ingredients.isNotEmpty, "Ingredients of $registerName is empty.");
    assert(ingredients.length <= FoodRecipeProtocol.maxIngredient,
        "Ingredients of $registerName is > ${FoodRecipeProtocol.maxIngredient}.");
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
  bool updateCooking(List<ItemStack> slots, TS totalTimePassed) {
    // It must reach the [cookingTime]
    if (totalTimePassed < cookingTime) return false;
    if (slots.length != ingredients.length) return false;
    // Cooked!
    final rest = Set.of(slots);
    for (final ingredient in ingredients) {
      final matched = rest.firstWhereOrNull((input) => isMatched(input, ingredient));
      assert(matched != null, "$slots should match $registerName in $updateCooking");
      if (matched == null) return false;
      rest.remove(matched);
      if (matched.meta.mergeable) {
        matched.mass = matched.stackMass - (ingredient.mass ?? 0);
      } else {
        slots.removeStack(matched);
      }
    }
    slots.cleanEmptyStack();
    slots.add(output().create(mass: outputMass));
    return true;
  }

  static const type = "FoodRecipe";

  @override
  String get typeName => type;
}
