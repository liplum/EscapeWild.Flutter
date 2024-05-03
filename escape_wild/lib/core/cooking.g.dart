// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimedCookRecipe _$TimedCookRecipeFromJson(Map<String, dynamic> json) => TimedCookRecipe(
      json['name'] as String,
      ingredients: (json['ingredients'] as List<dynamic>).map(TagMassEntry.fromJson).toList(),
      dishes: (json['dishes'] as List<dynamic>).map((e) => LazyItemStack.fromJson(e as Map<String, dynamic>)).toList(),
      cookingTime: Ts.fromJson((json['cookingTime'] as num).toInt()),
    )..mod = Moddable.modId2ModFunc(json['mod'] as String);

ContinuousCookRecipe _$ContinuousCookRecipeFromJson(Map<String, dynamic> json) => ContinuousCookRecipe(
      json['name'] as String,
      ingredient: (json['ingredient'] as List<dynamic>).map((e) => e as String),
      dish: NamedItemGetter.create(json['dish'] as String),
      speed: (json['speed'] as num).toDouble(),
      ratio: (json['ratio'] as num?)?.toDouble() ?? 1.0,
    )..mod = Moddable.modId2ModFunc(json['mod'] as String);

InstantConvertCookRecipe _$InstantConvertCookRecipeFromJson(Map<String, dynamic> json) => InstantConvertCookRecipe(
      json['name'] as String,
      input: NamedItemGetter.create(json['input'] as String),
      output: NamedItemGetter.create(json['output'] as String),
      keptProps: (json['keptProps'] as List<dynamic>?)?.map((e) => $enumDecode(_$ItemPropEnumMap, e)).toSet() ??
          InstantConvertCookRecipe.kKeptProps,
      inputMass: (json['inputMass'] as num?)?.toInt(),
      outputMass: (json['outputMass'] as num?)?.toInt(),
    )..mod = Moddable.modId2ModFunc(json['mod'] as String);

const _$ItemPropEnumMap = {
  ItemProp.mass: 'mass',
  ItemProp.wetness: 'wetness',
  ItemProp.durability: 'durability',
  ItemProp.freshness: 'freshness',
};
