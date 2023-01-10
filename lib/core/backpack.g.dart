// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backpack.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Backpack _$BackpackFromJson(Map<String, dynamic> json) => Backpack()
  .._items = (json['items'] as List<dynamic>)
      .map((e) => ItemEntry.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$BackpackToJson(Backpack instance) => <String, dynamic>{
      'items': directConvertFunc(instance._items),
    };
