// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_comp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DurabilityComp _$DurabilityCompFromJson(Map<String, dynamic> json) =>
    DurabilityComp(
      max: (json['max'] as num).toDouble(),
      allowExceed: json['allowExceed'] as bool? ?? false,
    );

ToolAttr _$ToolAttrFromJson(Map<String, dynamic> json) => ToolAttr(
      efficiency: (json['efficiency'] as num).toDouble(),
    );

ToolComp _$ToolCompFromJson(Map<String, dynamic> json) => ToolComp(
      attr: json['attr'] == null
          ? ToolAttr.normal
          : ToolAttr.fromJson(json['attr'] as Map<String, dynamic>),
      toolType: ToolType.fromJson(json['toolType'] as String),
    );

ModifyAttrComp _$ModifyAttrCompFromJson(Map<String, dynamic> json) =>
    ModifyAttrComp(
      $enumDecode(_$UseTypeEnumMap, json['useType']),
      (json['modifiers'] as List<dynamic>).map((e) => AttrModifier.fromJson(e)),
      afterUsedItem: NamedItemGetter.create(json['afterUsedItem'] as String),
    );

const _$UseTypeEnumMap = {
  UseType.use: 'use',
  UseType.drink: 'drink',
  UseType.eat: 'eat',
  UseType.equip: 'equip',
};

FuelComp _$FuelCompFromJson(Map<String, dynamic> json) => FuelComp(
      (json['heatValue'] as num).toDouble(),
    );

WetnessComp _$WetnessCompFromJson(Map<String, dynamic> json) => WetnessComp(
      dryTime: json['dryTime'] == null
          ? WetnessComp.defaultDryTime
          : Ts.fromJson(json['dryTime'] as int),
    );

FreshnessComp _$FreshnessCompFromJson(Map<String, dynamic> json) =>
    FreshnessComp(
      expire: Ts.fromJson(json['expire'] as int),
      wetFactor: (json['wetFactor'] as num?)?.toDouble() ??
          FreshnessComp.defaultWetFactor,
    );

FireStarterComp _$FireStarterCompFromJson(Map<String, dynamic> json) =>
    FireStarterComp(
      chance: (json['chance'] as num).toDouble(),
      cost: (json['cost'] as num).toDouble(),
      consumeSelfAfterBurning: json['consumeSelfAfterBurning'] as bool? ?? true,
    );

ItemPropModifier _$ItemPropModifierFromJson(Map<String, dynamic> json) =>
    ItemPropModifier(
      $enumDecode(_$ItemPropEnumMap, json['prop']),
      (json['deltaPerMinute'] as num).toDouble(),
    );

const _$ItemPropEnumMap = {
  ItemProp.mass: 'mass',
  ItemProp.wetness: 'wetness',
  ItemProp.durability: 'durability',
  ItemProp.freshness: 'freshness',
};

ContinuousModifyItemPropComp _$ContinuousModifyItemPropCompFromJson(
        Map<String, dynamic> json) =>
    ContinuousModifyItemPropComp(
      (json['modifiers'] as List<dynamic>)
          .map((e) => ItemPropModifier.fromJson(e)),
    );

ContinuousModifyMassComp _$ContinuousModifyMassCompFromJson(
        Map<String, dynamic> json) =>
    ContinuousModifyMassComp(
      deltaPerMinute: (json['deltaPerMinute'] as num).toDouble(),
    );

ContinuousModifyWetnessComp _$ContinuousModifyWetnessCompFromJson(
        Map<String, dynamic> json) =>
    ContinuousModifyWetnessComp(
      deltaPerMinute: (json['deltaPerMinute'] as num).toDouble(),
    );

ContinuousModifyDurabilityComp _$ContinuousModifyDurabilityCompFromJson(
        Map<String, dynamic> json) =>
    ContinuousModifyDurabilityComp(
      deltaPerMinute: (json['deltaPerMinute'] as num).toDouble(),
      wetFactor: (json['wetFactor'] as num?)?.toDouble() ??
          ContinuousModifyDurabilityComp.defaultWetFactor,
    );

ContinuousModifyFreshnessComp _$ContinuousModifyFreshnessCompFromJson(
        Map<String, dynamic> json) =>
    ContinuousModifyFreshnessComp(
      deltaPerMinute: (json['deltaPerMinute'] as num).toDouble(),
      wetFactor: (json['wetFactor'] as num?)?.toDouble() ??
          FreshnessComp.defaultWetFactor,
    );
