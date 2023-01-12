import 'package:jconverter/jconverter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'craft.g.dart';

class CraftRecipeCat {
  final String name;

  const CraftRecipeCat(this.name);

  const CraftRecipeCat.named(this.name);

  static const CraftRecipeCat tool = CraftRecipeCat("tool"),
      food = CraftRecipeCat("food"),
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

abstract class CraftRecipeProtocol {
  @JsonKey(fromJson: CraftRecipeCat.named, toJson: _cat2Name)
  final CraftRecipeCat cat;

  const CraftRecipeProtocol(this.cat);
}

@JsonSerializable(createToJson: false)
class TaggedCraftRecipe extends CraftRecipeProtocol implements JConvertibleProtocol {
  /// Item tags.
  final List<String> tagSlots;

  const TaggedCraftRecipe(super.cat, this.tagSlots);

  factory TaggedCraftRecipe.fromJson(Map<String, dynamic> json) => _$TaggedCraftRecipeFromJson(json);
  static const type = "TaggedCraftRecipe";

  @override
  String get typeName => type;
}

@JsonSerializable(createToJson: false)
class NamedCraftRecipe extends CraftRecipeProtocol implements JConvertibleProtocol {
  /// Item names.
  final List<String> items;

  const NamedCraftRecipe(super.cat, this.items);

  static const type = "NamedCraftRecipe";

  @override
  String get typeName => type;

  factory NamedCraftRecipe.fromJson(Map<String, dynamic> json) => _$NamedCraftRecipeFromJson(json);
}
