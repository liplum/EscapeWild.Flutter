import 'package:escape_wild/core.dart';
import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'craft.g.dart';

class CraftRecipeCat {
  final String name;

  const CraftRecipeCat(this.name);

  const CraftRecipeCat.named(this.name);

  static const CraftRecipeCat tool = CraftRecipeCat("tool"),
      food = CraftRecipeCat("food"),
      fire = CraftRecipeCat("fire"),
      refine = CraftRecipeCat("refine"),
      medical = CraftRecipeCat("medical");

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

  TaggedCraftRecipe(
    super.name,
    super.cat, {
    required this.tags,
    required this.output,
  });

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

  NamedCraftRecipe(
    super.name,
    super.cat, {
    required this.items,
    required this.output,
  });

  @override
  Item get outputItem => output();

  static const type = "NamedCraftRecipe";

  @override
  String get typeName => type;

  factory NamedCraftRecipe.fromJson(Map<String, dynamic> json) => _$NamedCraftRecipeFromJson(json);
}
