// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backpack.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Backpack _$BackpackFromJson(Map<String, dynamic> json) => Backpack()
  ..items = (json['items'] as List<dynamic>).map((e) => ItemStack.fromJson(e as Map<String, dynamic>)).toList()
  ..lastTrackId = (json['lastTrackId'] as num).toInt()
  ..mass = (json['mass'] as num).toInt();

Map<String, dynamic> _$BackpackToJson(Backpack instance) => <String, dynamic>{
      'items': instance.items,
      'lastTrackId': instance.lastTrackId,
      'mass': instance.mass,
    };
