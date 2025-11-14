// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InstantConvertCookRecipe _$InstantConvertCookRecipeFromJson(Map<String, dynamic> json) => InstantConvertCookRecipe(
  json['name'] as String,
  input: NamedItemGetter.create(json['input'] as String),
  output: NamedItemGetter.create(json['output'] as String),
  keptProps:
      (json['keptProps'] as List<dynamic>?)?.map((e) => $enumDecode(_$ItemPropEnumMap, e)).toSet() ??
      InstantConvertCookRecipe.kKeptProps,
  inputMass: (json['inputMass'] as num?)?.toInt(),
  outputMass: (json['outputMass'] as num?)?.toInt(),
);

const _$ItemPropEnumMap = {
  ItemProp.mass: 'mass',
  ItemProp.wetness: 'wetness',
  ItemProp.durability: 'durability',
  ItemProp.freshness: 'freshness',
};
