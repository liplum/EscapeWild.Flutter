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
      output: NamedItemGetter.create(json['output'] as String),
      cookingTime: TS.fromJsom(json['cookingTime'] as int),
      outputMass: json['outputMass'] as int?,
    )..mod = Moddable.modId2ModFunc(json['mod'] as String);
