// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subfrigid_zone.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubFrigidZoneRoute _$SubFrigidZoneRouteFromJson(Map<String, dynamic> json) => SubFrigidZoneRoute(
      json['name'] as String,
    )
      ..mod = Moddable.modId2ModFunc(json['mod'] as String)
      ..places = _placesFromJson(json['places'])
      ..routeProgress = (json['routeProgress'] as num).toDouble();

Map<String, dynamic> _$SubFrigidZoneRouteToJson(SubFrigidZoneRoute instance) => <String, dynamic>{
      'mod': Moddable.mod2ModIdFunc(instance.mod),
      'name': instance.name,
      'places': instance.places,
      'routeProgress': instance.routeProgress,
    };

SubFrigidZonePlace _$SubFrigidZonePlaceFromJson(Map<String, dynamic> json) => SubFrigidZonePlace(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..mod = Moddable.modId2ModFunc(json['mod'] as String)
      ..exploreCount = (json['exploreCount'] as num).toInt();

Map<String, dynamic> _$SubFrigidZonePlaceToJson(SubFrigidZonePlace instance) => <String, dynamic>{
      if (instance.extra case final value?) 'extra': value,
      'mod': Moddable.mod2ModIdFunc(instance.mod),
      'name': instance.name,
      'exploreCount': instance.exploreCount,
    };

IceSheet _$IceSheetFromJson(Map<String, dynamic> json) => IceSheet(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..mod = Moddable.modId2ModFunc(json['mod'] as String)
      ..exploreCount = (json['exploreCount'] as num).toInt();

Map<String, dynamic> _$IceSheetToJson(IceSheet instance) => <String, dynamic>{
      if (instance.extra case final value?) 'extra': value,
      'mod': Moddable.mod2ModIdFunc(instance.mod),
      'name': instance.name,
      'exploreCount': instance.exploreCount,
    };

Snowfield _$SnowfieldFromJson(Map<String, dynamic> json) => Snowfield(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..mod = Moddable.modId2ModFunc(json['mod'] as String)
      ..exploreCount = (json['exploreCount'] as num).toInt();

Map<String, dynamic> _$SnowfieldToJson(Snowfield instance) => <String, dynamic>{
      if (instance.extra case final value?) 'extra': value,
      'mod': Moddable.mod2ModIdFunc(instance.mod),
      'name': instance.name,
      'exploreCount': instance.exploreCount,
    };

Rivers _$RiversFromJson(Map<String, dynamic> json) => Rivers(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..mod = Moddable.modId2ModFunc(json['mod'] as String)
      ..exploreCount = (json['exploreCount'] as num).toInt();

Map<String, dynamic> _$RiversToJson(Rivers instance) => <String, dynamic>{
      if (instance.extra case final value?) 'extra': value,
      'mod': Moddable.mod2ModIdFunc(instance.mod),
      'name': instance.name,
      'exploreCount': instance.exploreCount,
    };

ConiferousForest _$ConiferousForestFromJson(Map<String, dynamic> json) => ConiferousForest(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..mod = Moddable.modId2ModFunc(json['mod'] as String)
      ..exploreCount = (json['exploreCount'] as num).toInt();

Map<String, dynamic> _$ConiferousForestToJson(ConiferousForest instance) => <String, dynamic>{
      if (instance.extra case final value?) 'extra': value,
      'mod': Moddable.mod2ModIdFunc(instance.mod),
      'name': instance.name,
      'exploreCount': instance.exploreCount,
    };

BrownBearNest _$BrownBearNestFromJson(Map<String, dynamic> json) => BrownBearNest(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..mod = Moddable.modId2ModFunc(json['mod'] as String)
      ..exploreCount = (json['exploreCount'] as num).toInt();

Map<String, dynamic> _$BrownBearNestToJson(BrownBearNest instance) => <String, dynamic>{
      if (instance.extra case final value?) 'extra': value,
      'mod': Moddable.mod2ModIdFunc(instance.mod),
      'name': instance.name,
      'exploreCount': instance.exploreCount,
    };

Tundra _$TundraFromJson(Map<String, dynamic> json) => Tundra(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..mod = Moddable.modId2ModFunc(json['mod'] as String)
      ..exploreCount = (json['exploreCount'] as num).toInt();

Map<String, dynamic> _$TundraToJson(Tundra instance) => <String, dynamic>{
      if (instance.extra case final value?) 'extra': value,
      'mod': Moddable.mod2ModIdFunc(instance.mod),
      'name': instance.name,
      'exploreCount': instance.exploreCount,
    };

Swamp _$SwampFromJson(Map<String, dynamic> json) => Swamp(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..mod = Moddable.modId2ModFunc(json['mod'] as String)
      ..exploreCount = (json['exploreCount'] as num).toInt();

Map<String, dynamic> _$SwampToJson(Swamp instance) => <String, dynamic>{
      if (instance.extra case final value?) 'extra': value,
      'mod': Moddable.mod2ModIdFunc(instance.mod),
      'name': instance.name,
      'exploreCount': instance.exploreCount,
    };
