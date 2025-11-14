// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'craft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagCraftRecipe _$TagCraftRecipeFromJson(Map<String, dynamic> json) => TagCraftRecipe(
  name: json['name'] as String,
  cat: CraftRecipeCat.named(json['cat'] as String),
  ingredients: (json['ingredients'] as List<dynamic>).map(TagMassEntry.fromJson).toList(),
  craftType: CraftType.named(json['craftType'] as String),
  outputMass: (json['outputMass'] as num?)?.toInt(),
  output: NamedItemGetter.create(json['output'] as String),
)..mod = Moddable.modId2ModFunc(json['mod'] as String);
