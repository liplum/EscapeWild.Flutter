// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemStack _$ItemStackFromJson(Map<String, dynamic> json) => ItemStack(
      Contents.getItemMetaByName(json['meta'] as String),
      mass: (json['mass'] as num?)?.toInt(),
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..trackId = (json['id'] as num?)?.toInt();

Map<String, dynamic> _$ItemStackToJson(ItemStack instance) => <String, dynamic>{
      if (instance.extra case final value?) 'extra': value,
      'meta': Item.getName(instance.meta),
      'id': instance.trackId,
      if (instance.mass case final value?) 'mass': value,
    };

ContainerItemStack _$ContainerItemStackFromJson(Map<String, dynamic> json) => ContainerItemStack(
      Contents.getItemMetaByName(json['meta'] as String),
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..trackId = (json['id'] as num?)?.toInt()
      ..inner = json['inner'] == null ? null : ItemStack.fromJson(json['inner'] as Map<String, dynamic>)
      ..mass = (json['mass'] as num?)?.toInt();

Map<String, dynamic> _$ContainerItemStackToJson(ContainerItemStack instance) => <String, dynamic>{
      if (instance.extra case final value?) 'extra': value,
      'meta': Item.getName(instance.meta),
      'id': instance.trackId,
      if (instance.inner case final value?) 'inner': value,
      if (instance.mass case final value?) 'mass': value,
    };
