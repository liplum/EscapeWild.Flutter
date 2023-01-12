import 'package:escape_wild/core.dart';
import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'craft.g.dart';

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

abstract class CraftRecipeProtocol with Moddable {
  @JsonKey(fromJson: CraftRecipeCat.named, toJson: _cat2Name)
  final CraftRecipeCat cat;
  final String name;

  List<ItemMatcher> get inputSlots;

  List<ItemMatcher> get toolSlots;

  CraftRecipeProtocol(this.name, this.cat);

  Item get outputItem;
}

@JsonSerializable()
class TagMassEntry {
  @JsonKey()
  final String tag;
  @JsonKey()
  final int? mass;

  const TagMassEntry(this.tag, this.mass);

  factory TagMassEntry.fromJson(Map<String, dynamic> json) => _$TagMassEntryFromJson(json);

  Map<String, dynamic> toJson() => _$TagMassEntryToJson(this);
}

@JsonSerializable(createToJson: false)
class TaggedCraftRecipe extends CraftRecipeProtocol implements JConvertibleProtocol {
  /// Item tags.
  @JsonKey()
  final List<TagMassEntry> tags;
  @JsonKey(fromJson: NamedItemGetter.create)
  final ItemGetter<Item> output;
  @override
  List<ItemMatcher> toolSlots = [];
  @override
  List<ItemMatcher> inputSlots = [];
  final int? outputMass;

  TaggedCraftRecipe(
    super.name,
    super.cat, {
    required this.tags,
    this.outputMass,
    required this.output,
  }) {
    for (final tag in tags) {
      inputSlots.add(ItemMatcher(
        typeOnly: (item) => item.hasTag(tag.tag),
        exact: (item) => item.meta.hasTag(tag.tag) && item.actualMass >= (tag.mass ?? 0.0),
      ));
    }
  }

  @override
  Item get outputItem => output();

  factory TaggedCraftRecipe.fromJson(Map<String, dynamic> json) => _$TaggedCraftRecipeFromJson(json);
  static const type = "TaggedCraftRecipe";

  @override
  String get typeName => type;
}

@JsonSerializable(createToJson: false)
class NamedCraftRecipe extends CraftRecipeProtocol implements JConvertibleProtocol {
  /// Item names.
  final List<String> items;
  @JsonKey(fromJson: NamedItemGetter.create)
  final ItemGetter<Item> output;
  @override
  List<ItemMatcher> toolSlots = [];
  @override
  List<ItemMatcher> inputSlots = [];

  NamedCraftRecipe(
    super.name,
    super.cat, {
    required this.items,
    required this.output,
  }) {
    for (final name in items) {
      inputSlots.add(ItemMatcher(
        typeOnly: (item) => item.name == name,
        exact: (item) => item.meta.name == name,
      ));
    }
  }

  @override
  Item get outputItem => output();

  static const type = "NamedCraftRecipe";

  @override
  String get typeName => type;

  factory NamedCraftRecipe.fromJson(Map<String, dynamic> json) => _$NamedCraftRecipeFromJson(json);
}

class MergeWetCraftRecipe extends CraftRecipeProtocol {
  final List<TagMassEntry> inputTags;
  final int? outputMass;
  final ItemGetter<Item> output;

  @override
  List<ItemMatcher> inputSlots = [];

  @override
  List<ItemMatcher> toolSlots = [];

  MergeWetCraftRecipe(
    super.name,
    super.cat, {
    required this.inputTags,
    this.outputMass,
    required this.output,
  }) {
    for (final input in inputTags) {
      inputSlots.add(ItemMatcher(
        typeOnly: (item) => item.hasTag(input.tag),
        exact: (item) {
          return item.meta.hasTag(input.tag) && item.actualMass >= (outputMass ?? item.meta.mass);
        },
      ));
    }
  }

  @override
  Item get outputItem => output();

  ItemEntry onCraft(List<ItemEntry> inputs) {
    var sumMass = 0;
    var sumWet = 0.0;
    for (final tag in inputTags) {
      final input = inputs.findFirstByTag(tag.tag);
      assert(input != null, "$tag not found in $inputs");
      if (input == null) return ItemEntry.empty;
      final inputMass = input.actualMass;
      sumMass += inputMass;
      sumWet += WetComp.tryGetWet(input) * inputMass;
    }
    final res = output().create(mass: outputMass);
    WetComp.trySetWet(res, sumWet / sumMass);
    return res;
  }
}
