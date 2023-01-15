// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subfrigid_zone.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubFrigidZoneRoute _$SubFrigidZoneRouteFromJson(Map<String, dynamic> json) =>
    SubFrigidZoneRoute(
      json['name'] as String,
    )
      ..places = _placesFromJson(json['places'])
      ..routeProgress = (json['routeProgress'] as num).toDouble()
      ..mod = Moddable.modId2ModFunc(json['mod'] as String);

Map<String, dynamic> _$SubFrigidZoneRouteToJson(SubFrigidZoneRoute instance) =>
    <String, dynamic>{
      'name': instance.name,
      'places': instance.places,
      'routeProgress': instance.routeProgress,
      'mod': Moddable.mod2ModIdFunc(instance.mod),
    };

SubFrigidZonePlace _$SubFrigidZonePlaceFromJson(Map<String, dynamic> json) =>
    SubFrigidZonePlace(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..mod = Moddable.modId2ModFunc(json['mod'] as String)
      ..exploreCount = json['exploreCount'] as int;

Map<String, dynamic> _$SubFrigidZonePlaceToJson(SubFrigidZonePlace instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('extra', instance.extra);
  val['mod'] = Moddable.mod2ModIdFunc(instance.mod);
  val['name'] = instance.name;
  val['exploreCount'] = instance.exploreCount;
  return val;
}
