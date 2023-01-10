// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtropics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubtropicsPlace _$SubtropicsPlaceFromJson(Map<String, dynamic> json) =>
    SubtropicsPlace(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..exploreCount = json['exploreCount'] as int
      ..mod = Moddable.modId2ModFunc(json['mod'] as String);

Map<String, dynamic> _$SubtropicsPlaceToJson(SubtropicsPlace instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('extra', instance.extra);
  val['name'] = instance.name;
  val['exploreCount'] = instance.exploreCount;
  val['mod'] = Moddable.mod2ModIdFunc(instance.mod);
  return val;
}
