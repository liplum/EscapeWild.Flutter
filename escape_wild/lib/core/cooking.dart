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
  /// - [inputs] is [Backpack.untracked].
  bool match(@Backpack.untracked List<ItemStack> inputs);

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
    TS totalTimePassed,
  );

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
  bool updateCooking(List<ItemStack> inputs, List<ItemStack> outputs, TS totalTimePassed) {
    // It must reach the [cookingTime]
    if (totalTimePassed < cookingTime) return false;
    if (inputs.length != ingredients.length) return false;
    // Cooked!
    final rest = Set.of(inputs);
    for (final ingredient in ingredients) {
      final matched = rest.firstWhereOrNull((input) => isMatched(input, ingredient));
      assert(matched != null, "$inputs should match $registerName in $updateCooking");
      if (matched == null) return false;
      rest.remove(matched);
      if (matched.meta.mergeable) {
        matched.mass = matched.stackMass - (ingredient.mass ?? 0);
      } else {
        inputs.removeStack(matched);
      }
    }
    inputs.cleanEmptyStack();
    for (final output in this.outputs) {
      final item = output.item();
      final mass = output.mass;
      final created = item.create(mass: mass);
      outputs.addItemOrMerge(created);
    }
    return true;
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
  @override
  late final $onCampfire = ValueNotifier<List<ItemStack>>([])
    ..addListener(() {
      cookingTime = TS.zero;
    });
  @override
  final $offCampfire = ValueNotifier<List<ItemStack>>([]);

  @CampfireHolderProtocol.campfireStackJsonKey
  List<ItemStack> get onCampfire => $onCampfire.value;

  set onCampfire(List<ItemStack> v) => $onCampfire.value = v;

  @CampfireHolderProtocol.campfireStackJsonKey
  List<ItemStack> get offCampfire => $offCampfire.value;

  set offCampfire(List<ItemStack> v) => $offCampfire.value = v;

  @CookRecipeProtocol.jsonKey
  CookRecipeProtocol? recipe;

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
      final changed = recipe.updateCooking(onCampfire, offCampfire, cookingTime);
      if (changed) {
        onCampfire = List.of(onCampfire);
        offCampfire = List.of(offCampfire);
        this.recipe = null;
        cookingTime = TS.zero;
      }
    }
  }
}
