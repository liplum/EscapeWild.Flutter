// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimedFoodRecipe _$TimedFoodRecipeFromJson(Map<String, dynamic> json) =>
    TimedFoodRecipe(
      json['name'] as String,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => TagMassEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      dishes: (json['dishes'] as List<dynamic>)
          .map((e) => LazyItemStack.fromJson(e as Map<String, dynamic>))
          .toList(),
      cookingTime: TS.fromJsom(json['cookingTime'] as int),
    )..mod = Moddable.modId2ModFunc(json['mod'] as String);
