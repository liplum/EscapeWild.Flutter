// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'craft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaggedCraftRecipe _$TaggedCraftRecipeFromJson(Map<String, dynamic> json) =>
    TaggedCraftRecipe(
      CraftRecipeCat.named(json['cat'] as String),
      (json['tagSlots'] as List<dynamic>).map((e) => e as String).toList(),
    );

NamedCraftRecipe _$NamedCraftRecipeFromJson(Map<String, dynamic> json) =>
    NamedCraftRecipe(
      CraftRecipeCat.named(json['cat'] as String),
      (json['items'] as List<dynamic>).map((e) => e as String).toList(),
    );
