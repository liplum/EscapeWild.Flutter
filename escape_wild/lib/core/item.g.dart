// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemEntry _$ItemEntryFromJson(Map<String, dynamic> json) => ItemEntry(
      Contents.getItemMetaByName(json['meta'] as String),
      mass: json['mass'] as int?,
    )..extra = json['extra'] as Map<String, dynamic>?;

Map<String, dynamic> _$ItemEntryToJson(ItemEntry instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('extra', instance.extra);
  val['meta'] = _getItemMetaName(instance.meta);
  writeNotNull('mass', instance.mass);
  return val;
}

ContainerItemEntry _$ContainerItemEntryFromJson(Map<String, dynamic> json) =>
    ContainerItemEntry(
      Contents.getItemMetaByName(json['meta'] as String),
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..inner = json['inner'] == null
          ? null
          : ItemEntry.fromJson(json['inner'] as Map<String, dynamic>)
      ..mass = json['mass'] as int?;

Map<String, dynamic> _$ContainerItemEntryToJson(ContainerItemEntry instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('extra', instance.extra);
  val['meta'] = _getItemMetaName(instance.meta);
  writeNotNull('inner', instance.inner);
  writeNotNull('mass', instance.mass);
  return val;
}

ToolAttr _$ToolAttrFromJson(Map<String, dynamic> json) => ToolAttr(
      efficiency: (json['efficiency'] as num).toDouble(),
      durability: (json['durability'] as num).toDouble(),
    );

ToolComp _$ToolCompFromJson(Map<String, dynamic> json) => ToolComp(
      attr: json['attr'] == null
          ? ToolAttr.normal
          : ToolAttr.fromJson(json['attr'] as Map<String, dynamic>),
      toolType: ToolType.named(json['toolType'] as String),
      maxHealth: (json['maxHealth'] as num).toDouble(),
    );

ModifyAttrComp _$ModifyAttrCompFromJson(Map<String, dynamic> json) =>
    ModifyAttrComp(
      $enumDecode(_$UseTypeEnumMap, json['useType']),
      (json['modifiers'] as List<dynamic>)
          .map((e) => AttrModifier.fromJson(e as Map<String, dynamic>))
          .toList(),
      afterUsedItem: NamedItemGetter.create(json['afterUsedItem'] as String),
    );

const _$UseTypeEnumMap = {
  UseType.use: 'use',
  UseType.drink: 'drink',
  UseType.eat: 'eat',
  UseType.equip: 'equip',
};

CookableComp _$CookableCompFromJson(Map<String, dynamic> json) => CookableComp(
      $enumDecode(_$CookTypeEnumMap, json['cookType']),
      (json['fuelCost'] as num).toDouble(),
      NamedItemGetter.create(json['cookedOutput'] as String),
    );

const _$CookTypeEnumMap = {
  CookType.cook: 'cook',
  CookType.boil: 'boil',
  CookType.roast: 'roast',
};

FuelComp _$FuelCompFromJson(Map<String, dynamic> json) => FuelComp(
      (json['heatValue'] as num).toDouble(),
    );
