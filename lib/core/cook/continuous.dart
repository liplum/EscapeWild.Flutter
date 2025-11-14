import 'dart:math';

import 'package:escape_wild/core/index.dart';
import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'continuous.g.dart';

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
    assert(ingredient.isNotEmpty, "Input tags of $name is empty.");
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
  bool updateCooking(List<ItemStack> inputs, List<ItemStack> outputs, Ts totalTimePassed, Ts delta) {
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
