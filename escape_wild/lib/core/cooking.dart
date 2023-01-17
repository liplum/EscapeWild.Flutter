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

/// - [dishes] will be created as long as [cookingTime] is reached.
///
/// [Item.container] is not allowed.
@JsonSerializable(createToJson: false)
class TimedFoodRecipe extends CookRecipeProtocol implements JConvertibleProtocol {
  @JsonKey()
  final List<TagMassEntry> ingredients;
  @JsonKey()
  final List<LazyItemStack> dishes;
  @TS.jsonKey
  final TS cookingTime;

  TimedFoodRecipe(
    super.name, {
    required this.ingredients,
    required this.dishes,
    required this.cookingTime,
  }) {
    assert(ingredients.isNotEmpty, "Ingredients of $registerName is empty.");
    assert(ingredients.length <= CookRecipeProtocol.maxIngredient,
        "Ingredients of $registerName is > ${CookRecipeProtocol.maxIngredient}.");
    assert(dishes.isNotEmpty, "Outputs of $registerName is empty.");
  }

  factory TimedFoodRecipe.fromJson(Map<String, dynamic> json) => _$TimedFoodRecipeFromJson(json);

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
    for (final dish in dishes) {
      final item = dish.item();
      final mass = dish.mass;
      final created = item.create(mass: mass);
      outputs.addItemOrMerge(created);
    }
    return true;
  }

  static const type = "ExclusiveFoodRecipe";

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

abstract class CampfireHolderProtocol {
  @JsonKey(ignore: true)
  ValueNotifier<FireState> get $fireState;

  @JsonKey(ignore: true)
  ValueNotifier<List<ItemStack>> get $onCampfire;

  @JsonKey(ignore: true)
  ValueNotifier<List<ItemStack>> get $offCampfire;

  static const campfireStackJsonKey =
      JsonKey(fromJson: campfireStackFromJson, toJson: campfireStackToJson, includeIfNull: false);

  static List<ItemStack> campfireStackFromJson(dynamic json) =>
      json == null ? [] : (json as List<dynamic>).map((e) => ItemStack.fromJson(e as Map<String, dynamic>)).toList();

  static dynamic campfireStackToJson(List<ItemStack> list) => list.isEmpty ? null : list;
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
        // [ValueNotifier] compare the former and new value with ==,
        // so to re-create an list object is required.
        onCampfire = List.of(onCampfire);
        offCampfire = List.of(offCampfire);
        this.recipe = null;
        cookingTime = TS.zero;
      }
    }
  }
}
