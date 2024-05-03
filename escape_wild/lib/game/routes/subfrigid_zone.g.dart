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

IceSheet _$IceSheetFromJson(Map<String, dynamic> json) => IceSheet(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..mod = Moddable.modId2ModFunc(json['mod'] as String)
      ..exploreCount = (json['exploreCount'] as num).toInt();

Map<String, dynamic> _$IceSheetToJson(IceSheet instance) {
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

Snowfield _$SnowfieldFromJson(Map<String, dynamic> json) => Snowfield(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..mod = Moddable.modId2ModFunc(json['mod'] as String)
      ..exploreCount = (json['exploreCount'] as num).toInt();

Map<String, dynamic> _$SnowfieldToJson(Snowfield instance) {
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

Rivers _$RiversFromJson(Map<String, dynamic> json) => Rivers(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..mod = Moddable.modId2ModFunc(json['mod'] as String)
      ..exploreCount = (json['exploreCount'] as num).toInt();

Map<String, dynamic> _$RiversToJson(Rivers instance) {
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

ConiferousForest _$ConiferousForestFromJson(Map<String, dynamic> json) => ConiferousForest(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..mod = Moddable.modId2ModFunc(json['mod'] as String)
      ..exploreCount = (json['exploreCount'] as num).toInt();

Map<String, dynamic> _$ConiferousForestToJson(ConiferousForest instance) {
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

BrownBearNest _$BrownBearNestFromJson(Map<String, dynamic> json) => BrownBearNest(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..mod = Moddable.modId2ModFunc(json['mod'] as String)
      ..exploreCount = (json['exploreCount'] as num).toInt();

Map<String, dynamic> _$BrownBearNestToJson(BrownBearNest instance) {
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

Tundra _$TundraFromJson(Map<String, dynamic> json) => Tundra(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..mod = Moddable.modId2ModFunc(json['mod'] as String)
      ..exploreCount = (json['exploreCount'] as num).toInt();

Map<String, dynamic> _$TundraToJson(Tundra instance) {
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

Swamp _$SwampFromJson(Map<String, dynamic> json) => Swamp(
      json['name'] as String,
    )
      ..extra = json['extra'] as Map<String, dynamic>?
      ..mod = Moddable.modId2ModFunc(json['mod'] as String)
      ..exploreCount = (json['exploreCount'] as num).toInt();

Map<String, dynamic> _$SwampToJson(Swamp instance) {
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
