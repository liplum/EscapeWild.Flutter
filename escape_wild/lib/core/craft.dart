import 'package:escape_wild/core.dart';
import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'craft.g.dart';

class CraftType with Moddable {
  @override
  final String name;

  CraftType(this.name);

  factory CraftType.named(String name) => CraftType(name);

  String l10nName() => i18n("craft-type.$name");

  static final CraftType craft = CraftType("craft"), repair = CraftType("repair"), process = CraftType("process");

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CraftType || other.runtimeType != runtimeType) return false;
    return name == other.name;
  }

  @override
  int get hashCode => name.hashCode;
}

class CraftRecipeCat with Moddable {
  @override
  final String name;

  CraftRecipeCat(this.name);

  CraftRecipeCat.named(this.name);

  static final CraftRecipeCat tool = CraftRecipeCat("tool"),
      survival = CraftRecipeCat("survival"),
      food = CraftRecipeCat("food"),
      fire = CraftRecipeCat("fire"),
      refine = CraftRecipeCat("refine"),
      medical = CraftRecipeCat("medical");

  String l10nName() => i18n("craft-recipe-cat.$name");

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CraftRecipeCat || runtimeType != other.runtimeType) return false;
    return name == other.name;
  }

  @override
  int get hashCode => name.hashCode;
}

String _cat2Name(CraftRecipeCat cat) => cat.name;

String _craftType2Name(CraftType craftType) => craftType.name;

typedef ItemStackConsumeReceiver = void Function(ItemStack item, int? mass);

abstract class CraftRecipeProtocol with Moddable {
  @JsonKey(fromJson: CraftRecipeCat.named, toJson: _cat2Name)
  final CraftRecipeCat cat;
  @JsonKey(fromJson: CraftType.named, toJson: _craftType2Name)
  final CraftType craftType;
  @override
  @JsonKey()
  final String name;

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<ItemMatcher> get inputSlots;

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<ItemMatcher> get toolSlots;

  CraftRecipeProtocol(
    this.name,
    this.cat, {
    CraftType? craftType,
  }) : craftType = craftType ?? CraftType.craft;

  Item get outputItem;

  ItemStack onCraft(List<ItemStack> inputs);

  /// The order of [inputs] should be the same as [inputSlots].
  /// - [inputs] is [Backpack.untracked].
  void onConsume(List<ItemStack> inputs, ItemStackConsumeReceiver consume);
}

/// It will merge [WetnessComp].
@JsonSerializable(createToJson: false)
class TagCraftRecipe extends CraftRecipeProtocol implements JConvertibleProtocol {
  @JsonKey()
  final List<TagMassEntry> ingredients;
  @JsonKey(fromJson: NamedItemGetter.create)
  final ItemGetter output;

  /// The order of inputs should be
  /// - [names]
  /// - [ingredients]
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<ItemMatcher> inputSlots = [];
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  List<ItemMatcher> toolSlots = [];
  final int? outputMass;

  TagCraftRecipe(
    super.name,
    super.cat, {
    required this.ingredients,
    super.craftType,
    this.outputMass,
    required this.output,
  }) {
    assert(ingredients.isNotEmpty, "Ingredients of $registerName is empty.");
    for (final ingredient in ingredients) {
      inputSlots.add(ItemMatcher(
        typeOnly: (item) => item.hasTags(ingredient.tags),
        exact: (item) {
          if (!item.meta.hasTags(ingredient.tags)) return ItemStackMatchResult.typeUnmatched;
          if (item.stackMass < (ingredient.mass ?? 0.0)) return ItemStackMatchResult.massUnmatched;
          return ItemStackMatchResult.matched;
        },
      ));
    }
  }

  @override
  Item get outputItem => output();

  @override
  ItemStack onCraft(List<ItemStack> inputs) {
    var sumMass = 0;
    var sumWet = 0.0;
    for (final tag in ingredients) {
      final input = inputs.findFirstByTags(tag.tags);
      assert(input != null, "$tag not found in $inputs");
      if (input == null) return ItemStack.empty;
      final inputMass = input.stackMass;
      sumMass += inputMass;
      sumWet += WetnessComp.tryGetWetness(input) * inputMass;
    }
    final res = output().create(mass: outputMass);
    WetnessComp.trySetWetness(res, sumWet / sumMass);
    return res;
  }

  @override
  void onConsume(List<ItemStack> inputs, ItemStackConsumeReceiver consume) {
    var i = 0;
    for (final tag in ingredients) {
      final input = inputs[i];
      consume(input, tag.mass);
      i++;
    }
  }

  factory TagCraftRecipe.fromJson(Map<String, dynamic> json) => _$TagCraftRecipeFromJson(json);

  static const type = "TagCraftRecipe";

  @override
  String get typeName => type;
}
