// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campfire.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FireState _$FireStateFromJson(Map<String, dynamic> json) => FireState(
      active: json['active'] as bool? ?? false,
      fuel: (json['fuel'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$FireStateToJson(FireState instance) => <String, dynamic>{
      'active': instance.active,
      'fuel': instance.fuel,
    };
