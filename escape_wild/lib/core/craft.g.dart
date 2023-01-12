// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'craft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StringMassEntry _$StringMassEntryFromJson(Map<String, dynamic> json) =>
    StringMassEntry(
      json['str'] as String,
      json['mass'] as int?,
    );

Map<String, dynamic> _$StringMassEntryToJson(StringMassEntry instance) =>
    <String, dynamic>{
      'str': instance.str,
      'mass': instance.mass,
    };

TaggedCraftRecipe _$TaggedCraftRecipeFromJson(Map<String, dynamic> json) =>
    TaggedCraftRecipe(
      json['name'] as String,
      CraftRecipeCat.named(json['cat'] as String),
      tags: (json['tags'] as List<dynamic>)
          .map((e) => StringMassEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      craftType: CraftType.named(json['craftType'] as String),
      outputMass: json['outputMass'] as int?,
      output: NamedItemGetter.create(json['output'] as String),
    )..mod = Moddable.modId2ModFunc(json['mod'] as String);

NamedCraftRecipe _$NamedCraftRecipeFromJson(Map<String, dynamic> json) =>
    NamedCraftRecipe(
      json['name'] as String,
      CraftRecipeCat.named(json['cat'] as String),
      craftType: CraftType.named(json['craftType'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) => StringMassEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      output: NamedItemGetter.create(json['output'] as String),
    )..mod = Moddable.modId2ModFunc(json['mod'] as String);

MergeWetCraftRecipe _$MergeWetCraftRecipeFromJson(Map<String, dynamic> json) =>
    MergeWetCraftRecipe(
      json['name'] as String,
      CraftRecipeCat.named(json['cat'] as String),
      craftType: CraftType.named(json['craftType'] as String),
      inputTags: (json['inputTags'] as List<dynamic>)
          .map((e) => StringMassEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      outputMass: json['outputMass'] as int?,
      output: NamedItemGetter.create(json['output'] as String),
    )..mod = Moddable.modId2ModFunc(json['mod'] as String);
