// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FoodRecipe _$FoodRecipeFromJson(Map<String, dynamic> json) => FoodRecipe(
      json['name'] as String,
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => TagMassEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      outputs: (json['outputs'] as List<dynamic>)
          .map((e) => LazyItemStack.fromJson(e as Map<String, dynamic>))
          .toList(),
      cookingTime: TS.fromJsom(json['cookingTime'] as int),
    )..mod = Moddable.modId2ModFunc(json['mod'] as String);
