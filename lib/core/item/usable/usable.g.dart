// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModifyAttrComp _$ModifyAttrCompFromJson(Map<String, dynamic> json) => ModifyAttrComp(
  $enumDecode(_$UseTypeEnumMap, json['useType']),
  (json['modifiers'] as List<dynamic>).map(AttrModifier.fromJson),
  afterUsedItem: NamedItemGetter.create(json['afterUsedItem'] as String),
);

const _$UseTypeEnumMap = {UseType.use: 'use', UseType.drink: 'drink', UseType.eat: 'eat', UseType.equip: 'equip'};
