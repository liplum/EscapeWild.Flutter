// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimedCookRecipe _$TimedCookRecipeFromJson(Map<String, dynamic> json) =>
    TimedCookRecipe(
      json['name'] as String,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => TagMassEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      dishes: (json['dishes'] as List<dynamic>)
          .map((e) => LazyItemStack.fromJson(e as Map<String, dynamic>))
          .toList(),
      cookingTime: TS.fromJsom(json['cookingTime'] as int),
    )..mod = Moddable.modId2ModFunc(json['mod'] as String);

TransformCookRecipe _$TransformCookRecipeFromJson(Map<String, dynamic> json) =>
    TransformCookRecipe(
      json['name'] as String,
      ingredient: (json['ingredient'] as List<dynamic>).map((e) => e as String),
      dish: NamedItemGetter.create(json['dish'] as String),
      speed: (json['speed'] as num).toDouble(),
      ratio: (json['ratio'] as num?)?.toDouble() ?? 1.0,
    )..mod = Moddable.modId2ModFunc(json['mod'] as String);
