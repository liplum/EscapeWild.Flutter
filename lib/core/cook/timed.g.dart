// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimedCookRecipe _$TimedCookRecipeFromJson(Map<String, dynamic> json) => TimedCookRecipe(
  json['name'] as String,
  ingredients: (json['ingredients'] as List<dynamic>).map(TagMassEntry.fromJson).toList(),
  dishes: (json['dishes'] as List<dynamic>).map((e) => LazyItemStack.fromJson(e as Map<String, dynamic>)).toList(),
  cookingTime: Ts.fromJson((json['cookingTime'] as num).toInt()),
);
