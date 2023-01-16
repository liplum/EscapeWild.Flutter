// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'craft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagCraftRecipe _$TagCraftRecipeFromJson(Map<String, dynamic> json) =>
    TagCraftRecipe(
      json['name'] as String,
      CraftRecipeCat.named(json['cat'] as String),
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => TagMassEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      craftType: CraftType.named(json['craftType'] as String),
      outputMass: json['outputMass'] as int?,
      output: NamedItemGetter.create(json['output'] as String),
    )..mod = Moddable.modId2ModFunc(json['mod'] as String);

MergeWetCraftRecipe _$MergeWetCraftRecipeFromJson(Map<String, dynamic> json) =>
    MergeWetCraftRecipe(
      json['name'] as String,
      CraftRecipeCat.named(json['cat'] as String),
      craftType: CraftType.named(json['craftType'] as String),
      inputTags: (json['inputTags'] as List<dynamic>)
          .map((e) => TagMassEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      outputMass: json['outputMass'] as int?,
      output: NamedItemGetter.create(json['output'] as String),
    )..mod = Moddable.modId2ModFunc(json['mod'] as String);
