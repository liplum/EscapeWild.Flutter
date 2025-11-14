// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'continuous.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContinuousCookRecipe _$ContinuousCookRecipeFromJson(Map<String, dynamic> json) => ContinuousCookRecipe(
  json['name'] as String,
  ingredient: (json['ingredient'] as List<dynamic>).map((e) => e as String),
  dish: NamedItemGetter.create(json['dish'] as String),
  speed: (json['speed'] as num).toDouble(),
  ratio: (json['ratio'] as num?)?.toDouble() ?? 1.0,
);
