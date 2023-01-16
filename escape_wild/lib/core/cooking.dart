import 'package:collection/collection.dart';
import 'package:escape_wild/core.dart';
import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cooking.g.dart';

abstract class FoodRecipeProtocol with Moddable {
  /// The max cooking slot.
  static const maxSlot = 4;

  @override
  final String name;

  FoodRecipeProtocol(this.name);

  /// It's used to pre-check if this recipe is matched.
  /// Or for building UI.
  int get slotRequired;

  /// ## Constrains
  /// - [inputs] is in no order.
  /// - [inputs.length] equals to [slotRequired].
  bool match(List<ItemStack> inputs);

  /// ## Constrains
  /// - [inputs] is in no order.
  /// - [inputs] is already matched.
  List<ItemStack> checkCook(List<ItemStack> inputs, TS timePassed);
}

/// [FoodRecipe] will output the food as long as [cookingTime] is reached.
///
/// [Item.container] is not allowed.
@JsonSerializable(createToJson: false)
class FoodRecipe extends FoodRecipeProtocol implements JConvertibleProtocol {
  @JsonKey()
  final List<TagMassEntry> ingredients;
  @JsonKey()
  final List<TagMassEntry> outputs;
  @JsonKey(fromJson: TS.fromJsom)
  final TS cookingTime;

  @override
  int get slotRequired => ingredients.length;

  FoodRecipe(
    super.name, {
    required this.ingredients,
    required this.outputs,
    required this.cookingTime,
  }) {
    assert(ingredients.isNotEmpty, "Ingredients of $registerName is empty.");
    assert(outputs.isNotEmpty, "Outputs of $registerName is empty.");
  }

  factory FoodRecipe.fromJson(Map<String, dynamic> json) => _$FoodRecipeFromJson(json);

  @override
  bool match(List<ItemStack> inputs) {
    if (inputs.length != slotRequired) return false;
    // Container is not allowed.
    if (inputs.any((input) => input.meta.isContainer)) return false;
    final rest = Set.of(inputs);
    for (final ingredient in ingredients) {
      final tagMatched = rest.firstWhereOrNull((input) => isMatched(input, ingredient));
      if (tagMatched == null) return false;
      rest.remove(tagMatched);
    }
    return rest.isEmpty;
  }

  bool isMatched(ItemStack input, TagMassEntry ingredient) {
    if (!input.meta.hasTag(ingredient.tag)) return false;
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
  List<ItemStack> checkCook(List<ItemStack> inputs, TS timePassed) {
    // It must reach the [cookingTime]
    if (timePassed < cookingTime) return inputs;
    if (inputs.length != slotRequired) return inputs;
    final rest = Set.of(inputs);
    final res = [];
    for (final ingredient in ingredients) {
      final tagMatched = rest.firstWhereOrNull((input) => isMatched(input, ingredient));
      assert(tagMatched != null, "$inputs should match $registerName in $checkCook");
      if (tagMatched == null) return inputs;
      rest.remove(tagMatched);

    }
    return const [];
  }

  static const type = "FoodRecipe";

  @override
  String get typeName => type;
}
