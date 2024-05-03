import 'dart:math';

import 'package:collection/collection.dart';
import 'package:escape_wild/core.dart';
import 'package:flutter/widgets.dart';
import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';

import 'item_comp/durability.dart';
import 'item_comp/freshness.dart';
import 'item_comp/wetness.dart';
import 'item_prop.dart';

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

/// - [dishes] will be created as long as [cookingTime] is reached.
///
/// [Item.container] is not allowed.
@JsonSerializable(createToJson: false)
class TimedCookRecipe extends CookRecipeProtocol implements JConvertibleProtocol {
  @JsonKey()
  final List<TagMassEntry> ingredients;
  @JsonKey()
  final List<LazyItemStack> dishes;
  @JsonKey()
  final Ts cookingTime;

  TimedCookRecipe(
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

  factory TimedCookRecipe.fromJson(Map<String, dynamic> json) => _$TimedCookRecipeFromJson(json);

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
  bool updateCooking(
    List<ItemStack> inputs,
    List<ItemStack> outputs,
    Ts totalTimePassed,
    Ts delta,
  ) {
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

  static const type = "TimedCookRecipe";

  @override
  String get typeName => type;
}

/// [ContainerCookRecipe] will transform a certain [Item] that meets [inputTags] into [result] by a certain ratio.
/// It only allow one input.
///
/// For example,
class ContainerCookRecipe extends CookRecipeProtocol implements JConvertibleProtocol {
  final List<String> inputTags;
  final ItemGetter result;

  ContainerCookRecipe(super.name, this.inputTags, this.result);

  @override
  bool match(List<ItemStack> inputs) {
    throw UnimplementedError();
  }

  @override
  bool updateCooking(
    List<ItemStack> inputs,
    List<ItemStack> outputs,
    Ts totalTimePassed,
    Ts delta,
  ) {
    throw UnimplementedError();
  }

  static const type = "ContainerCookRecipe";

  @override
  String get typeName => type;
}

/// [ContinuousCookRecipe] will continuously convert a certain [Item] that meets [ingredient] into [dish] by a certain ratio.
/// - [ingredient] only matches one whose [Item.mergeable] is true.
///
/// It doesn't allow [Item.container].
@JsonSerializable(createToJson: false)
class ContinuousCookRecipe extends CookRecipeProtocol implements JConvertibleProtocol {
  @JsonKey()
  final Iterable<String> ingredient;
  @itemGetterJsonKey
  final ItemGetter dish;

  /// [speed] is how much [ingredient] that will be transform to [dish] per minutes.
  /// ```dart
  /// int mass;
  /// int minute;
  /// speed = mass / minute;
  /// ```
  /// Unit: g/min
  final double speed;

  /// [ratio] works with [speed]. It's how much [dish] based on [speed]
  /// ```dart
  /// int transformedInput = speed * time;
  /// int outputMass = transformedInput * ratio;
  /// ```
  ///
  /// The default is 1.0
  final double ratio;

  ContinuousCookRecipe(
    super.name, {
    required this.ingredient,
    required this.dish,
    required this.speed,
    this.ratio = 1.0,
  }) {
    assert(ingredient.isNotEmpty, "Input tags of $registerName is empty.");
  }

  @override
  bool match(List<ItemStack> inputs) {
    if (inputs.length != 1) return false;
    final input = inputs.first;
    if (!input.meta.mergeable) return false;
    if (!input.meta.hasTags(ingredient)) return false;
    return true;
  }

  @override
  bool updateCooking(
    List<ItemStack> inputs,
    List<ItemStack> outputs,
    Ts totalTimePassed,
    Ts delta,
  ) {
    if (inputs.length != 1) return false;
    final input = inputs.first;
    if (!input.meta.mergeable) return false;
    if (!input.meta.hasTags(ingredient)) return false;
    double transformedInputF = min(speed * delta.minutes, input.stackMass.toDouble());
    double outputMassF = transformedInputF * ratio;
    // to avoid lose of precision.
    int transformedInput = transformedInputF.toInt();
    int outputMass = outputMassF.toInt();
    input.mass = input.stackMass - transformedInput;
    inputs.cleanEmptyStack();
    final result = dish();
    final resultStack = result.create(mass: outputMass);
    outputs.addItemOrMerge(resultStack);
    return true;
  }

  factory ContinuousCookRecipe.fromJson(Map<String, dynamic> json) => _$ContinuousCookRecipeFromJson(json);

  static const type = "TransformCookRecipe";

  @override
  String get typeName => type;
}

/// [InstantConvertCookRecipe] will transform an [Item] to another one instantly.
///
/// It doesn't allow [Item.container].
@JsonSerializable(createToJson: false)
class InstantConvertCookRecipe extends CookRecipeProtocol implements JConvertibleProtocol {
  /// the item as input
  @itemGetterJsonKey
  final ItemGetter input;

  /// If [input] is mergeable, cooking will consume [inputMass] amount of [input].
  final int? inputMass;

  /// the item as output
  @itemGetterJsonKey
  final ItemGetter output;

  /// If [output] is mergeable, cooking will create [outputMass] amount of [output].
  final int? outputMass;
  static const Set<ItemProp> kKeptProps = {
    ItemProp.mass,
    ItemProp.wetness,
    ItemProp.durability,
    ItemProp.freshness,
  };
  @JsonKey()
  final Set<ItemProp> keptProps;

  InstantConvertCookRecipe(
    super.name, {
    required this.input,
    required this.output,
    this.keptProps = InstantConvertCookRecipe.kKeptProps,
    this.inputMass,
    this.outputMass,
  });

  @override
  bool match(List<ItemStack> inputs) {
    if (inputs.length != 1) return false;
    final meta = inputs.first.meta;
    if (meta.isContainer) return false;
    return meta == input();
  }

  @override
  bool onMatch(List<ItemStack> inputs, List<ItemStack> outputs) {
    if (inputs.length != 1) return false;
    final input = inputs.first;
    if (input.meta != this.input()) return false;
    // handle input
    int? outputMass = this.outputMass;
    if (input.meta.mergeable) {
      int? inputMass = this.inputMass;
      assert(inputMass != null, "${input.meta} is mergeable but [inputMass] is not specified.");
      if (inputMass == null) {
        // if [inputMass] is empty, clear the input.
        inputs.clear();
      } else {
        input.mass = input.stackMass - inputMass;
        if (keptProps.contains(ItemProp.mass)) {
          // when [ItemProp.mass] is kept
          inputMass = input.stackMass;
        }
      }
    } else {
      inputs.clear();
    }
    // handle output
    final outputStack = output().create(mass: outputMass);
    _bakeOutput(input, outputStack);
    outputs.addItemOrMerge(outputStack);
    return true;
  }

  void _bakeOutput(ItemStack input, ItemStack output) {
    for (final prop in keptProps) {
      switch (prop) {
        case ItemProp.wetness:
          final inputComp = WetnessComp.of(input);
          final outputComp = WetnessComp.of(output);
          if (inputComp != null && outputComp != null) {
            outputComp.setWetness(output, inputComp.getWetness(input));
          }
          break;
        case ItemProp.durability:
          final inputComp = DurabilityComp.of(input);
          final outputComp = DurabilityComp.of(output);
          if (inputComp != null && outputComp != null) {
            outputComp.setDurability(output, inputComp.getDurability(input));
          }
          break;
        case ItemProp.freshness:
          final inputComp = FreshnessComp.of(input);
          final outputComp = FreshnessComp.of(output);
          if (inputComp != null && outputComp != null) {
            outputComp.setFreshness(output, inputComp.getFreshness(input));
          }
          break;
        default:
      }
    }
  }

  factory InstantConvertCookRecipe.fromJson(Map<String, dynamic> json) => _$InstantConvertCookRecipeFromJson(json);

  static const type = "InstantConvertCookRecipe";

  @override
  String get typeName => type;
}

CookRecipeProtocol? _match(List<ItemStack> stacks) {
  if (stacks.isEmpty) return null;
  for (final recipe in Contents.cookRecipes.name2FoodRecipe.values) {
    if (recipe.match(stacks)) {
      return recipe;
    }
  }
  return null;
}

abstract class CampfirePlaceProtocol extends PlaceProtocol with ChangeNotifier {
  FireState get fireState;

  set fireState(FireState v);

  List<ItemStack> get onCampfire;

  set onCampfire(List<ItemStack> v);

  List<ItemStack> get offCampfire;

  set offCampfire(List<ItemStack> v);

  void onResetCooking();
}

extension CampfireHolderProtocolX on CampfirePlaceProtocol {
  bool get isCampfireHasAnyStack => onCampfire.isNotEmpty || offCampfire.isNotEmpty;
}

mixin CampfireCookingMixin on CampfirePlaceProtocol {
  @JsonKey(fromJson: tsFromJson, toJson: tsToJson, includeIfNull: false)
  Ts cookingTime = Ts.zero;
  List<ItemStack> _onCampfire = [];

  @override
  @JsonKey(fromJson: campfireStackFromJson, toJson: campfireStackToJson, includeIfNull: false)
  List<ItemStack> get onCampfire => _onCampfire;

  @override
  set onCampfire(List<ItemStack> v) {
    _onCampfire = v;
    notifyListeners();
  }

  List<ItemStack> _offCampfire = [];

  @override
  @JsonKey(fromJson: campfireStackFromJson, toJson: campfireStackToJson, includeIfNull: false)
  List<ItemStack> get offCampfire => _offCampfire;

  @override
  set offCampfire(List<ItemStack> v) {
    _offCampfire = v;
    notifyListeners();
  }

  @CookRecipeProtocol.jsonKey
  CookRecipeProtocol? recipe;

  FireState _fireState = FireState.off;

  @override
  @JsonKey(fromJson: fireStateFromJson, toJson: fireStateStackToJson, includeIfNull: false)
  FireState get fireState => _fireState;

  @override
  set fireState(FireState v) {
    _fireState = v;
    notifyListeners();
  }

  double get fuelCostPerMinute;

  /// Call this after changing [onCampfire].
  @override
  void onResetCooking() {
    cookingTime = Ts.zero;
    final matched = _match(onCampfire);
    recipe = matched;
    if (matched != null) {
      // for instant cooking
      final changed = matched.onMatch(onCampfire, offCampfire);
      if (changed) {
        notifyListeners();
      }
    }
  }

  Future<void> onCampfirePass(Ts delta) async {
    // update items the place holds
    for (final stack in onCampfire) {
      await stack.onPassTime(delta);
    }
    for (final stack in offCampfire) {
      await stack.onPassTime(delta);
    }
    if (fireState.active) {
      final cost = delta.minutes * fuelCostPerMinute;
      fireState = _burningFuel(fireState, cost);
    }
    // only cooking when fire has fuel.
    if (fireState.fuel <= 0) return;
    if (onCampfire.isEmpty) return;
    final recipe = this.recipe ??= _match(onCampfire);
    if (recipe == null) {
      cookingTime = Ts.zero;
    } else {
      cookingTime += delta;
      final changed = recipe.updateCooking(onCampfire, offCampfire, cookingTime, delta);
      if (changed) {
        this.recipe = null;
        cookingTime = Ts.zero;
        notifyListeners();
      }
    }
  }

  Future<void> onFirePass(double fuelCostSpeed, Ts delta) async {
    final fireState = this.fireState;
    if (fireState.active) {
      final cost = delta / actionStepTime * fuelCostSpeed;
      this.fireState = _burningFuel(fireState, cost);
    }
  }

  static List<ItemStack> campfireStackFromJson(dynamic json) =>
      json == null ? [] : (json as List<dynamic>).map((e) => ItemStack.fromJson(e as Map<String, dynamic>)).toList();

  static dynamic campfireStackToJson(List<ItemStack> list) => list.isEmpty ? null : list;

  static Ts tsFromJson(dynamic json) => json == null ? Ts.zero : Ts.fromJson((json as num).toInt());

  static dynamic tsToJson(Ts ts) => ts == Ts.zero ? null : ts;

  static FireState fireStateFromJson(dynamic json) => json == null ? FireState.off : FireState.fromJson(json);

  static dynamic fireStateStackToJson(FireState fire) => fire.isOff ? null : fire;
}

const _emberCostFactor = 5;

// TODO: Better formula
FireState _burningFuel(
  FireState former,
  double cost,
) {
  final curFuel = former.fuel;
  var resFuel = curFuel;
  var resEmber = former.ember;
  if (curFuel <= cost) {
    final costOverflow = cost - curFuel;
    resFuel = 0;
    resEmber += curFuel;
    resEmber -= costOverflow * _emberCostFactor;
  } else {
    resFuel -= cost;
    resEmber += cost;
  }
  return FireState(ember: resEmber, fuel: resFuel);
}
