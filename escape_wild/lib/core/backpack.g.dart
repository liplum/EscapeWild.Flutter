// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backpack.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Backpack _$BackpackFromJson(Map<String, dynamic> json) => Backpack()
  ..items = (json['items'] as List<dynamic>)
      .map((e) => ItemEntry.fromJson(e as Map<String, dynamic>))
      .toList()
  ..mass = json['mass'] as int;

Map<String, dynamic> _$BackpackToJson(Backpack instance) => <String, dynamic>{
      'items': instance.items,
      'mass': instance.mass,
    };
