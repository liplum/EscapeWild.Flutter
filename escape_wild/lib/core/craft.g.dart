// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'craft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagMassEntry _$TagMassEntryFromJson(Map<String, dynamic> json) => TagMassEntry(
      json['tag'] as String,
      json['mass'] as int?,
    );

Map<String, dynamic> _$TagMassEntryToJson(TagMassEntry instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'mass': instance.mass,
    };

TaggedCraftRecipe _$TaggedCraftRecipeFromJson(Map<String, dynamic> json) =>
    TaggedCraftRecipe(
      json['name'] as String,
      CraftRecipeCat.named(json['cat'] as String),
      tags: (json['tags'] as List<dynamic>)
          .map((e) => TagMassEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      output: NamedItemGetter.create(json['output'] as String),
    )..mod = Moddable.modId2ModFunc(json['mod'] as String);

NamedCraftRecipe _$NamedCraftRecipeFromJson(Map<String, dynamic> json) =>
    NamedCraftRecipe(
      json['name'] as String,
      CraftRecipeCat.named(json['cat'] as String),
      items: (json['items'] as List<dynamic>).map((e) => e as String).toList(),
      output: NamedItemGetter.create(json['output'] as String),
    )..mod = Moddable.modId2ModFunc(json['mod'] as String);
