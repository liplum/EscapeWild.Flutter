// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campfire.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FireState _$FireStateFromJson(Map<String, dynamic> json) =>
    FireState(ember: (json['ember'] as num?)?.toDouble() ?? 0.0, fuel: (json['fuel'] as num?)?.toDouble() ?? 0.0);

Map<String, dynamic> _$FireStateToJson(FireState instance) => <String, dynamic>{
  'ember': instance.ember,
  'fuel': instance.fuel,
};
