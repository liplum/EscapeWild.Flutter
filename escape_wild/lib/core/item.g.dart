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

Map<String, dynamic> _$ItemStackToJson(ItemStack instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('extra', instance.extra);
  val['meta'] = Item.getName(instance.meta);
  val['id'] = instance.trackId;
  writeNotNull('mass', instance.mass);
  return val;
}

ContainerItemStack _$ContainerItemStackFromJson(Map<String, dynamic> json) => ContainerItemStack(
      Contents.getItemMetaByName(json['meta'] as String),
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..trackId = (json['id'] as num?)?.toInt()
      ..inner = json['inner'] == null ? null : ItemStack.fromJson(json['inner'] as Map<String, dynamic>)
      ..mass = (json['mass'] as num?)?.toInt();

Map<String, dynamic> _$ContainerItemStackToJson(ContainerItemStack instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('extra', instance.extra);
  val['meta'] = Item.getName(instance.meta);
  val['id'] = instance.trackId;
  writeNotNull('inner', instance.inner);
  writeNotNull('mass', instance.mass);
  return val;
}
