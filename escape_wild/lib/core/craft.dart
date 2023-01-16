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

  @override
  String toString() => name;
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

  @JsonKey(ignore: true)
  List<ItemMatcher> get inputSlots;

  @JsonKey(ignore: true)
  List<ItemMatcher> get toolSlots;

  CraftRecipeProtocol(
    this.name,
    this.cat, {
    CraftType? craftType,
  }) : craftType = craftType ?? CraftType.craft;

  Item get outputItem;

  ItemStack onCraft(List<ItemStack> inputs);

  /// The order of [inputs] should be the same as [inputSlots].
  void onConsume(List<ItemStack> inputs, ItemStackConsumeReceiver consume);
}

@JsonSerializable()
class StringMassEntry {
  @JsonKey()
  final String str;
  @JsonKey()
  final int? mass;

  const StringMassEntry(this.str, this.mass);

  factory StringMassEntry.fromJson(Map<String, dynamic> json) => _$StringMassEntryFromJson(json);

  Map<String, dynamic> toJson() => _$StringMassEntryToJson(this);

  @override
  String toString() {
    final mass = this.mass;
    return mass == null ? str : "$str ${mass}g";
  }
}

@JsonSerializable(createToJson: false)
class MixCraftRecipe extends CraftRecipeProtocol implements JConvertibleProtocol {
  /// Item names.
  @JsonKey()
  final List<StringMassEntry> names;

  /// Item tags.
  @JsonKey()
  final List<StringMassEntry> tags;
  @JsonKey(fromJson: NamedItemGetter.create)
  final ItemGetter<Item> output;
  @override
  @JsonKey(ignore: true)
  List<ItemMatcher> toolSlots = [];

  /// The order of inputs should be
  /// - [names]
  /// - [tags]
  @override
  @JsonKey(ignore: true)
  List<ItemMatcher> inputSlots = [];
  final int? outputMass;

  MixCraftRecipe(
    super.name,
    super.cat, {
    this.names = const [],
    this.tags = const [],
    super.craftType,
    this.outputMass,
    required this.output,
  }) {
    for (final name in names) {
      inputSlots.add(ItemMatcher(
        typeOnly: (item) => item.name == name.str,
        exact: (item) => item.meta.name == name.str ? ItemStackMatchResult.matched : ItemStackMatchResult.typeUnmatched,
      ));
    }
    for (final tag in tags) {
      inputSlots.add(ItemMatcher(
        typeOnly: (item) => item.hasTag(tag.str),
        exact: (item) {
          if (!item.meta.hasTag(tag.str)) return ItemStackMatchResult.typeUnmatched;
          if (item.stackMass < (tag.mass ?? 0.0)) return ItemStackMatchResult.massUnmatched;
          return ItemStackMatchResult.matched;
        },
      ));
    }
  }

  @override
  Item get outputItem => output();

  factory MixCraftRecipe.fromJson(Map<String, dynamic> json) => _$MixCraftRecipeFromJson(json);
  static const type = "MixCraftRecipe";

  @override
  String get typeName => type;

  @override
  ItemStack onCraft(List<ItemStack> inputs) {
    return output().create();
  }

  @override
  void onConsume(List<ItemStack> inputs, ItemStackConsumeReceiver consume) {
    var i = 0;
    for (final name in names) {
      final input = inputs[i];
      consume(input, name.mass);
      i++;
    }
    for (final tag in tags) {
      final input = inputs[i];
      consume(input, tag.mass);
      i++;
    }
  }
}

@JsonSerializable(createToJson: false)
class MergeWetCraftRecipe extends CraftRecipeProtocol {
  @JsonKey()
  final List<StringMassEntry> inputTags;
  @JsonKey()
  final int? outputMass;
  @JsonKey(fromJson: NamedItemGetter.create)
  final ItemGetter<Item> output;

  @override
  @JsonKey(ignore: true)
  List<ItemMatcher> inputSlots = [];

  @override
  @JsonKey(ignore: true)
  List<ItemMatcher> toolSlots = [];

  MergeWetCraftRecipe(
    super.name,
    super.cat, {
    super.craftType,
    required this.inputTags,
    this.outputMass,
    required this.output,
  }) {
    for (final input in inputTags) {
      inputSlots.add(ItemMatcher(
        typeOnly: (item) => item.hasTag(input.str),
        exact: (item) {
          if (!item.meta.hasTag(input.str)) return ItemStackMatchResult.typeUnmatched;
          if (item.stackMass < (outputMass ?? item.meta.mass)) return ItemStackMatchResult.massUnmatched;
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
    for (final tag in inputTags) {
      final input = inputs.findFirstByTag(tag.str);
      assert(input != null, "$tag not found in $inputs");
      if (input == null) return ItemStack.empty;
      final inputMass = input.stackMass;
      sumMass += inputMass;
      sumWet += WetComp.tryGetWet(input) * inputMass;
    }
    final res = output().create(mass: outputMass);
    WetComp.trySetWet(res, sumWet / sumMass);
    return res;
  }

  @override
  void onConsume(List<ItemStack> inputs, ItemStackConsumeReceiver consume) {
    for (final tag in inputTags) {
      final input = inputs.findFirstByTag(tag.str);
      assert(input != null, "$tag not found in $inputs");
      if (input == null) continue;
      consume(input, tag.mass);
    }
  }

  factory MergeWetCraftRecipe.fromJson(Map<String, dynamic> json) => _$MergeWetCraftRecipeFromJson(json);
}
