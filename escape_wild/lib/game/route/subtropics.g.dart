// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtropics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubtropicsRoute _$SubtropicsRouteFromJson(Map<String, dynamic> json) =>
    SubtropicsRoute(
      json['name'] as String,
    )
      ..places = (json['places'] as List<dynamic>)
          .map((e) => SubtropicsPlace.fromJson(e as Map<String, dynamic>))
          .toList()
      ..routeProgress = (json['routeProgress'] as num).toDouble()
      ..mod = Moddable.modId2ModFunc(json['mod'] as String);

Map<String, dynamic> _$SubtropicsRouteToJson(SubtropicsRoute instance) =>
    <String, dynamic>{
      'name': instance.name,
      'places': instance.places,
      'routeProgress': instance.routeProgress,
      'mod': Moddable.mod2ModIdFunc(instance.mod),
    };

SubtropicsPlace _$SubtropicsPlaceFromJson(Map<String, dynamic> json) =>
    SubtropicsPlace(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..exploreCount = json['ec'] as int;

Map<String, dynamic> _$SubtropicsPlaceToJson(SubtropicsPlace instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('extra', instance.extra);
  val['name'] = instance.name;
  val['ec'] = instance.exploreCount;
  return val;
}
