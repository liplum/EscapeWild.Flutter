import 'package:escape_wild/core.dart';
import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'craft.g.dart';

class CraftType with Moddable {
  final String name;

  CraftType(this.name);

  factory CraftType.named(String name) => CraftType(name);

  String l10nName() => i18n("craft-type.$name");

  @override
  String toString() => name;
  static final CraftType craft = CraftType("craft"), fix = CraftType("fix"), process = CraftType("process");

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
  final String name;

  CraftRecipeCat(this.name);

  CraftRecipeCat.named(this.name);

  static final CraftRecipeCat tool = CraftRecipeCat("tool"),
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

typedef ItemEntryConsumeReceiver = void Function(ItemEntry item, int? mass);

abstract class CraftRecipeProtocol with Moddable {
  @JsonKey(fromJson: CraftRecipeCat.named, toJson: _cat2Name)
  final CraftRecipeCat cat;
  @JsonKey(fromJson: CraftType.named, toJson: _craftType2Name)
  final CraftType craftType;
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

  ItemEntry onCraft(List<ItemEntry> inputs);

  void onConsume(List<ItemEntry> inputs, ItemEntryConsumeReceiver consume);
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
}

@JsonSerializable(createToJson: false)
class TaggedCraftRecipe extends CraftRecipeProtocol implements JConvertibleProtocol {
  /// Item tags.
  @JsonKey()
  final List<StringMassEntry> tags;
  @JsonKey(fromJson: NamedItemGetter.create)
  final ItemGetter<Item> output;
  @override
  @JsonKey(ignore: true)
  List<ItemMatcher> toolSlots = [];
  @override
  @JsonKey(ignore: true)
  List<ItemMatcher> inputSlots = [];
  final int? outputMass;

  TaggedCraftRecipe(
    super.name,
    super.cat, {
    required this.tags,
    super.craftType,
    this.outputMass,
    required this.output,
  }) {
    for (final tag in tags) {
      inputSlots.add(ItemMatcher(
        typeOnly: (item) => item.hasTag(tag.str),
        exact: (item) => item.meta.hasTag(tag.str) && item.entryMass >= (tag.mass ?? 0.0),
      ));
    }
  }

  @override
  Item get outputItem => output();

  factory TaggedCraftRecipe.fromJson(Map<String, dynamic> json) => _$TaggedCraftRecipeFromJson(json);
  static const type = "TaggedCraftRecipe";

  @override
  String get typeName => type;

  @override
  ItemEntry onCraft(List<ItemEntry> inputs) {
    return output().create();
  }

  @override
  void onConsume(List<ItemEntry> inputs, ItemEntryConsumeReceiver consume) {
    for (final tag in tags) {
      final input = inputs.findFirstByTag(tag.str);
      assert(input != null, "$tag not found in $inputs");
      if (input == null) continue;
      consume(input, tag.mass);
    }
  }
}

@JsonSerializable(createToJson: false)
class NamedCraftRecipe extends CraftRecipeProtocol implements JConvertibleProtocol {
  /// Item names.
  final List<StringMassEntry> items;
  @JsonKey(fromJson: NamedItemGetter.create)
  final ItemGetter<Item> output;
  @override
  @JsonKey(ignore: true)
  List<ItemMatcher> toolSlots = [];
  @override
  @JsonKey(ignore: true)
  List<ItemMatcher> inputSlots = [];

  NamedCraftRecipe(
    super.name,
    super.cat, {
    super.craftType,
    required this.items,
    required this.output,
  }) {
    for (final req in items) {
      inputSlots.add(ItemMatcher(
        typeOnly: (item) => item.name == req.str,
        exact: (item) => item.meta.name == req.str,
      ));
    }
  }

  @override
  Item get outputItem => output();

  static const type = "NamedCraftRecipe";

  @override
  String get typeName => type;

  factory NamedCraftRecipe.fromJson(Map<String, dynamic> json) => _$NamedCraftRecipeFromJson(json);

  @override
  ItemEntry onCraft(List<ItemEntry> inputs) {
    return output().create();
  }

  @override
  void onConsume(List<ItemEntry> inputs, ItemEntryConsumeReceiver consume) {
    for (final item in items) {
      final input = inputs.findFirstByName(item.str);
      assert(input != null, "$item not found in $inputs");
      if (input == null) continue;
      consume(input, item.mass);
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
          return item.meta.hasTag(input.str) && item.entryMass >= (outputMass ?? item.meta.mass);
        },
      ));
    }
  }

  @override
  Item get outputItem => output();

  @override
  ItemEntry onCraft(List<ItemEntry> inputs) {
    var sumMass = 0;
    var sumWet = 0.0;
    for (final tag in inputTags) {
      final input = inputs.findFirstByTag(tag.str);
      assert(input != null, "$tag not found in $inputs");
      if (input == null) return ItemEntry.empty;
      final inputMass = input.entryMass;
      sumMass += inputMass;
      sumWet += WetComp.tryGetWet(input) * inputMass;
    }
    final res = output().create(mass: outputMass);
    WetComp.trySetWet(res, sumWet / sumMass);
    return res;
  }

  @override
  void onConsume(List<ItemEntry> inputs, ItemEntryConsumeReceiver consume) {
    for (final tag in inputTags) {
      final input = inputs.findFirstByTag(tag.str);
      assert(input != null, "$tag not found in $inputs");
      if (input == null) continue;
      consume(input, tag.mass);
    }
  }

  factory MergeWetCraftRecipe.fromJson(Map<String, dynamic> json) => _$MergeWetCraftRecipeFromJson(json);
}
